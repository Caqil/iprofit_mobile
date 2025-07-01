import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/register_request.dart';
import '../models/auth/user_model.dart';
import '../models/common/api_response.dart';
import '../services/storage_service.dart';
import '../services/device_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  /// Login user with credentials
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<LoginResponse>.fromJson(
          response.data!,
          (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Store tokens and user data
          await _storeAuthData(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Login failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Register new user
  Future<ApiResponse<LoginResponse>> register(RegisterRequest request) async {
    try {
      // Add device ID to request
      final deviceId = await DeviceService.getDeviceId();
      final requestWithDevice = RegisterRequest(
        name: request.name,
        email: request.email,
        phone: request.phone,
        password: request.password,
        confirmPassword: request.confirmPassword,
        deviceId: deviceId,
        planId: request.planId,
        referralCode: request.referralCode,
        dateOfBirth: request.dateOfBirth,
        address: request.address,
        acceptTerms: request.acceptTerms,
        acceptPrivacy: request.acceptPrivacy,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: requestWithDevice.toJson(),
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        final apiResponse = ApiResponse<LoginResponse>.fromJson(
          response.data!,
          (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Store tokens and user data
          await _storeAuthData(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Registration failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.logout,
      );

      // Clear local data regardless of API response
      await _clearAuthData();

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      // Return success even if API call fails (local logout)
      return ApiResponse<void>(
        success: true,
        message: 'Logged out successfully',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Clear local data even if logout API fails
      await _clearAuthData();

      return ApiResponse<void>(
        success: true,
        message: 'Logged out successfully',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Refresh access token
  Future<ApiResponse<LoginResponse>> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        throw AppException.unauthorized('No refresh token available');
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<LoginResponse>.fromJson(
          response.data!,
          (json) => LoginResponse.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Store new tokens
          await _storeAuthData(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.unauthorized('Token refresh failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Forgot password
  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Forgot password request failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Reset password
  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Password reset failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Password change failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Verify email with OTP
  Future<ApiResponse<void>> verifyEmail(String otp) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.verifyEmail,
        data: {'otp': otp},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Email verification failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Resend verification email
  Future<ApiResponse<void>> resendVerification() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.resendVerification,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Resend verification failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await StorageService.getAccessToken();
      final user = await StorageService.getUser();
      return token != null && user != null;
    } catch (e) {
      return false;
    }
  }

  /// Get current user from storage
  Future<UserModel?> getCurrentUser() async {
    try {
      return await StorageService.getUser();
    } catch (e) {
      return null;
    }
  }

  /// Store authentication data
  Future<void> _storeAuthData(LoginResponse loginResponse) async {
    await Future.wait([
      StorageService.setAccessToken(loginResponse.tokens.accessToken),
      StorageService.setRefreshToken(loginResponse.tokens.refreshToken),
      StorageService.setUser(loginResponse.user),
    ]);
  }

  /// Clear authentication data
  Future<void> _clearAuthData() async {
    await StorageService.clearAuthData();
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await StorageService.getAccessToken();
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await StorageService.getRefreshToken();
  }

  /// Update stored user data
  Future<void> updateStoredUser(UserModel user) async {
    await StorageService.setUser(user);
  }

  /// Check if session is valid
  Future<bool> isSessionValid() async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) return false;

      // You could add token expiry check here if tokens contain expiry info
      return true;
    } catch (e) {
      return false;
    }
  }
}
