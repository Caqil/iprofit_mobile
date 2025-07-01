import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/notifications/notification_model.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/storage_service.dart';
import '../services/device_service.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(ref.read(apiClientProvider));
});

class NotificationsRepository {
  final ApiClient _apiClient;
  static const String _cacheKey = 'notifications';
  static const String _unreadCountKey = 'unread_notifications_count';
  static const Duration _cacheExpiry = Duration(minutes: 10);

  NotificationsRepository(this._apiClient);

  /// Get notifications with pagination
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
      final cacheKey = '${_cacheKey}_${page}_${limit}_${type}_$read';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedNotifications(cacheKey);
        if (cached != null) {
          return cached;
        }
      }

      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
        ApiConstants.sortByParam: sortBy,
        ApiConstants.sortOrderParam: sortOrder,
      };

      if (type != 'all') {
        queryParams[ApiConstants.typeParam] = type;
      }

      if (read != 'all') {
        queryParams['read'] = read == 'read';
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          ApiConstants.notifications,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse = PaginatedResponse<NotificationModel>.fromJson(
          response.data!,
          (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheNotifications(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch notifications');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Mark notification as read
  Future<ApiResponse<void>> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.notificationRead}/$notificationId/read',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Update cache to reflect read status
        await _updateNotificationReadStatus(notificationId, true);
        await _decrementUnreadCount();

        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to mark notification as read');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.notificationMarkAllRead,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear cache to refresh data
        await _clearNotificationsCache();
        await _updateUnreadCount(0);

        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError(
        'Failed to mark all notifications as read',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get unread notifications count
  Future<ApiResponse<int>> getUnreadCount({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedUnreadCount();
        if (cached != null) {
          return ApiResponse<int>(
            success: true,
            data: cached,
            message: 'Unread count loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.notifications}/unread-count',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<int>.fromJson(
          response.data!,
          (json) => json as int,
        );

        // Cache the count
        if (apiResponse.success && apiResponse.data != null) {
          await _updateUnreadCount(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch unread count');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Register FCM device token
  Future<ApiResponse<void>> registerDeviceToken(FCMTokenRequest request) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.registerDevice,
        data: request.toJson(),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to register device token');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Unregister FCM device token
  Future<ApiResponse<void>> unregisterDeviceToken() async {
    try {
      final deviceId = await DeviceService.getDeviceId();

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.unregisterDevice}/$deviceId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to unregister device token');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Update notification settings/preferences
  Future<ApiResponse<void>> updateNotificationSettings(
    Map<String, dynamic> settings,
  ) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiConstants.notificationSettings,
        data: settings,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to update notification settings');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get notification settings
  Future<ApiResponse<Map<String, dynamic>>> getNotificationSettings() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.notificationSettings,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch notification settings');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Delete notification
  Future<ApiResponse<void>> deleteNotification(String notificationId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.notifications}/$notificationId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Remove from cache
        await _removeNotificationFromCache(notificationId);

        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to delete notification');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Clear all notifications
  Future<ApiResponse<void>> clearAllNotifications() async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.notifications}/clear-all',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear cache
        await _clearNotificationsCache();
        await _updateUnreadCount(0);

        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to clear all notifications');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get notification by ID
  Future<ApiResponse<NotificationModel>> getNotification(
    String notificationId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.notifications}/$notificationId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<NotificationModel>.fromJson(
          response.data!,
          (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw AppException.serverError('Failed to fetch notification');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Test notification (for development/testing)
  Future<ApiResponse<void>> sendTestNotification({
    required String title,
    required String message,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.notifications}/test',
        data: {
          'title': title,
          'message': message,
          'type': type,
          if (data != null) 'data': data,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to send test notification');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cacheNotifications(
    String key,
    PaginatedResponse<NotificationModel> notifications,
  ) async {
    await StorageService.setCachedData(key, {
      'data': notifications.toJson((notification) => notification.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<NotificationModel>?> _getCachedNotifications(
    String key,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<NotificationModel>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateUnreadCount(int count) async {
    await StorageService.setCachedData(_unreadCountKey, {
      'count': count,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int?> _getCachedUnreadCount() async {
    try {
      final cached = await StorageService.getCachedData(
        _unreadCountKey,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['count'] != null) {
        return cached['count'] as int;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _decrementUnreadCount() async {
    final current = await _getCachedUnreadCount();
    if (current != null && current > 0) {
      await _updateUnreadCount(current - 1);
    }
  }

  Future<void> _updateNotificationReadStatus(
    String notificationId,
    bool isRead,
  ) async {
    // This would update the notification in cache if we implement detailed caching
    // For now, we'll clear the cache to trigger a refresh
    await _clearNotificationsCache();
  }

  Future<void> _removeNotificationFromCache(String notificationId) async {
    // Clear cache to trigger refresh
    await _clearNotificationsCache();
  }

  Future<void> _clearNotificationsCache() async {
    final keys = await StorageService.getCacheInfo();
    final notificationKeys = (keys['keys'] as List)
        .where((key) => key.toString().startsWith(_cacheKey))
        .toList();

    for (final key in notificationKeys) {
      await StorageService.removeCachedData(key.toString());
    }
  }

  /// Clear all notifications cache
  Future<void> clearNotificationsCache() async {
    await _clearNotificationsCache();
    await StorageService.removeCachedData(_unreadCountKey);
  }

  /// Get cached notifications for offline mode
  Future<List<NotificationModel>?> getCachedNotifications() async {
    try {
      final cached = await _getCachedNotifications('${_cacheKey}_1_20_all_all');
      return cached?.data;
    } catch (e) {
      return null;
    }
  }

  /// Check if notification is unread
  bool isNotificationUnread(NotificationModel notification) {
    return !notification.read;
  }

  /// Check if notification has action
  bool hasAction(NotificationModel notification) {
    return notification.actionUrl != null && notification.actionUrl!.isNotEmpty;
  }

  /// Get notification type icon
  String getNotificationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'transaction':
        return 'account_balance_wallet';
      case 'security':
        return 'security';
      case 'kyc':
        return 'verified_user';
      case 'loan':
        return 'payment';
      case 'task':
        return 'assignment';
      case 'referral':
        return 'people';
      case 'system':
        return 'settings';
      case 'marketing':
        return 'campaign';
      default:
        return 'notifications';
    }
  }

  /// Get notification type color
  String getNotificationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'transaction':
        return '#4CAF50'; // Green
      case 'security':
        return '#F44336'; // Red
      case 'kyc':
        return '#2196F3'; // Blue
      case 'loan':
        return '#FF9800'; // Orange
      case 'task':
        return '#9C27B0'; // Purple
      case 'referral':
        return '#00BCD4'; // Cyan
      case 'system':
        return '#607D8B'; // Blue Grey
      case 'marketing':
        return '#E91E63'; // Pink
      default:
        return '#757575'; // Grey
    }
  }

  /// Format notification time
  String formatNotificationTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
