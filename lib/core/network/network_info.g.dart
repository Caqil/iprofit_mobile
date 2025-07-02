// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkInfo _$NetworkInfoFromJson(Map<String, dynamic> json) => NetworkInfo(
  isConnected: json['isConnected'] as bool,
  networkType: $enumDecode(_$NetworkTypeEnumMap, json['networkType']),
  connectionType: json['connectionType'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  isInternetAccessible: json['isInternetAccessible'] as bool? ?? false,
  networkName: json['networkName'] as String?,
  ipAddress: json['ipAddress'] as String?,
  ping: (json['ping'] as num?)?.toInt(),
  signalStrength: (json['signalStrength'] as num?)?.toDouble(),
  additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$NetworkInfoToJson(NetworkInfo instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'networkType': _$NetworkTypeEnumMap[instance.networkType]!,
      'connectionType': instance.connectionType,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'isInternetAccessible': instance.isInternetAccessible,
      'networkName': instance.networkName,
      'ipAddress': instance.ipAddress,
      'ping': instance.ping,
      'signalStrength': instance.signalStrength,
      'additionalInfo': instance.additionalInfo,
    };

const _$NetworkTypeEnumMap = {
  NetworkType.none: 'none',
  NetworkType.wifi: 'wifi',
  NetworkType.mobile: 'mobile',
  NetworkType.ethernet: 'ethernet',
  NetworkType.bluetooth: 'bluetooth',
  NetworkType.vpn: 'vpn',
  NetworkType.other: 'other',
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasInternetAccessHash() => r'b8c89a7131cc4afe3d817d9cbc0f1438a3a06234';

/// See also [hasInternetAccess].
@ProviderFor(hasInternetAccess)
final hasInternetAccessProvider = AutoDisposeFutureProvider<bool>.internal(
  hasInternetAccess,
  name: r'hasInternetAccessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasInternetAccessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasInternetAccessRef = AutoDisposeFutureProviderRef<bool>;
String _$connectivityHistoryHash() =>
    r'58c176a709ea10a0b977166d743a18ab032c53f5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [connectivityHistory].
@ProviderFor(connectivityHistory)
const connectivityHistoryProvider = ConnectivityHistoryFamily();

/// See also [connectivityHistory].
class ConnectivityHistoryFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [connectivityHistory].
  const ConnectivityHistoryFamily();

  /// See also [connectivityHistory].
  ConnectivityHistoryProvider call({
    int limit = 50,
    bool forceRefresh = false,
  }) {
    return ConnectivityHistoryProvider(
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }

  @override
  ConnectivityHistoryProvider getProviderOverride(
    covariant ConnectivityHistoryProvider provider,
  ) {
    return call(limit: provider.limit, forceRefresh: provider.forceRefresh);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'connectivityHistoryProvider';
}

/// See also [connectivityHistory].
class ConnectivityHistoryProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [connectivityHistory].
  ConnectivityHistoryProvider({int limit = 50, bool forceRefresh = false})
    : this._internal(
        (ref) => connectivityHistory(
          ref as ConnectivityHistoryRef,
          limit: limit,
          forceRefresh: forceRefresh,
        ),
        from: connectivityHistoryProvider,
        name: r'connectivityHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$connectivityHistoryHash,
        dependencies: ConnectivityHistoryFamily._dependencies,
        allTransitiveDependencies:
            ConnectivityHistoryFamily._allTransitiveDependencies,
        limit: limit,
        forceRefresh: forceRefresh,
      );

  ConnectivityHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.forceRefresh,
  }) : super.internal();

  final int limit;
  final bool forceRefresh;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
      ConnectivityHistoryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConnectivityHistoryProvider._internal(
        (ref) => create(ref as ConnectivityHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        forceRefresh: forceRefresh,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _ConnectivityHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectivityHistoryProvider &&
        other.limit == limit &&
        other.forceRefresh == forceRefresh;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, forceRefresh.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConnectivityHistoryRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `forceRefresh` of this provider.
  bool get forceRefresh;
}

class _ConnectivityHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with ConnectivityHistoryRef {
  _ConnectivityHistoryProviderElement(super.provider);

  @override
  int get limit => (origin as ConnectivityHistoryProvider).limit;
  @override
  bool get forceRefresh => (origin as ConnectivityHistoryProvider).forceRefresh;
}

String _$networkStatisticsHash() => r'0a5f2f4f1d2ebdfb8cde1eb057d8a95580fbdb51';

/// See also [networkStatistics].
@ProviderFor(networkStatistics)
const networkStatisticsProvider = NetworkStatisticsFamily();

/// See also [networkStatistics].
class NetworkStatisticsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [networkStatistics].
  const NetworkStatisticsFamily();

  /// See also [networkStatistics].
  NetworkStatisticsProvider call({bool forceRefresh = false}) {
    return NetworkStatisticsProvider(forceRefresh: forceRefresh);
  }

  @override
  NetworkStatisticsProvider getProviderOverride(
    covariant NetworkStatisticsProvider provider,
  ) {
    return call(forceRefresh: provider.forceRefresh);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'networkStatisticsProvider';
}

/// See also [networkStatistics].
class NetworkStatisticsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [networkStatistics].
  NetworkStatisticsProvider({bool forceRefresh = false})
    : this._internal(
        (ref) => networkStatistics(
          ref as NetworkStatisticsRef,
          forceRefresh: forceRefresh,
        ),
        from: networkStatisticsProvider,
        name: r'networkStatisticsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$networkStatisticsHash,
        dependencies: NetworkStatisticsFamily._dependencies,
        allTransitiveDependencies:
            NetworkStatisticsFamily._allTransitiveDependencies,
        forceRefresh: forceRefresh,
      );

  NetworkStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.forceRefresh,
  }) : super.internal();

  final bool forceRefresh;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(NetworkStatisticsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NetworkStatisticsProvider._internal(
        (ref) => create(ref as NetworkStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        forceRefresh: forceRefresh,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _NetworkStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NetworkStatisticsProvider &&
        other.forceRefresh == forceRefresh;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, forceRefresh.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NetworkStatisticsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `forceRefresh` of this provider.
  bool get forceRefresh;
}

class _NetworkStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with NetworkStatisticsRef {
  _NetworkStatisticsProviderElement(super.provider);

  @override
  bool get forceRefresh => (origin as NetworkStatisticsProvider).forceRefresh;
}

String _$networkInfoStateHash() => r'388fd1dfca147cd6a3d9413e9dd0624193d834eb';

/// See also [NetworkInfoState].
@ProviderFor(NetworkInfoState)
final networkInfoStateProvider =
    AutoDisposeNotifierProvider<NetworkInfoState, NetworkInfo>.internal(
      NetworkInfoState.new,
      name: r'networkInfoStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$networkInfoStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NetworkInfoState = AutoDisposeNotifier<NetworkInfo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
