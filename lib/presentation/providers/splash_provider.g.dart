// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$splashStatusHash() => r'1c7afac115e420f75863bf434963e3be4effca61';

/// Provider for splash status
///
/// Copied from [splashStatus].
@ProviderFor(splashStatus)
final splashStatusProvider = AutoDisposeProvider<SplashStatus>.internal(
  splashStatus,
  name: r'splashStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashStatusRef = AutoDisposeProviderRef<SplashStatus>;
String _$splashProgressHash() => r'd8959816cd153ba7014f3f771c8abc05f4c8e871';

/// Provider for splash progress
///
/// Copied from [splashProgress].
@ProviderFor(splashProgress)
final splashProgressProvider = AutoDisposeProvider<double>.internal(
  splashProgress,
  name: r'splashProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashProgressRef = AutoDisposeProviderRef<double>;
String _$splashMessageHash() => r'171e8fad1ed8b3e221d2514a1bb2f7c5b8dae40d';

/// Provider for splash message
///
/// Copied from [splashMessage].
@ProviderFor(splashMessage)
final splashMessageProvider = AutoDisposeProvider<String>.internal(
  splashMessage,
  name: r'splashMessageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashMessageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashMessageRef = AutoDisposeProviderRef<String>;
String _$isSplashCompletedHash() => r'0ffb606de91c564aacab08be6a95be874c309e28';

/// Provider for checking if splash is completed
///
/// Copied from [isSplashCompleted].
@ProviderFor(isSplashCompleted)
final isSplashCompletedProvider = AutoDisposeProvider<bool>.internal(
  isSplashCompleted,
  name: r'isSplashCompletedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSplashCompletedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSplashCompletedRef = AutoDisposeProviderRef<bool>;
String _$splashErrorHash() => r'70b0eff18b301efe8ecbc413b01976bb2a7afb4e';

/// Provider for splash error
///
/// Copied from [splashError].
@ProviderFor(splashError)
final splashErrorProvider = AutoDisposeProvider<String?>.internal(
  splashError,
  name: r'splashErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$splashErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SplashErrorRef = AutoDisposeProviderRef<String?>;
String _$isFirstLaunchHash() => r'3358daf9a4181bb9faaf7cea384c4e639f934a0a';

/// Provider for first launch status
///
/// Copied from [isFirstLaunch].
@ProviderFor(isFirstLaunch)
final isFirstLaunchProvider = AutoDisposeProvider<bool>.internal(
  isFirstLaunch,
  name: r'isFirstLaunchProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isFirstLaunchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsFirstLaunchRef = AutoDisposeProviderRef<bool>;
String _$needsOnboardingHash() => r'4d5df4b90c418bde86b2ffa47420039758b9a58a';

/// Provider for onboarding requirement
///
/// Copied from [needsOnboarding].
@ProviderFor(needsOnboarding)
final needsOnboardingProvider = AutoDisposeProvider<bool>.internal(
  needsOnboarding,
  name: r'needsOnboardingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$needsOnboardingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NeedsOnboardingRef = AutoDisposeProviderRef<bool>;
String _$nextRouteHash() => r'30d98da546fc55d972fe6e5ba9446340acf10868';

/// Provider for next route
///
/// Copied from [nextRoute].
@ProviderFor(nextRoute)
final nextRouteProvider = AutoDisposeProvider<String>.internal(
  nextRoute,
  name: r'nextRouteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextRouteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextRouteRef = AutoDisposeProviderRef<String>;
String _$hasInternetConnectionHash() =>
    r'ebb9a7398bf63a8c91c2a0181c9920cc00d7325f';

/// Provider for internet connectivity status
///
/// Copied from [hasInternetConnection].
@ProviderFor(hasInternetConnection)
final hasInternetConnectionProvider = AutoDisposeProvider<bool>.internal(
  hasInternetConnection,
  name: r'hasInternetConnectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasInternetConnectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasInternetConnectionRef = AutoDisposeProviderRef<bool>;
String _$splashHash() => r'3c0646e9363119964b0d4dfab217c65b4ab0eba3';

/// See also [Splash].
@ProviderFor(Splash)
final splashProvider =
    AutoDisposeNotifierProvider<Splash, SplashState>.internal(
      Splash.new,
      name: r'splashProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$splashHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Splash = AutoDisposeNotifier<SplashState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
