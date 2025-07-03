// ============================================================================
// lib/core/network/api_interceptor.dart - FIXED VERSION
// ============================================================================

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:iprofit_mobile/core/errors/app_exception.dart';
import 'package:iprofit_mobile/core/errors/error_handler.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/device_service.dart';

/// Fixed API Interceptor with proper async error handling
class ApiInterceptor extends Interceptor {
  final ErrorHandler _errorHandler = ErrorHandler();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Add authentication headers
      await _addAuthHeaders(options);

      // Add device headers
      await _addDeviceHeaders(options);

      // Add common headers
      _addCommonHeaders(options);

      // Log request if debugging is enabled
      if (AppConfig.enableDebugLogging) {
        _logRequest(options);
      }

      super.onRequest(options, handler);
    } catch (e) {
      print('❌ Request interceptor error: $e');

      // Handle error synchronously for request interceptor
      final appException = e is AppException
          ? e
          : AppException.fromException(e as Exception);

      handler.reject(
        DioException(
          requestOptions: options,
          error: appException,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      // Log response if debugging is enabled
      if (AppConfig.enableDebugLogging) {
        _logResponse(response);
      }

      // Validate response structure
      if (!_isValidResponse(response)) {
        print('❌ Invalid response structure');
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: const AppException.parseError('Invalid response format'),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }

      super.onResponse(response, handler);
    } catch (e) {
      print('❌ Response interceptor error: $e');

      final appException = e is AppException
          ? e
          : AppException.fromException(e as Exception);

      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: appException,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      print('🚨 Interceptor handling error: ${err.type}');
      print('🔍 Error message: ${err.message}');
      print('🔍 Response status: ${err.response?.statusCode}');

      // Log error if debugging is enabled
      if (AppConfig.enableDebugLogging) {
        _logError(err);
      }

      // Handle token refresh for 401 errors
      if (err.response?.statusCode == 401 &&
          !err.requestOptions.path.contains('/auth/')) {
        print('🔄 Attempting token refresh...');
        final refreshed = await _handleTokenRefresh(err.requestOptions);
        if (refreshed) {
          print('✅ Token refreshed, retrying request...');
          // Retry the original request with new token
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        }
        print('❌ Token refresh failed');
      }

      // ✅ FIXED: Properly await the error handler and extract AppException
      print('🔧 Processing error with error handler...');
      final errorHandlerResult = await _errorHandler.handleError(err);
      final appException = errorHandlerResult.exception;

      print('✅ Error processed: ${appException.runtimeType}');
      print('📄 User message: ${errorHandlerResult.userMessage}');

      // Create new DioException with proper AppException
      final newError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: appException,
        type: err.type,
        stackTrace: err.stackTrace,
        message:
            errorHandlerResult.userMessage, // Use the user-friendly message
      );

      super.onError(newError, handler);
    } catch (e) {
      print('❌ Error handler failed: $e');
      print('📍 Error type: ${e.runtimeType}');

      // If error handling fails, create a simple AppException
      final fallbackException = AppException.unknown(
        'Request failed: ${e.toString().replaceAll('Instance of \'Future', 'Processing error')}',
      );

      final fallbackError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: fallbackException,
        type: DioExceptionType.unknown,
        stackTrace: err.stackTrace,
        message: fallbackException.userMessage,
      );

      super.onError(fallbackError, handler);
    }
  }

  /// Add authentication headers to request
  Future<void> _addAuthHeaders(RequestOptions options) async {
    try {
      // Skip auth headers for auth endpoints
      if (_isAuthEndpoint(options.path)) {
        return;
      }

      final accessToken = await StorageService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers[ApiConstants.authorizationHeader] =
            'Bearer $accessToken';
      }
    } catch (e) {
      // Log error but don't fail the request
      if (AppConfig.enableDebugLogging) {
        debugPrint('Failed to add auth headers: $e');
      }
    }
  }

  /// Add device identification headers
  Future<void> _addDeviceHeaders(RequestOptions options) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final fingerprint = await DeviceService.getDeviceFingerprint();

      if (deviceId.isNotEmpty) {
        options.headers[ApiConstants.deviceIdHeader] = deviceId;
      }

      if (fingerprint.isNotEmpty) {
        options.headers[ApiConstants.fingerprintHeader] = fingerprint;
      }

      // Add ngrok headers for development
      if (options.baseUrl.contains('ngrok')) {
        options.headers['ngrok-skip-browser-warning'] = 'true';
      }
    } catch (e) {
      // Log error but don't fail the request
      if (AppConfig.enableDebugLogging) {
        debugPrint('Failed to add device headers: $e');
      }
    }
  }

  /// Add common headers to all requests
  void _addCommonHeaders(RequestOptions options) {
    options.headers.addAll({
      // ✅ FIXED: Use proper header names, not values as names
      'User-Agent': AppConfig.userAgent,
      'Content-Type':
          ApiConstants.contentType, // 'Content-Type': 'application/json'
      'Accept': ApiConstants.accept, // 'Accept': 'application/json'
      'X-App-Version': AppConfig.appVersion,
      'X-Platform': AppConfig.currentConfig.name,
      'X-Request-ID': _generateRequestId(),
      'X-Timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle token refresh for expired tokens
  Future<bool> _handleTokenRefresh(RequestOptions originalOptions) async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleAuthFailure();
        return false;
      }

      // Create new Dio instance to avoid interceptor loop
      final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        final newRefreshToken = response.data['data']['refreshToken'];

        // Save new tokens
        await StorageService.setAccessToken(newAccessToken);
        await StorageService.setRefreshToken(newRefreshToken);

        return true;
      } else {
        await _handleAuthFailure();
        return false;
      }
    } catch (e) {
      await _handleAuthFailure();
      return false;
    }
  }

  /// Handle authentication failure by clearing tokens
  Future<void> _handleAuthFailure() async {
    try {
      await StorageService.clearAuthData();
      // Note: Navigation to login should be handled by the app state management
    } catch (e) {
      if (AppConfig.enableDebugLogging) {
        debugPrint('Failed to handle auth failure: $e');
      }
    }
  }

  /// Retry the original request after token refresh
  Future<Response> _retry(RequestOptions requestOptions) async {
    // Add new auth header
    final accessToken = await StorageService.getAccessToken();
    if (accessToken != null) {
      requestOptions.headers[ApiConstants.authorizationHeader] =
          'Bearer $accessToken';
    }

    // Create new Dio instance to avoid interceptor loop
    final dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

    return await dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  /// Check if endpoint is an authentication endpoint
  bool _isAuthEndpoint(String path) {
    final authPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refreshToken,
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
      ApiConstants.verifyEmail,
      ApiConstants.verifyOtp,
    ];

    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// Validate response structure
  bool _isValidResponse(Response response) {
    try {
      // Check if response data exists
      if (response.data == null) {
        return false;
      }

      // For non-JSON responses (like file downloads), accept them
      if (response.headers.value('content-type')?.contains('json') != true) {
        return true;
      }

      // For API responses, expect specific structure
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Check for standard API response structure
        return data.containsKey('success') ||
            data.containsKey('data') ||
            data.containsKey('message');
      }

      // Allow arrays and primitive types
      return response.data is List ||
          response.data is String ||
          response.data is num ||
          response.data is bool;
    } catch (e) {
      return false;
    }
  }

  /// Generate unique request ID for tracking
  String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// Sanitize headers for logging (remove sensitive data)
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);

    // Remove or mask sensitive headers
    final sensitiveHeaders = [
      ApiConstants.authorizationHeader.toLowerCase(),
      ApiConstants.fingerprintHeader.toLowerCase(),
      'cookie',
      'set-cookie',
    ];

    sanitized.removeWhere((key, value) {
      final keyLower = key.toString().toLowerCase();
      if (sensitiveHeaders.contains(keyLower)) {
        if (keyLower == ApiConstants.authorizationHeader.toLowerCase()) {
          sanitized[key] = 'Bearer ***';
        } else {
          sanitized[key] = '***';
        }
        return false;
      }
      return false;
    });

    return sanitized;
  }

  /// Log HTTP request
  void _logRequest(RequestOptions options) {
    if (!AppConfig.enableDebugLogging) return;

    final message =
        '''
╭─────────────────────────────────────────────────────────────
│ 🚀 REQUEST
├─────────────────────────────────────────────────────────────
│ ${options.method.toUpperCase()} ${options.uri}
│ Headers: ${_sanitizeHeaders(options.headers)}
│ Query Parameters: ${options.queryParameters}
│ Data: ${_sanitizeRequestData(options.data)}
╰─────────────────────────────────────────────────────────────
''';

    developer.log(message, name: 'ApiInterceptor');

    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log HTTP response
  void _logResponse(Response response) {
    if (!AppConfig.enableDebugLogging) return;

    final message =
        '''
╭─────────────────────────────────────────────────────────────
│ ✅ RESPONSE
├─────────────────────────────────────────────────────────────
│ ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}
│ Status: ${response.statusCode} ${response.statusMessage}
│ Headers: ${_sanitizeHeaders(response.headers.map)}
│ Data: ${_sanitizeResponseData(response.data)}
╰─────────────────────────────────────────────────────────────
''';

    developer.log(message, name: 'ApiInterceptor');

    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log HTTP error
  void _logError(DioException error) {
    if (!AppConfig.enableDebugLogging) return;

    final message =
        '''
╭─────────────────────────────────────────────────────────────
│ ❌ ERROR
├─────────────────────────────────────────────────────────────
│ ${error.requestOptions.method.toUpperCase()} ${error.requestOptions.uri}
│ Status: ${error.response?.statusCode ?? 'No Response'}
│ Type: ${error.type.name}
│ Message: ${error.message}
│ Response Data: ${error.response?.data}
╰─────────────────────────────────────────────────────────────
''';

    developer.log(message, name: 'ApiInterceptor', level: 1000);

    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Sanitize request data for logging
  String _sanitizeRequestData(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is FormData) {
        return 'FormData with ${data.fields.length} fields and ${data.files.length} files';
      }

      if (data is Map<String, dynamic>) {
        final sanitized = Map<String, dynamic>.from(data);

        // Remove sensitive fields
        final sensitiveFields = [
          'password',
          'confirmPassword',
          'pin',
          'otp',
          'token',
          'secret',
          'key',
          'private',
        ];

        for (final field in sensitiveFields) {
          if (sanitized.containsKey(field)) {
            sanitized[field] = '***';
          }
        }

        return jsonEncode(sanitized);
      }

      return data.toString();
    } catch (e) {
      return 'Data sanitization failed: $e';
    }
  }

  /// Sanitize response data for logging
  String _sanitizeResponseData(dynamic data) {
    if (data == null) return 'null';

    try {
      // Limit response data size in logs
      final dataString = data.toString();
      if (dataString.length > 1000) {
        return '${dataString.substring(0, 1000)}... (truncated)';
      }

      return dataString;
    } catch (e) {
      return 'Response data logging failed: $e';
    }
  }
}

/// Extension methods for better error handling in API calls
extension DioExceptionX on DioException {
  /// Check if error is due to network connectivity
  bool get isNetworkError {
    return type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        message?.contains('SocketException') == true;
  }

  /// Check if error is due to authentication issues
  bool get isAuthError {
    return response?.statusCode == 401 || response?.statusCode == 403;
  }

  /// Check if error is due to server issues
  bool get isServerError {
    final statusCode = response?.statusCode ?? 0;
    return statusCode >= 500 && statusCode < 600;
  }

  /// Check if error is due to client issues
  bool get isClientError {
    final statusCode = response?.statusCode ?? 0;
    return statusCode >= 400 && statusCode < 500;
  }

  /// Get user-friendly error message
  String get userMessage {
    if (error is AppException) {
      return (error as AppException).userMessage;
    }

    if (isNetworkError) {
      return 'Please check your internet connection and try again.';
    }

    if (isAuthError) {
      return 'Authentication failed. Please login again.';
    }

    if (isServerError) {
      return 'Server error. Please try again later.';
    }

    return message ?? 'Something went wrong. Please try again.';
  }
}
