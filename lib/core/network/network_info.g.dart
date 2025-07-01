// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$networkInfoHash() => r'9288ad3ae376b3ac5792b2cd03e767a1a94ba6d2';

/// Riverpod provider for NetworkInfo
///
/// Copied from [networkInfo].
@ProviderFor(networkInfo)
final networkInfoProvider = AutoDisposeProvider<NetworkInfo>.internal(
  networkInfo,
  name: r'networkInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkInfoRef = AutoDisposeProviderRef<NetworkInfo>;
String _$networkStatusStreamHash() =>
    r'6d1554384ed615f760cb9b2bef2ea1a36291f6ff';

/// Riverpod provider for network status stream
///
/// Copied from [networkStatusStream].
@ProviderFor(networkStatusStream)
final networkStatusStreamProvider =
    AutoDisposeStreamProvider<NetworkDetails>.internal(
      networkStatusStream,
      name: r'networkStatusStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$networkStatusStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkStatusStreamRef = AutoDisposeStreamProviderRef<NetworkDetails>;
String _$networkStatusHash() => r'5b4cab5d760d033927c5ecd1639de9aee95bb745';

/// Riverpod provider for current network status
///
/// Copied from [NetworkStatus].
@ProviderFor(NetworkStatus)
final networkStatusProvider =
    AutoDisposeAsyncNotifierProvider<NetworkStatus, NetworkDetails>.internal(
      NetworkStatus.new,
      name: r'networkStatusProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$networkStatusHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NetworkStatus = AutoDisposeAsyncNotifier<NetworkDetails>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
