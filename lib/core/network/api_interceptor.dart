import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:iprofit_mobile/core/errors/app_exception.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/device_service.dart';
import 'error_handler.dart';
import 'app_exception.dart';

/// API Interceptor for handling authentication, headers, and request/response processing
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

      // Record breadcrumb for debugging
      _errorHandler.recordBreadcrumb(
        'API Request: ${options.method} ${options.path}',
        data: {
          'method': options.method,
          'path': options.path,
          'headers': _sanitizeHeaders(options.headers),
        },
      );

      super.onRequest(options, handler);
    } catch (e) {
      final error = _errorHandler.handleError(e);
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
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

      // Record successful response breadcrumb
      _errorHandler.recordBreadcrumb(
        'API Response: ${response.statusCode} ${response.requestOptions.path}',
        data: {
          'statusCode': response.statusCode ?? 0,
          'method': response.requestOptions.method,
          'path': response.requestOptions.path,
        },
      );

      // Validate response structure
      if (!_isValidResponse(response)) {
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
      final error = _errorHandler.handleError(e);
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: error,
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      // Log error if debugging is enabled
      if (AppConfig.enableDebugLogging) {
        _logError(err);
      }

      // Record error breadcrumb
      _errorHandler.recordBreadcrumb(
        'API Error: ${err.response?.statusCode ?? 'Network'} ${err.requestOptions.path}',
        data: {
          'statusCode': err.response?.statusCode ?? 0,
          'method': err.requestOptions.method,
          'path': err.requestOptions.path,
          'errorType': err.type.name,
        },
      );

      // Handle token refresh for 401 errors
      if (err.response?.statusCode == 401 &&
          !err.requestOptions.path.contains('/auth/')) {
        final refreshed = await _handleTokenRefresh(err.requestOptions);
        if (refreshed) {
          // Retry the original request with new token
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
          return;
        }
      }

      // Convert DioException to AppException
      final appException = _errorHandler.handleError(err);

      // Create new DioException with AppException
      final newError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: appException,
        type: err.type,
        stackTrace: err.stackTrace,
        message: appException.message,
      );

      super.onError(newError, handler);
    } catch (e) {
      // If error handling fails, pass through original error
      super.onError(err, handler);
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
      ApiConstants.userAgentHeader: AppConfig.userAgent,
      ApiConstants.contentType: ApiConstants.contentType,
      ApiConstants.accept: ApiConstants.accept,
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
