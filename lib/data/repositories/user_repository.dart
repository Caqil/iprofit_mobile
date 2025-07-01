import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../models/auth/user_model.dart';
import '../models/common/api_response.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(apiServiceProvider));
});

class UserRepository {
  final ApiService _apiService;
  static const String _dashboardCacheKey = 'dashboard_data';
  static const String _userCacheKey = 'user_data';
  static const String _preferencesCacheKey = 'user_preferences_data';
  static const String _securitySettingsCacheKey = 'security_settings_data';

  UserRepository(this._apiService);

  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.dashboard,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache dashboard data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _dashboardCacheKey,
            apiResponse.data!,
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(_dashboardCacheKey);
      if (cachedData != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: cachedData as Map<String, dynamic>,
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<UserModel>> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.profile}/$userId',
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<UserModel>.fromJson(
          response.data!,
          (json) => UserModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache user data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setUser(apiResponse.data!);
          await StorageService.setCachedData(
            _userCacheKey,
            apiResponse.data!.toJson(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(_userCacheKey);
      if (cachedData != null) {
        return ApiResponse<UserModel>(
          success: true,
          data: UserModel.fromJson(cachedData),
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<UserModel>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? dateOfBirth,
    Address? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
      if (address != null) data['address'] = address.toJson();

      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiConstants.profile}/$userId',
        data: data,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<UserModel>.fromJson(
          response.data!,
          (json) => UserModel.fromJson(json as Map<String, dynamic>),
        );

        // Update cached user data
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setUser(apiResponse.data!);
          await StorageService.setCachedData(
            _userCacheKey,
            apiResponse.data!.toJson(),
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

  Future<ApiResponse<UserPreferences>> getUserPreferences() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.preferences,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<UserPreferences>.fromJson(
          response.data!,
          (json) => UserPreferences.fromJson(json as Map<String, dynamic>),
        );

        // Cache preferences data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _preferencesCacheKey,
            apiResponse.data!.toJson(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(
        _preferencesCacheKey,
      );
      if (cachedData != null) {
        return ApiResponse<UserPreferences>(
          success: true,
          data: UserPreferences.fromJson(cachedData),
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<UserPreferences>> updateUserPreferences(
    UserPreferences preferences,
  ) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        ApiConstants.preferences,
        data: preferences.toJson(),
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<UserPreferences>.fromJson(
          response.data!,
          (json) => UserPreferences.fromJson(json as Map<String, dynamic>),
        );

        // Update cached preferences data
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _preferencesCacheKey,
            apiResponse.data!.toJson(),
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

  Future<ApiResponse<String>> uploadProfilePicture(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'resize': true,
        'quality': 80,
      });

      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/upload/profile',
        data: formData,
      );

      if (response.data != null) {
        return ApiResponse<String>.fromJson(
          response.data!,
          (json) => json.toString(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteAccount({
    required String password,
    String? reason,
  }) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '/api/users/account',
        data: {'password': password, if (reason != null) 'reason': reason},
      );

      if (response.data != null) {
        // Clear all cached data after account deletion
        await StorageService.clearAllData();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getSecuritySettings() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/security/settings',
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache security settings data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _securitySettingsCacheKey,
            apiResponse.data!,
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(
        _securitySettingsCacheKey,
      );
      if (cachedData != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: cachedData as Map<String, dynamic>,
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getLoginHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'limit': limit.toString()};

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/security/login-history',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> setup2FA() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/2fa/setup',
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

  Future<ApiResponse<void>> enable2FA({
    required String token,
    required List<String> backupCodes,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/2fa/enable',
        data: {'token': token, 'backupCodes': backupCodes},
      );

      if (response.data != null) {
        // Refresh user profile after enabling 2FA
        final user = await StorageService.getUser();
        if (user != null) {
          await getUserProfile(user.id);
        }

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> disable2FA({
    required String token,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/2fa/disable',
        data: {'token': token, 'password': password},
      );

      if (response.data != null) {
        // Refresh user profile after disabling 2FA
        final user = await StorageService.getUser();
        if (user != null) {
          await getUserProfile(user.id);
        }

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getUserDevices() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/mobile/devices',
        queryParameters: {'includeStats': 'true', 'includeHistory': 'true'},
      );

      if (response.data != null) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> updateDeviceInfo(
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/api/mobile/device-update',
        data: {'deviceId': updates['deviceId'], 'updates': updates},
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

  Future<ApiResponse<void>> removeDevice(String deviceId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '/api/mobile/devices/$deviceId',
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

  Future<ApiResponse<Map<String, dynamic>>> getAccountStats() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/stats',
      );

      if (response.data != null) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getUserAchievements({
    String category = 'all',
    String status = 'all',
    bool includeProgress = true,
  }) async {
    try {
      final queryParams = {
        'category': category,
        'status': status,
        'includeProgress': includeProgress.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.achievements,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> verifyEmail(String token) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/verify-email',
        data: {'token': token},
      );

      if (response.data != null) {
        // Refresh user profile after email verification
        final user = await StorageService.getUser();
        if (user != null) {
          await getUserProfile(user.id);
        }

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> resendVerificationEmail() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/resend-verification',
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

  // Cache management methods
  Future<Map<String, dynamic>?> getCachedDashboard() async {
    try {
      final cachedData = await StorageService.getCachedData(_dashboardCacheKey);
      return cachedData as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getCachedUser() async {
    try {
      final cachedData = await StorageService.getCachedData(_userCacheKey);
      if (cachedData != null) {
        return UserModel.fromJson(cachedData);
      }
      return await StorageService.getUser();
    } catch (e) {
      return null;
    }
  }

  Future<UserPreferences?> getCachedPreferences() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _preferencesCacheKey,
      );
      if (cachedData != null) {
        return UserPreferences.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCachedSecuritySettings() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _securitySettingsCacheKey,
      );
      return cachedData as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUserCache() async {
    await StorageService.removeCachedData(_dashboardCacheKey);
    await StorageService.removeCachedData(_userCacheKey);
    await StorageService.removeCachedData(_preferencesCacheKey);
    await StorageService.removeCachedData(_securitySettingsCacheKey);
  }

  Future<Map<String, dynamic>> getUserSummary() async {
    try {
      final user = await getCachedUser();
      final dashboard = await getCachedDashboard();

      if (user == null) return {};

      return {
        'name': user.name,
        'email': user.email,
        'balance': user.balance,
        'kycStatus': user.kycStatus,
        'emailVerified': user.emailVerified,
        'phoneVerified': user.phoneVerified,
        'twoFactorEnabled': user.twoFactorEnabled,
        'memberSince': user.createdAt,
        'lastLogin': user.lastLogin,
        'plan': user.plan?.name,
        'referralCode': user.referralCode,
        if (dashboard != null) ...dashboard,
      };
    } catch (e) {
      return {};
    }
  }
}
