import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/notifications/notification_model.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(ref.read(apiServiceProvider));
});

class NotificationsRepository {
  final ApiService _apiService;
  static const String _notificationsCacheKey = 'notifications_data';
  static const String _unreadCountCacheKey = 'unread_notifications_count';

  NotificationsRepository(this._apiService);

  Future<PaginatedResponse<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String type = 'all',
    String read = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'type': type,
        'read': read,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse = PaginatedResponse<NotificationModel>.fromJson(
          response.data!,
          (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache notifications data locally (first page only)
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _notificationsCacheKey,
            paginatedResponse.data
                .map((notification) => notification.toJson())
                .toList(),
          );

          // Update unread count cache
          final unreadCount = paginatedResponse.data
              .where((notification) => !notification.read)
              .length;
          await StorageService.setCachedData(_unreadCountCacheKey, unreadCount);
        }

        return paginatedResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(
          _notificationsCacheKey,
        );
        if (cachedData != null) {
          final notifications = (cachedData as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList();

          return PaginatedResponse<NotificationModel>(
            success: true,
            data: notifications,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: notifications.length,
              itemsPerPage: notifications.length,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
            timestamp: DateTime.now(),
          );
        }
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<NotificationModel>> getNotificationById(
    String notificationId,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.notifications}/$notificationId',
      );

      if (response.data != null) {
        return ApiResponse<NotificationModel>.fromJson(
          response.data!,
          (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${ApiConstants.notifications}/$notificationId/read',
      );

      if (response.data != null) {
        // Update cached notifications
        await _updateCachedNotificationStatus(notificationId, true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> markAsUnread(String notificationId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${ApiConstants.notifications}/$notificationId/unread',
      );

      if (response.data != null) {
        // Update cached notifications
        await _updateCachedNotificationStatus(notificationId, false);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${ApiConstants.notifications}/mark-all-read',
      );

      if (response.data != null) {
        // Update all cached notifications as read
        await _markAllCachedNotificationsAsRead();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConstants.notifications}/$notificationId',
      );

      if (response.data != null) {
        // Remove from cached notifications
        await _removeCachedNotification(notificationId);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> clearAllNotifications() async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConstants.notifications}/clear-all',
      );

      if (response.data != null) {
        // Clear cached notifications
        await clearNotificationsCache();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> registerDeviceToken(FCMTokenRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.registerDevice,
        data: request.toJson(),
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

  Future<ApiResponse<void>> unregisterDeviceToken(String deviceId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConstants.registerDevice}/$deviceId',
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

  Future<ApiResponse<Map<String, dynamic>>> getNotificationSettings() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/notifications/settings',
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

  Future<ApiResponse<void>> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/api/users/notifications/settings',
        data: settings,
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

  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.notifications}/unread-count',
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<int>.fromJson(
          response.data!,
          (json) => json as int,
        );

        // Cache unread count
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _unreadCountCacheKey,
            apiResponse.data!,
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Return cached unread count if available
      final cachedCount = await StorageService.getCachedData(
        _unreadCountCacheKey,
      );
      if (cachedCount != null) {
        return ApiResponse<int>(
          success: true,
          data: cachedCount as int,
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  // Helper methods for cache management
  Future<void> _updateCachedNotificationStatus(
    String notificationId,
    bool read,
  ) async {
    try {
      final cachedData = await StorageService.getCachedData(
        _notificationsCacheKey,
      );
      if (cachedData != null) {
        final notifications = (cachedData as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Create updated notification
          final updatedNotification = NotificationModel(
            id: notifications[index].id,
            title: notifications[index].title,
            message: notifications[index].message,
            type: notifications[index].type,
            read: read,
            createdAt: notifications[index].createdAt,
            data: notifications[index].data,
            imageUrl: notifications[index].imageUrl,
            actionUrl: notifications[index].actionUrl,
          );

          notifications[index] = updatedNotification;

          await StorageService.setCachedData(
            _notificationsCacheKey,
            notifications.map((n) => n.toJson()).toList(),
          );

          // Update unread count
          final unreadCount = notifications.where((n) => !n.read).length;
          await StorageService.setCachedData(_unreadCountCacheKey, unreadCount);
        }
      }
    } catch (e) {
      // Ignore cache update errors
    }
  }

  Future<void> _markAllCachedNotificationsAsRead() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _notificationsCacheKey,
      );
      if (cachedData != null) {
        final notifications = (cachedData as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        final updatedNotifications = notifications
            .map(
              (notification) => NotificationModel(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                type: notification.type,
                read: true,
                createdAt: notification.createdAt,
                data: notification.data,
                imageUrl: notification.imageUrl,
                actionUrl: notification.actionUrl,
              ),
            )
            .toList();

        await StorageService.setCachedData(
          _notificationsCacheKey,
          updatedNotifications.map((n) => n.toJson()).toList(),
        );

        // Set unread count to 0
        await StorageService.setCachedData(_unreadCountCacheKey, 0);
      }
    } catch (e) {
      // Ignore cache update errors
    }
  }

  Future<void> _removeCachedNotification(String notificationId) async {
    try {
      final cachedData = await StorageService.getCachedData(
        _notificationsCacheKey,
      );
      if (cachedData != null) {
        final notifications = (cachedData as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        notifications.removeWhere((n) => n.id == notificationId);

        await StorageService.setCachedData(
          _notificationsCacheKey,
          notifications.map((n) => n.toJson()).toList(),
        );

        // Update unread count
        final unreadCount = notifications.where((n) => !n.read).length;
        await StorageService.setCachedData(_unreadCountCacheKey, unreadCount);
      }
    } catch (e) {
      // Ignore cache update errors
    }
  }

  Future<List<NotificationModel>?> getCachedNotifications() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _notificationsCacheKey,
      );
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int> getCachedUnreadCount() async {
    try {
      final cachedCount = await StorageService.getCachedData(
        _unreadCountCacheKey,
      );
      return cachedCount as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> clearNotificationsCache() async {
    await StorageService.removeCachedData(_notificationsCacheKey);
    await StorageService.removeCachedData(_unreadCountCacheKey);
  }
}
