import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/user_model.dart';
import '../models/common/api_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider));
});

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<LoginResponse>.fromJson(
          response.data!,
          (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        );

        // Cache user data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setUser(apiResponse.data!.user);
          await StorageService.setAccessToken(
            apiResponse.data!.tokens.accessToken,
          );
          await StorageService.setRefreshToken(
            apiResponse.data!.tokens.refreshToken,
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<UserModel>> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: request.toJson(),
      );

      if (response.data != null) {
        return ApiResponse<UserModel>.fromJson(
          response.data!,
          (json) => UserModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await _apiService.post<Map<String, dynamic>>(ApiConstants.logout);

      // Clear local storage
      await StorageService.clearAuthData();

      return ApiResponse<void>(
        success: true,
        message: 'Logged out successfully',
        timestamp: DateTime.now(),
      );
    } on DioException catch (e) {
      // Even if logout fails on server, clear local data
      await StorageService.clearAuthData();
      throw AppException.fromDioException(e);
    } catch (e) {
      await StorageService.clearAuthData();
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<TokenData>> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        throw const AppException.unauthorized('No refresh token available');
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<TokenData>.fromJson(
          response.data!,
          (json) => TokenData.fromJson(json as Map<String, dynamic>),
        );

        // Update stored tokens
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setAccessToken(apiResponse.data!.accessToken);
          await StorageService.setRefreshToken(apiResponse.data!.refreshToken);
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/auth/forgot-password',
        data: {'email': email},
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> verifyOTP({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/auth/verify-otp',
        data: {'email': email, 'otp': otp, 'type': type},
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> resendOTP({
    required String email,
    required String type,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/auth/resend-otp',
        data: {'email': email, 'type': type},
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/auth/reset-password',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/security/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        },
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getAccessToken();
    final user = await StorageService.getUser();
    return token != null && user != null;
  }

  Future<UserModel?> getCurrentUser() async {
    return await StorageService.getUser();
  }
}
