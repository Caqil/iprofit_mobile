// ============================================================================
// lib/core/network/api_client.dart - ENHANCED VERSION
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/device_service.dart';
import 'api_interceptor.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'IProfit-Flutter-Client/1.0.0',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptor());

    // Enhanced logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          print('🌐 HTTP: $object');
        },
      ),
    );
  }

  /// Enhanced GET request with better error handling
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('🔄 GET Request: $path');
      if (queryParameters != null) {
        print('📋 Query Params: $queryParameters');
      }

      await _ensureConnectivity();
      await _addAuthHeaders(options);

      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      print('✅ GET Success: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ GET Error: $e');
      print('📍 Error Type: ${e.runtimeType}');
      throw _handleError(e, 'GET $path');
    }
  }

  /// Enhanced POST request with better error handling
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('🔄 POST Request: $path');
      if (data != null) {
        print('📦 Request Data Type: ${data.runtimeType}');
      }

      await _ensureConnectivity();
      await _addAuthHeaders(options);

      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      print('✅ POST Success: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ POST Error: $e');
      print('📍 Error Type: ${e.runtimeType}');
      throw _handleError(e, 'POST $path');
    }
  }

  /// Enhanced PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('🔄 PUT Request: $path');

      await _ensureConnectivity();
      await _addAuthHeaders(options);

      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      print('✅ PUT Success: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ PUT Error: $e');
      throw _handleError(e, 'PUT $path');
    }
  }

  /// Enhanced DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print('🔄 DELETE Request: $path');

      await _ensureConnectivity();
      await _addAuthHeaders(options);

      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      print('✅ DELETE Success: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ DELETE Error: $e');
      throw _handleError(e, 'DELETE $path');
    }
  }

  /// Enhanced connectivity check
  Future<void> _ensureConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      print('📶 Connectivity: $connectivityResult');

      if (connectivityResult == ConnectivityResult.none) {
        throw const AppException.network('No internet connection');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw const AppException.network('Failed to check connectivity');
    }
  }

  /// Enhanced auth headers addition
  Future<void> _addAuthHeaders(Options? options) async {
    try {
      final token = await StorageService.getAccessToken();
      final deviceId = await DeviceService.getDeviceId();
      final fingerprint = await DeviceService.getDeviceFingerprint();

      final headers = <String, dynamic>{
        'X-Request-ID': DateTime.now().millisecondsSinceEpoch.toString(),
        'X-Client-Version': '1.0.0',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      if (deviceId.isNotEmpty) {
        headers['X-Device-ID'] = deviceId;
      }

      if (fingerprint.isNotEmpty) {
        headers['X-Fingerprint'] = fingerprint;
      }

      if (options == null) {
        options = Options(headers: headers);
      } else {
        options.headers = {...?options.headers, ...headers};
      }

      print('🔐 Auth headers added');
    } catch (e) {
      print('⚠️ Failed to add auth headers: $e');
      // Don't fail the request for header issues
    }
  }

  /// Enhanced error handling
  AppException _handleError(dynamic error, String context) {
    print('🚨 Handling error in $context');
    print('📋 Error details: $error');
    print('📍 Error type: ${error.runtimeType}');

    // Handle specific cases that cause "Instance of 'Future'" errors
    if (error.toString().contains('Instance of \'Future\'')) {
      print('🔍 Detected Future instance error');
      return AppException.parseError(
        'Async operation failed. Please try again.',
      );
    }

    if (error is DioException) {
      print('🌐 DioException details:');
      print('   Type: ${error.type}');
      print('   Message: ${error.message}');
      print('   Status Code: ${error.response?.statusCode}');
      print('   Response Data: ${error.response?.data}');

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          print('⏱️ Connection timeout');
          return const AppException.network(
            'Connection timeout. Please check your internet connection.',
          );

        case DioExceptionType.sendTimeout:
          print('⏱️ Send timeout');
          return const AppException.network(
            'Request timeout. Please try again.',
          );

        case DioExceptionType.receiveTimeout:
          print('⏱️ Receive timeout');
          return const AppException.network(
            'Server response timeout. Please try again.',
          );

        case DioExceptionType.badResponse:
          print('📄 Bad response');
          return _handleResponseError(error.response, context);

        case DioExceptionType.cancel:
          print('🚫 Request cancelled');
          return const AppException.requestCancelled('Request was cancelled');

        case DioExceptionType.connectionError:
          print('🔌 Connection error');
          if (error.message?.contains('SocketException') == true) {
            return const AppException.network(
              'Cannot connect to server. Please check your internet connection.',
            );
          }
          return const AppException.network(
            'Connection failed. Please try again.',
          );

        case DioExceptionType.unknown:
          print('❓ Unknown error');
          if (error.error != null) {
            print('   Underlying error: ${error.error}');
            print('   Underlying error type: ${error.error.runtimeType}');

            // Handle specific underlying errors
            if (error.error.toString().contains('SocketException')) {
              return const AppException.network(
                'Cannot reach server. Please check your connection.',
              );
            }

            if (error.error.toString().contains('HandshakeException')) {
              return const AppException.network(
                'SSL connection failed. Please try again.',
              );
            }
          }
          return AppException.unknown(
            'Network error: ${error.message ?? "Unknown error"}',
          );
        case DioExceptionType.badCertificate:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }

    // Handle other exception types
    if (error is AppException) {
      return error;
    }

    // Generic error fallback
    print('🔮 Generic error fallback');
    return AppException.unknown(
      'Unexpected error in $context: ${error.toString()}',
    );
  }

  /// Enhanced response error handling
  AppException _handleResponseError(Response? response, String context) {
    if (response == null) {
      print('📭 Null response');
      return const AppException.unknown('No response received from server');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    print('📊 Response Error Details:');
    print('   Status: $statusCode');
    print('   Data Type: ${data.runtimeType}');
    print('   Data: $data');

    String message = 'Request failed';
    Map<String, dynamic>? details;

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        message = data['message'].toString();
      } else if (data['error'] != null) {
        message = data['error'].toString();
      } else if (data['errors'] != null) {
        message = data['errors'].toString();
      }

      details = data;
    } else if (data is String) {
      message = data;
    }

    // Handle specific status codes
    switch (statusCode) {
      case 400:
        print('🚫 Bad Request');
        return AppException.badRequest(message);

      case 401:
        print('🔐 Unauthorized');
        return AppException.unauthorized(
          'Authentication required. Please login again.',
        );

      case 403:
        print('🛡️ Forbidden');
        return AppException.forbidden(
          'Access denied. You don\'t have permission to perform this action.',
        );

      case 404:
        print('🔍 Not Found');
        return AppException.notFound('The requested resource was not found.');

      case 422:
        print('✏️ Validation Error');
        return AppException.validationError(message, details);

      case 429:
        print('🚦 Rate Limited');
        return AppException.rateLimited(
          'Too many requests. Please wait a moment and try again.',
        );

      case 500:
        print('💥 Internal Server Error');
        return AppException.serverError(
          'Server error. Please try again later.',
        );

      case 502:
        print('🌉 Bad Gateway');
        return AppException.serverError(
          'Server temporarily unavailable. Please try again.',
        );

      case 503:
        print('🔧 Service Unavailable');
        return AppException.serverError(
          'Service temporarily unavailable. Please try again later.',
        );

      case 504:
        print('⏰ Gateway Timeout');
        return AppException.serverError('Server timeout. Please try again.');

      default:
        print('❓ Unhandled status code: $statusCode');
        return AppException.unknown(
          'Request failed with status $statusCode: $message',
        );
    }
  }

  /// Get current base URL for debugging
  String get baseUrl => _dio.options.baseUrl;

  /// Check if client is properly configured
  bool get isConfigured => _dio.options.baseUrl.isNotEmpty;
}
