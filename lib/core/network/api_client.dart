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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'IProfit-Flutter-Client/1.0.0',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptor());
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureConnectivity();
    await _addAuthHeaders(options);

    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureConnectivity();
    await _addAuthHeaders(options);

    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureConnectivity();
    await _addAuthHeaders(options);

    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureConnectivity();
    await _addAuthHeaders(options);

    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _ensureConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw const AppException.network('No internet connection');
    }
  }

  Future<void> _addAuthHeaders(Options? options) async {
    final token = await StorageService.getAccessToken();
    final deviceId = await DeviceService.getDeviceId();
    final fingerprint = await DeviceService.getDeviceFingerprint();

    final headers = <String, dynamic>{};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (deviceId != null) {
      headers['x-device-id'] = deviceId;
    }

    if (fingerprint != null) {
      headers['x-fingerprint'] = fingerprint;
    }

    if (options == null) {
      options = Options(headers: headers);
    } else {
      options.headers = {...?options.headers, ...headers};
    }
  }

  AppException _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const AppException.network('Connection timeout');
        case DioExceptionType.badResponse:
          return _handleResponseError(error.response);
        case DioExceptionType.cancel:
          return const AppException.requestCancelled('Request cancelled');
        default:
          return const AppException.unknown('Something went wrong');
      }
    }
    return const AppException.unknown('Unexpected error occurred');
  }

  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return const AppException.unknown('No response received');
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String message = 'Something went wrong';
    if (data is Map<String, dynamic> && data['error'] != null) {
      message = data['error'].toString();
    }

    switch (statusCode) {
      case 400:
        return AppException.badRequest(message);
      case 401:
        return AppException.unauthorized(message);
      case 403:
        return AppException.forbidden(message);
      case 404:
        return AppException.notFound(message);
      case 422:
        return AppException.validationError(message, data['details']);
      case 429:
        return AppException.rateLimited(message);
      case 500:
        return AppException.serverError(message);
      default:
        return AppException.unknown(message);
    }
  }
}
