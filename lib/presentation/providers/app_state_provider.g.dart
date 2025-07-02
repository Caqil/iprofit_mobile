// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appStateHash() => r'd8da2ab06d6bfd28a1c35ddbc746b0b09017e395';

/// Convenience provider for app state
///
/// Copied from [appState].
@ProviderFor(appState)
final appStateProvider = AutoDisposeProvider<AppState>.internal(
  appState,
  name: r'appStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppStateRef = AutoDisposeProviderRef<AppState>;
String _$isAppReadyHash() => r'd82845ac796e4f796fe9d344e9772f10fb7324e6';

/// Provider for checking if app is ready
///
/// Copied from [isAppReady].
@ProviderFor(isAppReady)
final isAppReadyProvider = AutoDisposeProvider<bool>.internal(
  isAppReady,
  name: r'isAppReadyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAppReadyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAppReadyRef = AutoDisposeProviderRef<bool>;
String _$themeModeHash() => r'355f605e1495b00c9f721173cd79a2b4d80e1ac7';

/// Provider for current theme mode
///
/// Copied from [themeMode].
@ProviderFor(themeMode)
final themeModeProvider = AutoDisposeProvider<ThemeMode>.internal(
  themeMode,
  name: r'themeModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeModeRef = AutoDisposeProviderRef<ThemeMode>;
String _$isAuthenticatedHash() => r'cd2ea51a73d46d943f769b5398b2bf1f9a5b6be9';

/// Provider for authentication status
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$currentUserHash() => r'940d680a43de2f604c1d3b16a8e6912b67b997f9';

/// Provider for current user
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<UserModel?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<UserModel?>;
String _$isOnlineHash() => r'8d42b40049693e43fdd30fa24575e657b0916c70';

/// Provider for connectivity status
///
/// Copied from [isOnline].
@ProviderFor(isOnline)
final isOnlineProvider = AutoDisposeProvider<bool>.internal(
  isOnline,
  name: r'isOnlineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isOnlineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsOnlineRef = AutoDisposeProviderRef<bool>;
String _$appErrorHash() => r'a3ace484b59f27d259eee67e1efec23451718ca3';

/// Provider for error state
///
/// Copied from [appError].
@ProviderFor(appError)
final appErrorProvider = AutoDisposeProvider<AppError?>.internal(
  appError,
  name: r'appErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppErrorRef = AutoDisposeProviderRef<AppError?>;
String _$appStateNotifierHash() => r'b1aea7085b65d06efd9406e61656a19f1a37581e';

/// See also [AppStateNotifier].
@ProviderFor(AppStateNotifier)
final appStateNotifierProvider =
    AutoDisposeNotifierProvider<AppStateNotifier, AppState>.internal(
      AppStateNotifier.new,
      name: r'appStateNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appStateNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppStateNotifier = AutoDisposeNotifier<AppState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
