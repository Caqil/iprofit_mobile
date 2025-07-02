// lib/presentation/providers/notifications_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/models/notifications/notification_model.dart';
import '../../data/models/common/pagination.dart';
import '../../data/services/device_service.dart';

part 'notifications_provider.g.dart';

// ============================================================================
// NOTIFICATIONS STATE MODEL
// ============================================================================

/// Notifications provider state model
class NotificationsState {
  final List<NotificationModel> notifications;
  final Pagination? pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool isMarkingAsRead;
  final bool isDeleting;
  final int unreadCount;
  final String currentFilter;
  final String currentType;
  final bool areNotificationsEnabled;
  final String? lastUpdated;

  const NotificationsState({
    this.notifications = const [],
    this.pagination,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.isMarkingAsRead = false,
    this.isDeleting = false,
    this.unreadCount = 0,
    this.currentFilter = 'all',
    this.currentType = 'all',
    this.areNotificationsEnabled = true,
    this.lastUpdated,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    Pagination? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? isMarkingAsRead,
    bool? isDeleting,
    int? unreadCount,
    String? currentFilter,
    String? currentType,
    bool? areNotificationsEnabled,
    String? lastUpdated,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      isMarkingAsRead: isMarkingAsRead ?? this.isMarkingAsRead,
      isDeleting: isDeleting ?? this.isDeleting,
      unreadCount: unreadCount ?? this.unreadCount,
      currentFilter: currentFilter ?? this.currentFilter,
      currentType: currentType ?? this.currentType,
      areNotificationsEnabled:
          areNotificationsEnabled ?? this.areNotificationsEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasNotifications => notifications.isNotEmpty;
  bool get hasMorePages => pagination?.hasNextPage ?? false;
  bool get hasUnreadNotifications => unreadCount > 0;
  int get totalNotifications => pagination?.totalItems ?? notifications.length;

  // Notification categories
  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.read).toList();
  List<NotificationModel> get readNotifications =>
      notifications.where((n) => n.read).toList();
  List<NotificationModel> get importantNotifications => notifications
      .where((n) => n.type == 'security' || n.type == 'kyc')
      .toList();
  List<NotificationModel> get systemNotifications =>
      notifications.where((n) => n.type == 'system').toList();
  List<NotificationModel> get transactionNotifications =>
      notifications.where((n) => n.type == 'transaction').toList();
  List<NotificationModel> get promotionalNotifications =>
      notifications.where((n) => n.type == 'promotional').toList();
}

// ============================================================================
// NOTIFICATIONS PROVIDER
// ============================================================================

@riverpod
class Notifications extends _$Notifications {
  Timer? _refreshTimer;

  @override
  NotificationsState build() {
    // Initialize notifications data on provider creation
    _initializeNotifications();

    // Set up auto-refresh for notifications
    _setupAutoRefresh();

    // Clean up when provider is disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return const NotificationsState();
  }

  // ===== INITIALIZATION =====

  /// Initialize notifications data
  Future<void> _initializeNotifications() async {
    await loadNotifications();
    await loadUnreadCount();
  }

  /// Setup auto-refresh for notifications
  void _setupAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (_) {
     loadUnreadCount(); 
    });
  }

  // ===== NOTIFICATIONS MANAGEMENT =====

  /// Load notifications with optional filtering
  Future<void> loadNotifications({
    int page = 1,
    String type = 'all',
    String read = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoading: true,
          error: null,
          currentType: type,
          currentFilter: read,
        );
      } else {
        state = state.copyWith(isLoadingMore: true, error: null);
      }

      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.getNotifications(
        page: page,
        type: type,
        read: read,
        sortBy: sortBy,
        sortOrder: sortOrder,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<NotificationModel> updatedNotifications;

        if (page == 1) {
          updatedNotifications = response.data;
        } else {
          updatedNotifications = [...state.notifications, ...response.data];
        }

        state = state.copyWith(
          notifications: updatedNotifications,
          pagination: response.pagination,
          isLoading: false,
          isLoadingMore: false,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    final nextPage = (state.pagination?.currentPage ?? 0) + 1;
    await loadNotifications(
      page: nextPage,
      type: state.currentType,
      read: state.currentFilter,
    );
  }

  /// Refresh notifications list
  Future<void> refreshNotifications() async {
    await loadNotifications(
      type: state.currentType,
      read: state.currentFilter,
      forceRefresh: true,
    );
    await loadUnreadCount();
  }

  /// Filter notifications by type
  Future<void> filterByType(String type) async {
    if (state.currentType == type) return;

    await loadNotifications(type: type, read: state.currentFilter);
  }

  /// Filter notifications by read status
  Future<void> filterByReadStatus(String read) async {
    if (state.currentFilter == read) return;

    await loadNotifications(type: state.currentType, read: read);
  }

  // ===== NOTIFICATION ACTIONS =====

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      state = state.copyWith(isMarkingAsRead: true, error: null);

      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.markAsRead(notificationId);

      if (response.success) {
        // Update notification in local list
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              read: true, // Mark as read
              createdAt: notification.createdAt,
              data: notification.data,
              imageUrl: notification.imageUrl,
              actionUrl: notification.actionUrl,
            );
          }
          return notification;
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          isMarkingAsRead: false,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        );

        return true;
      } else {
        state = state.copyWith(
          isMarkingAsRead: false,
          error: response.message ?? 'Failed to mark notification as read',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isMarkingAsRead: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      state = state.copyWith(isMarkingAsRead: true, error: null);

      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.markAllAsRead();

      if (response.success) {
        // Update all notifications as read
        final updatedNotifications = state.notifications.map((notification) {
          return NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            read: true, // Mark as read
            createdAt: notification.createdAt,
            data: notification.data,
            imageUrl: notification.imageUrl,
            actionUrl: notification.actionUrl,
          );
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          isMarkingAsRead: false,
          unreadCount: 0,
        );

        return true;
      } else {
        state = state.copyWith(
          isMarkingAsRead: false,
          error: response.message ?? 'Failed to mark all notifications as read',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isMarkingAsRead: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.deleteNotification(
        notificationId,
      );

      if (response.success) {
        // Remove notification from local list
        final notification = state.notifications.firstWhere(
          (n) => n.id == notificationId,
        );
        final updatedNotifications = state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        final newUnreadCount = !notification.read && state.unreadCount > 0
            ? state.unreadCount - 1
            : state.unreadCount;

        state = state.copyWith(
          notifications: updatedNotifications,
          isDeleting: false,
          unreadCount: newUnreadCount,
        );

        return true;
      } else {
        state = state.copyWith(
          isDeleting: false,
          error: response.message ?? 'Failed to delete notification',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: _getErrorMessage(e));
      return false;
    }
  }

  /// Clear all notifications
  Future<bool> clearAllNotifications() async {
    try {
      state = state.copyWith(isDeleting: true, error: null);

      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.clearAllNotifications();

      if (response.success) {
        state = state.copyWith(
          notifications: [],
          isDeleting: false,
          unreadCount: 0,
          pagination: null,
        );

        return true;
      } else {
        state = state.copyWith(
          isDeleting: false,
          error: response.message ?? 'Failed to clear notifications',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isDeleting: false, error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== NOTIFICATION SETTINGS =====

  /// Update notification settings
  Future<bool> updateNotificationSettings({
    required bool enabled,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    List<String>? enabledTypes,
  }) async {
    try {
      final settings = <String, dynamic>{
        'enabled': enabled,
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (emailEnabled != null) 'emailEnabled': emailEnabled,
        if (smsEnabled != null) 'smsEnabled': smsEnabled,
        if (enabledTypes != null) 'enabledTypes': enabledTypes,
      };

      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.updateNotificationSettings(
        settings,
      );

      if (response.success) {
        state = state.copyWith(areNotificationsEnabled: enabled);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to update notification settings',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== UNREAD COUNT =====

  /// Load unread notifications count
  Future<void> loadUnreadCount() async {
    try {
      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.getUnreadCount();

      if (response.success && response.data != null) {
        state = state.copyWith(unreadCount: response.data ?? 0);
      }
    } catch (e) {
      // Silent fail for unread count
    }
  }

  // ===== FCM TOKEN MANAGEMENT =====

  /// Update FCM token
  Future<bool> updateFcmToken(String token) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final deviceInfo = await DeviceService.getFullDeviceInfo();

      final request = FCMTokenRequest(
        fcmToken: token,
        deviceId: deviceId,
        platform: Platform.isAndroid ? 'android' : 'ios',
        appVersion: deviceInfo['appVersion'] as String?,
        osVersion: deviceInfo['osVersion'] as String?,
        deviceModel: deviceInfo['model'] as String?,
        deviceBrand: deviceInfo['brand'] as String?,
      );

      final notificationsRepository = ref.read(notificationsRepositoryProvider);
      final response = await notificationsRepository.registerDeviceToken(
        request,
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  // ===== UTILITY METHODS =====

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return error.toString();
  }

  /// Get notification by ID
  NotificationModel? getNotificationById(String notificationId) {
    try {
      return state.notifications.firstWhere((n) => n.id == notificationId);
    } catch (e) {
      return null;
    }
  }

  /// Add new notification (for real-time updates)
  void addNotification(NotificationModel notification) {
    final updatedNotifications = [notification, ...state.notifications];
    final newUnreadCount = !notification.read
        ? state.unreadCount + 1
        : state.unreadCount;

    state = state.copyWith(
      notifications: updatedNotifications,
      unreadCount: newUnreadCount,
    );
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return state.notifications.where((n) => n.type == type).toList();
  }

  /// Force refresh all notifications data
  Future<void> refresh() async {
    await refreshNotifications();
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for unread notifications
@riverpod
List<NotificationModel> unreadNotifications(Ref ref) {
  return ref.watch(
    notificationsProvider.select((state) => state.unreadNotifications),
  );
}

/// Provider for unread count
@riverpod
int unreadNotificationsCount(Ref ref) {
  return ref.watch(notificationsProvider.select((state) => state.unreadCount));
}

/// Provider for important notifications
@riverpod
List<NotificationModel> importantNotifications(Ref ref) {
  return ref.watch(
    notificationsProvider.select((state) => state.importantNotifications),
  );
}

/// Provider for notifications loading state
@riverpod
bool isNotificationsLoading(Ref ref) {
  return ref.watch(notificationsProvider.select((state) => state.isLoading));
}

/// Provider for notifications error
@riverpod
String? notificationsError(Ref ref) {
  return ref.watch(notificationsProvider.select((state) => state.error));
}

/// Provider for notification settings status
@riverpod
bool areNotificationsEnabled(Ref ref) {
  return ref.watch(
    notificationsProvider.select((state) => state.areNotificationsEnabled),
  );
}

/// Provider for checking if there are unread notifications
@riverpod
bool hasUnreadNotifications(Ref ref) {
  return ref.watch(
    notificationsProvider.select((state) => state.hasUnreadNotifications),
  );
}
