import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/auth/user_model.dart';
import '../models/common/api_response.dart';
import '../services/storage_service.dart';
import '../services/device_service.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(apiClientProvider));
});

class UserRepository {
  final ApiClient _apiClient;
  static const String _cacheKeyDashboard = 'dashboard_data';
  static const String _cacheKeyProfile = 'user_profile';
  static const String _cacheKeyPreferences = 'user_preferences';
  static const String _cacheKeyDevices = 'user_devices';
  static const String _cacheKeySecurityLogs = 'security_logs';
  static const String _cacheKeyUserSummary = 'user_summary';
  static const Duration _cacheExpiry = Duration(minutes: 15);

  UserRepository(this._apiClient);
  Future<ApiResponse<Map<String, dynamic>>> getUserSummary({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedUserSummary();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'User summary loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.userPrefix}/summary',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheUserSummary(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch user summary');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get dashboard data
  Future<ApiResponse<Map<String, dynamic>>> getDashboard({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedDashboard();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Dashboard data loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.dashboard,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheDashboard(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch dashboard data');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user profile by ID
  Future<ApiResponse<UserModel>> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.profile}/$userId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<UserModel>.fromJson(
          response.data!,
          (json) => UserModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw AppException.serverError('Failed to fetch user profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get current user profile
  Future<ApiResponse<UserModel>> getCurrentUserProfile({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedProfile();
        if (cached != null) {
          return ApiResponse<UserModel>(
            success: true,
            data: cached,
            message: 'User profile loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.profile,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<UserModel>.fromJson(
          response.data!,
          (json) => UserModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result and update stored user
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheProfile(apiResponse.data!);
          await StorageService.setUser(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch user profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.updateProfile,
        data: updates,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<UserModel>.fromJson(
          response.data!,
          (json) => UserModel.fromJson(json as Map<String, dynamic>),
        );

        // Update cache and stored user
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheProfile(apiResponse.data!);
          await StorageService.setUser(apiResponse.data!);
          await _clearDashboardCache(); // Dashboard might need refresh
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to update profile');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Upload profile picture
  Future<ApiResponse<Map<String, dynamic>>> uploadProfilePicture({
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.uploadProfile,
        data: formData,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Clear profile cache to force refresh
        await _clearProfileCache();

        return apiResponse;
      }

      throw AppException.serverError('Failed to upload profile picture');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Upload document
  Future<ApiResponse<Map<String, dynamic>>> uploadDocument({
    required String filePath,
    required String documentType,
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(filePath),
        'document_type': documentType,
        if (description != null) 'description': description,
      });

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.uploadDocument,
        data: formData,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to upload document');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user preferences
  Future<ApiResponse<Map<String, dynamic>>> getUserPreferences({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedPreferences();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'User preferences loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.preferences,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cachePreferences(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch user preferences');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Update user preferences
  Future<ApiResponse<Map<String, dynamic>>> updatePreferences({
    required Map<String, dynamic> preferences,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.preferences,
        data: preferences,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Update cache
        if (apiResponse.success && apiResponse.data != null) {
          await _cachePreferences(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to update preferences');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Change user password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to change password');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Enable/disable two-factor authentication
  Future<ApiResponse<Map<String, dynamic>>> toggle2FA({
    required bool enable,
    String? token,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.authPrefix}/2fa',
        data: {'enable': enable, if (token != null) 'token': token},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear profile cache to reflect 2FA status change
        await _clearProfileCache();

        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to toggle 2FA');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user devices
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserDevices({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedDevices();
        if (cached != null) {
          return ApiResponse<List<Map<String, dynamic>>>(
            success: true,
            data: cached,
            message: 'User devices loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.userPrefix}/devices',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheDevices(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch user devices');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Remove user device
  Future<ApiResponse<void>> removeDevice(String deviceId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.userPrefix}/devices/$deviceId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear devices cache
        await _clearDevicesCache();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to remove device');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Register current device
  Future<ApiResponse<Map<String, dynamic>>> registerDevice() async {
    try {
      final deviceInfo = await DeviceService.getFullDeviceInfo();

      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.userPrefix}/devices/register',
        data: deviceInfo,
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        // Clear devices cache
        await _clearDevicesCache();

        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to register device');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get security activity logs
  Future<ApiResponse<List<Map<String, dynamic>>>> getSecurityLogs({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeySecurityLogs}_${page}_$limit';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedSecurityLogs(cacheKey);
        if (cached != null) {
          return ApiResponse<List<Map<String, dynamic>>>(
            success: true,
            data: cached,
            message: 'Security logs loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.userPrefix}/security/logs',
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );

        // Cache first page
        if (page == 1 && apiResponse.success && apiResponse.data != null) {
          await _cacheSecurityLogs(cacheKey, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch security logs');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Delete user account
  Future<ApiResponse<void>> deleteAccount({
    required String password,
    required String reason,
  }) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.userPrefix}/delete',
        data: {'password': password, 'reason': reason},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear all user-related cache and storage
        await _clearAllCache();
        await StorageService.clearAuthData();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to delete account');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get user account status and verification info
  Future<ApiResponse<Map<String, dynamic>>> getAccountStatus() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.userPrefix}/status',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch account status');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Request email verification
  Future<ApiResponse<void>> requestEmailVerification() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.resendVerification,
        data: {},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to send verification email');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Verify email with token
  Future<ApiResponse<void>> verifyEmail(String token) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.verifyEmail,
        data: {'token': token},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear profile cache to reflect email verification status
        await _clearProfileCache();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to verify email');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cacheDashboard(Map<String, dynamic> dashboard) async {
    await StorageService.setCachedData(_cacheKeyDashboard, {
      'data': dashboard,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedDashboard() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyDashboard,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheProfile(UserModel user) async {
    await StorageService.setCachedData(_cacheKeyProfile, {
      'data': user.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _cacheUserSummary(Map<String, dynamic> summary) async {
    await StorageService.setCachedData(_cacheKeyUserSummary, {
      'data': summary,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedUserSummary() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyUserSummary,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> _getCachedProfile() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyProfile,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return UserModel.fromJson(cached['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cachePreferences(Map<String, dynamic> preferences) async {
    await StorageService.setCachedData(_cacheKeyPreferences, {
      'data': preferences,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedPreferences() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyPreferences,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheDevices(List<Map<String, dynamic>> devices) async {
    await StorageService.setCachedData(_cacheKeyDevices, {
      'data': devices,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>?> _getCachedDevices() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyDevices,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return (cached['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheSecurityLogs(
    String key,
    List<Map<String, dynamic>> logs,
  ) async {
    await StorageService.setCachedData(key, {
      'data': logs,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>?> _getCachedSecurityLogs(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return (cached['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getCachedUser() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyProfile,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return UserModel.fromJson(cached['data'] as Map<String, dynamic>);
      }

      // Fallback to stored user if cache is empty
      return await StorageService.getUser();
    } catch (e) {
      // Fallback to stored user on error
      try {
        return await StorageService.getUser();
      } catch (e) {
        return null;
      }
    }
  }

  /// Get cached dashboard data without making API call
  Future<Map<String, dynamic>?> getCachedDashboard() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyDashboard,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached user summary without making API call
  Future<Map<String, dynamic>?> getCachedUserSummary() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyUserSummary,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached user preferences without making API call
  Future<Map<String, dynamic>?> getCachedUserPreferences() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyPreferences,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user data is cached and valid
  Future<bool> isUserDataCached() async {
    try {
      final user = await getCachedUser();
      final dashboard = await getCachedDashboard();
      return user != null && dashboard != null;
    } catch (e) {
      return false;
    }
  }

  /// Clear specific cache methods
  Future<void> _clearDashboardCache() async {
    await StorageService.removeCachedData(_cacheKeyDashboard);
  }

  Future<void> _clearProfileCache() async {
    await StorageService.removeCachedData(_cacheKeyProfile);
  }

  Future<void> _clearDevicesCache() async {
    await StorageService.removeCachedData(_cacheKeyDevices);
  }

  Future<void> clearUserCache() async {
    try {
      await Future.wait([
        StorageService.removeCachedData(_cacheKeyDashboard),
        StorageService.removeCachedData(_cacheKeyProfile),
        StorageService.removeCachedData(_cacheKeyPreferences),
        StorageService.removeCachedData(_cacheKeyDevices),
        StorageService.removeCachedData(_cacheKeyUserSummary),
      ]);

      // Clear security logs cache by pattern
      final cacheInfo = await StorageService.getCacheInfo();
      final securityLogKeys = (cacheInfo['keys'] as List)
          .where((key) => key.toString().startsWith(_cacheKeySecurityLogs))
          .toList();

      for (final key in securityLogKeys) {
        await StorageService.removeCachedData(key.toString());
      }
    } catch (e) {
      // Handle cache clearing error silently
    }
  }

  /// Clear all user-related cache
  Future<void> _clearAllCache() async {
    await Future.wait([
      StorageService.removeCachedData(_cacheKeyDashboard),
      StorageService.removeCachedData(_cacheKeyProfile),
      StorageService.removeCachedData(_cacheKeyPreferences),
      StorageService.removeCachedData(_cacheKeyDevices),
      StorageService.removeCachedData('security_logs'),
    ]);
  }
}
