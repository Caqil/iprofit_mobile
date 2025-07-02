// lib/data/services/api_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import 'storage_service.dart';
import 'device_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(apiClientProvider));
});

/// High-level API service that provides common operations
/// and handles API responses consistently across the application
class ApiService {
  final ApiClient _apiClient;

  ApiService(this._apiClient);

  // ===== GENERIC HTTP METHODS =====

  /// Generic GET request with automatic response parsing
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final options = Options(
        headers: headers,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request with automatic response parsing
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final options = Options(
        headers: headers,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request with automatic response parsing
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final options = Options(
        headers: headers,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

      final response = await _apiClient.put<Map<String, dynamic>>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request with automatic response parsing
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final options = Options(
        headers: headers,
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

      final response = await _apiClient.delete<Map<String, dynamic>>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ===== SPECIALIZED METHODS =====

  /// Get paginated data with automatic parsing
  Future<PaginatedResponse<T>> getPaginated<T>(
    String endpoint, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    Map<String, String>? headers,
  }) async {
    try {
      final params = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
        ApiConstants.sortByParam: sortBy,
        ApiConstants.sortOrderParam: sortOrder,
        if (queryParameters != null) ...queryParameters,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == ApiConstants.statusOk &&
          response.data != null) {
        return PaginatedResponse<T>.fromJson(
          response.data!,
          fromJson ?? (json) => json as T,
        );
      }

      throw AppException.serverError('Failed to fetch paginated data');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file with progress tracking
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    T Function(dynamic)? fromJson,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalFields != null) ...additionalFields,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        endpoint,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ===== UTILITY METHODS =====

  /// Check if the API is reachable
  Future<bool> checkConnectivity() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.systemHealth}',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == ApiConstants.statusOk;
    } catch (e) {
      return false;
    }
  }

  /// Get API version information
  Future<ApiResponse<Map<String, dynamic>>> getApiVersion() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.systemVersion,
      );
      return _parseResponse<Map<String, dynamic>>(
        response,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Send device information for analytics
  Future<void> sendDeviceInfo() async {
    try {
      final deviceInfo = await DeviceService.getFullDeviceInfo();

      await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.apiPrefix}/device/info',
        data: deviceInfo,
      );
    } catch (e) {
      // Silently fail device info sending
      // This is not critical for app functionality
    }
  }

  // ===== PRIVATE METHODS =====

  /// Parse API response into ApiResponse object
  ApiResponse<T> _parseResponse<T>(
    Response<Map<String, dynamic>> response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode == ApiConstants.statusOk ||
        response.statusCode == ApiConstants.statusCreated) {
      if (response.data != null) {
        return ApiResponse<T>.fromJson(
          response.data!,
          fromJson ?? (json) => json as T,
        );
      }
    }

    throw AppException.serverError('Invalid response: ${response.statusCode}');
  }

  /// Handle and convert errors to AppException
  AppException _handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    return AppException.fromException(error as Exception);
  }
}
