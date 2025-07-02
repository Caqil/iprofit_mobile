// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationsHash() =>
    r'2aabcd2afdc8a67ab804b23a6d4adc158054929f';

/// Provider for unread notifications
///
/// Copied from [unreadNotifications].
@ProviderFor(unreadNotifications)
final unreadNotificationsProvider =
    AutoDisposeProvider<List<NotificationModel>>.internal(
      unreadNotifications,
      name: r'unreadNotificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationsRef =
    AutoDisposeProviderRef<List<NotificationModel>>;
String _$unreadNotificationsCountHash() =>
    r'4df0345e9b4b4c9ee7f68b52f381dcce10cf452e';

/// Provider for unread count
///
/// Copied from [unreadNotificationsCount].
@ProviderFor(unreadNotificationsCount)
final unreadNotificationsCountProvider = AutoDisposeProvider<int>.internal(
  unreadNotificationsCount,
  name: r'unreadNotificationsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationsCountRef = AutoDisposeProviderRef<int>;
String _$importantNotificationsHash() =>
    r'bb22b1276a1f5ce263a7e8a11bd5ea0f0ed4133a';

/// Provider for important notifications
///
/// Copied from [importantNotifications].
@ProviderFor(importantNotifications)
final importantNotificationsProvider =
    AutoDisposeProvider<List<NotificationModel>>.internal(
      importantNotifications,
      name: r'importantNotificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$importantNotificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImportantNotificationsRef =
    AutoDisposeProviderRef<List<NotificationModel>>;
String _$isNotificationsLoadingHash() =>
    r'7e99617e9cb722d576a27caeef19f803cbe4b3b2';

/// Provider for notifications loading state
///
/// Copied from [isNotificationsLoading].
@ProviderFor(isNotificationsLoading)
final isNotificationsLoadingProvider = AutoDisposeProvider<bool>.internal(
  isNotificationsLoading,
  name: r'isNotificationsLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isNotificationsLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsNotificationsLoadingRef = AutoDisposeProviderRef<bool>;
String _$notificationsErrorHash() =>
    r'4f4ea0b76f434adee7eb756793914d408afc31b5';

/// Provider for notifications error
///
/// Copied from [notificationsError].
@ProviderFor(notificationsError)
final notificationsErrorProvider = AutoDisposeProvider<String?>.internal(
  notificationsError,
  name: r'notificationsErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsErrorRef = AutoDisposeProviderRef<String?>;
String _$areNotificationsEnabledHash() =>
    r'95723327ece6880f6378efa09c1d6008999017fb';

/// Provider for notification settings status
///
/// Copied from [areNotificationsEnabled].
@ProviderFor(areNotificationsEnabled)
final areNotificationsEnabledProvider = AutoDisposeProvider<bool>.internal(
  areNotificationsEnabled,
  name: r'areNotificationsEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$areNotificationsEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AreNotificationsEnabledRef = AutoDisposeProviderRef<bool>;
String _$hasUnreadNotificationsHash() =>
    r'0ac8278bbe13236cac440f227e990a63752bdb69';

/// Provider for checking if there are unread notifications
///
/// Copied from [hasUnreadNotifications].
@ProviderFor(hasUnreadNotifications)
final hasUnreadNotificationsProvider = AutoDisposeProvider<bool>.internal(
  hasUnreadNotifications,
  name: r'hasUnreadNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasUnreadNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasUnreadNotificationsRef = AutoDisposeProviderRef<bool>;
String _$notificationsHash() => r'65431cfa2e2feb1ea7f7159f79b4b333a12cc9e2';

/// See also [Notifications].
@ProviderFor(Notifications)
final notificationsProvider =
    AutoDisposeNotifierProvider<Notifications, NotificationsState>.internal(
      Notifications.new,
      name: r'notificationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Notifications = AutoDisposeNotifier<NotificationsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
