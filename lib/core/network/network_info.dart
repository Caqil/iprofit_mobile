// lib/core/network/network_info.dart
import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../errors/app_exception.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/device_service.dart';

part 'network_info.g.dart';

// ============================================================================
// MODEL
// ============================================================================

@JsonSerializable()
class NetworkInfo {
  final bool isConnected;
  final NetworkType networkType;
  final String connectionType;
  final DateTime lastUpdated;
  final bool isInternetAccessible;
  final String? networkName;
  final String? ipAddress;
  final int? ping;
  final double? signalStrength;
  final Map<String, dynamic>? additionalInfo;

  const NetworkInfo({
    required this.isConnected,
    required this.networkType,
    required this.connectionType,
    required this.lastUpdated,
    this.isInternetAccessible = false,
    this.networkName,
    this.ipAddress,
    this.ping,
    this.signalStrength,
    this.additionalInfo,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) =>
      _$NetworkInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkInfoToJson(this);

  factory NetworkInfo.initial() => NetworkInfo(
    isConnected: false,
    networkType: NetworkType.none,
    connectionType: 'none',
    lastUpdated: DateTime.now(),
  );

  factory NetworkInfo.fromConnectivityResult(
    ConnectivityResult result, {
    bool isInternetAccessible = false,
    String? networkName,
    String? ipAddress,
    int? ping,
    double? signalStrength,
    Map<String, dynamic>? additionalInfo,
  }) {
    return NetworkInfo(
      isConnected: result != ConnectivityResult.none,
      networkType: _mapConnectivityToNetworkType(result),
      connectionType: _getConnectionTypeString(result),
      lastUpdated: DateTime.now(),
      isInternetAccessible: isInternetAccessible,
      networkName: networkName,
      ipAddress: ipAddress,
      ping: ping,
      signalStrength: signalStrength,
      additionalInfo: additionalInfo,
    );
  }

  static NetworkType _mapConnectivityToNetworkType(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.mobile:
        return NetworkType.mobile;
      case ConnectivityResult.ethernet:
        return NetworkType.ethernet;
      case ConnectivityResult.bluetooth:
        return NetworkType.bluetooth;
      case ConnectivityResult.vpn:
        return NetworkType.vpn;
      case ConnectivityResult.other:
        return NetworkType.other;
      case ConnectivityResult.none:
      default:
        return NetworkType.none;
    }
  }

  static String _getConnectionTypeString(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'wifi';
      case ConnectivityResult.mobile:
        return 'mobile';
      case ConnectivityResult.ethernet:
        return 'ethernet';
      case ConnectivityResult.bluetooth:
        return 'bluetooth';
      case ConnectivityResult.vpn:
        return 'vpn';
      case ConnectivityResult.other:
        return 'other';
      case ConnectivityResult.none:
      default:
        return 'none';
    }
  }

  NetworkInfo copyWith({
    bool? isConnected,
    NetworkType? networkType,
    String? connectionType,
    DateTime? lastUpdated,
    bool? isInternetAccessible,
    String? networkName,
    String? ipAddress,
    int? ping,
    double? signalStrength,
    Map<String, dynamic>? additionalInfo,
  }) {
    return NetworkInfo(
      isConnected: isConnected ?? this.isConnected,
      networkType: networkType ?? this.networkType,
      connectionType: connectionType ?? this.connectionType,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isInternetAccessible: isInternetAccessible ?? this.isInternetAccessible,
      networkName: networkName ?? this.networkName,
      ipAddress: ipAddress ?? this.ipAddress,
      ping: ping ?? this.ping,
      signalStrength: signalStrength ?? this.signalStrength,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NetworkInfo) return false;
    return isConnected == other.isConnected &&
        networkType == other.networkType &&
        connectionType == other.connectionType &&
        lastUpdated == other.lastUpdated &&
        isInternetAccessible == other.isInternetAccessible &&
        networkName == other.networkName &&
        ipAddress == other.ipAddress &&
        ping == other.ping &&
        signalStrength == other.signalStrength &&
        _mapEquals(additionalInfo, other.additionalInfo);
  }

  @override
  int get hashCode {
    return Object.hash(
      isConnected,
      networkType,
      connectionType,
      lastUpdated,
      isInternetAccessible,
      networkName,
      ipAddress,
      ping,
      signalStrength,
      additionalInfo,
    );
  }

  @override
  String toString() {
    return 'NetworkInfo('
        'isConnected: $isConnected, '
        'networkType: $networkType, '
        'connectionType: $connectionType, '
        'lastUpdated: $lastUpdated, '
        'isInternetAccessible: $isInternetAccessible, '
        'networkName: $networkName, '
        'ipAddress: $ipAddress, '
        'ping: $ping, '
        'signalStrength: $signalStrength, '
        'additionalInfo: $additionalInfo)';
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

@JsonEnum()
enum NetworkType { none, wifi, mobile, ethernet, bluetooth, vpn, other }

// ============================================================================
// SERVICE
// ============================================================================

class NetworkInfoService {
  static NetworkInfoService? _instance;
  static NetworkInfoService get instance =>
      _instance ??= NetworkInfoService._();

  NetworkInfoService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<NetworkInfo> _networkInfoController =
      StreamController<NetworkInfo>.broadcast();

  NetworkInfo? _currentNetworkInfo;
  static const String _cacheKey = 'network_info_cache';
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Stream of network info updates
  Stream<NetworkInfo> get networkInfoStream => _networkInfoController.stream;

  /// Get current network info
  NetworkInfo? get currentNetworkInfo => _currentNetworkInfo;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      await _loadCachedNetworkInfo();
      await _startConnectivityMonitoring();
      await checkConnectivity();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing NetworkInfoService: $e');
      }
    }
  }

  Future<void> _startConnectivityMonitoring() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        // Use the first result as the primary connectivity status
        final result = results.isNotEmpty
            ? results.first
            : ConnectivityResult.none;
        await _updateNetworkInfo(result);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Connectivity monitoring error: $error');
        }
      },
    );
  }

  /// Check current connectivity
  Future<NetworkInfo> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // Use the first result as the primary connectivity status
      final result = results.isNotEmpty
          ? results.first
          : ConnectivityResult.none;
      return await _updateNetworkInfo(result);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return _currentNetworkInfo ?? NetworkInfo.initial();
    }
  }

  /// Update network info based on connectivity result
  Future<NetworkInfo> _updateNetworkInfo(ConnectivityResult result) async {
    try {
      String? ipAddress;
      int? ping;
      bool isInternetAccessible = false;

      if (result != ConnectivityResult.none) {
        ipAddress = await _getIpAddress();
        ping = await _measurePing();
        isInternetAccessible = await _checkInternetAccess();
      }

      final networkInfo = NetworkInfo.fromConnectivityResult(
        result,
        isInternetAccessible: isInternetAccessible,
        ipAddress: ipAddress,
        ping: ping,
      );

      _currentNetworkInfo = networkInfo;
      await _cacheNetworkInfo(networkInfo);
      _networkInfoController.add(networkInfo);

      return networkInfo;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating network info: $e');
      }
      return _currentNetworkInfo ?? NetworkInfo.initial();
    }
  }

  /// Get device IP address
  Future<String?> _getIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address.address;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Measure ping to test server
  Future<int?> _measurePing() async {
    try {
      final stopwatch = Stopwatch()..start();
      final result = await InternetAddress.lookup('google.com');
      stopwatch.stop();

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return stopwatch.elapsedMilliseconds;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if device has internet access
  Future<bool> _checkInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Cache network info
  Future<void> _cacheNetworkInfo(NetworkInfo networkInfo) async {
    try {
      await StorageService.setCachedData(_cacheKey, {
        'data': networkInfo.toJson(),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error caching network info: $e');
      }
    }
  }

  /// Load cached network info
  Future<void> _loadCachedNetworkInfo() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKey,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        _currentNetworkInfo = NetworkInfo.fromJson(
          cached['data'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cached network info: $e');
      }
    }
  }

  /// Dispose the service
  void dispose() {
    _connectivitySubscription?.cancel();
    _networkInfoController.close();
  }
}

// ============================================================================
// REPOSITORY
// ============================================================================

class NetworkInfoRepository {
  final NetworkInfoService _networkInfoService = NetworkInfoService.instance;

  static const String _connectivityHistoryKey = 'connectivity_history';
  static const int _maxHistoryEntries = 100;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get current network info
  Future<NetworkInfo> getCurrentNetworkInfo() async {
    try {
      return await _networkInfoService.checkConnectivity();
    } catch (e) {
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get network info stream
  Stream<NetworkInfo> getNetworkInfoStream() {
    return _networkInfoService.networkInfoStream;
  }

  /// Check if device has internet access
  Future<bool> hasInternetAccess() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get connectivity history
  Future<List<Map<String, dynamic>>> getConnectivityHistory({
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_connectivityHistoryKey}_$limit';

      if (!forceRefresh) {
        final cached = await _getCachedHistory(cacheKey);
        if (cached != null) return cached;
      }

      final history = await StorageService.getCachedData(
        _connectivityHistoryKey,
      );

      if (history != null && history['data'] is List) {
        final List<dynamic> historyData = history['data'];
        final result = historyData
            .map((item) => item as Map<String, dynamic>)
            .take(limit)
            .toList();

        await _cacheHistory(cacheKey, result);
        return result;
      }

      return [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Save connectivity event to history
  Future<void> saveConnectivityEvent(NetworkInfo networkInfo) async {
    try {
      final currentHistory = await getConnectivityHistory(
        limit: _maxHistoryEntries - 1,
        forceRefresh: true,
      );

      final newEvent = {
        'timestamp': DateTime.now().toIso8601String(),
        'isConnected': networkInfo.isConnected,
        'networkType': networkInfo.networkType.toString(),
        'connectionType': networkInfo.connectionType,
        'isInternetAccessible': networkInfo.isInternetAccessible,
        'ipAddress': networkInfo.ipAddress,
        'ping': networkInfo.ping,
        'deviceId': await DeviceService.getDeviceId(),
      };

      final updatedHistory = [newEvent, ...currentHistory];

      await StorageService.setCachedData(_connectivityHistoryKey, {
        'data': updatedHistory,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      });

      await _clearHistoryCache();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving connectivity event: $e');
      }
    }
  }

  /// Get network statistics
  Future<Map<String, dynamic>> getNetworkStatistics({
    bool forceRefresh = false,
  }) async {
    try {
      const cacheKey = 'network_statistics';

      if (!forceRefresh) {
        final cached = await _getCachedStatistics(cacheKey);
        if (cached != null) return cached;
      }

      final history = await getConnectivityHistory(
        limit: _maxHistoryEntries,
        forceRefresh: true,
      );

      if (history.isEmpty) {
        return _getEmptyStatistics();
      }

      final stats = _calculateStatistics(history);
      await _cacheStatistics(cacheKey, stats);

      return stats;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Calculate statistics from history
  Map<String, dynamic> _calculateStatistics(
    List<Map<String, dynamic>> history,
  ) {
    final totalEvents = history.length;
    final connectedEvents = history
        .where((event) => event['isConnected'] == true)
        .length;
    final connectionUptime = (connectedEvents / totalEvents) * 100;

    // Most used network type
    final networkTypeCounts = <String, int>{};
    for (final event in history) {
      final networkType = event['networkType'] as String;
      networkTypeCounts[networkType] =
          (networkTypeCounts[networkType] ?? 0) + 1;
    }

    final mostUsedNetworkType =
        networkTypeCounts.entries
            .fold<MapEntry<String, int>?>(
              null,
              (prev, curr) =>
                  prev == null || curr.value > prev.value ? curr : prev,
            )
            ?.key ??
        'none';

    // Average ping
    final pings = history
        .where((event) => event['ping'] != null)
        .map((event) => event['ping'] as int)
        .toList();
    final averagePing = pings.isNotEmpty
        ? pings.reduce((a, b) => a + b) / pings.length
        : null;

    // Connection stability
    int disconnections = 0;
    for (int i = 1; i < history.length; i++) {
      if (history[i - 1]['isConnected'] == true &&
          history[i]['isConnected'] == false) {
        disconnections++;
      }
    }
    final connectionStability = totalEvents > 1
        ? ((totalEvents - disconnections) / totalEvents) * 100
        : 100.0;

    // Internet accessibility rate
    final internetAccessibleEvents = history
        .where((event) => event['isInternetAccessible'] == true)
        .length;
    final internetAccessibilityRate = totalEvents > 0
        ? (internetAccessibleEvents / totalEvents) * 100
        : 0.0;

    return {
      'totalEvents': totalEvents,
      'connectionUptime': connectionUptime,
      'mostUsedNetworkType': mostUsedNetworkType,
      'averagePing': averagePing,
      'connectionStability': connectionStability,
      'totalDisconnections': disconnections,
      'internetAccessibilityRate': internetAccessibilityRate,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _getEmptyStatistics() {
    return {
      'totalEvents': 0,
      'connectionUptime': 0.0,
      'mostUsedNetworkType': 'none',
      'averagePing': null,
      'connectionStability': 0.0,
      'totalDisconnections': 0,
      'internetAccessibilityRate': 0.0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// Clear connectivity history
  Future<void> clearConnectivityHistory() async {
    try {
      await StorageService.setCachedData(_connectivityHistoryKey, {
        'data': [],
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      });

      await _clearHistoryCache();
    } catch (e) {
      throw AppException.fromException(e as Exception);
    }
  }

  // Cache management methods
  Future<List<Map<String, dynamic>>?> _getCachedHistory(String key) async {
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

  Future<void> _cacheHistory(
    String key,
    List<Map<String, dynamic>> history,
  ) async {
    await StorageService.setCachedData(key, {
      'data': history,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedStatistics(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
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

  Future<void> _cacheStatistics(String key, Map<String, dynamic> stats) async {
    await StorageService.setCachedData(key, {
      'data': stats,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _clearHistoryCache() async {
    // Clear all history-related cache keys
    try {
      await StorageService.setCachedData('network_statistics', null);
    } catch (e) {
      // Ignore cache clearing errors
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

final networkInfoRepositoryProvider = Provider<NetworkInfoRepository>((ref) {
  return NetworkInfoRepository();
});

@riverpod
class NetworkInfoState extends _$NetworkInfoState {
  @override
  NetworkInfo build() {
    _initializeService();
    return NetworkInfoService.instance.currentNetworkInfo ??
        NetworkInfo.initial();
  }

  void _initializeService() {
    final subscription = NetworkInfoService.instance.networkInfoStream.listen((
      networkInfo,
    ) {
      state = networkInfo;

      // Save to history
      ref
          .read(networkInfoRepositoryProvider)
          .saveConnectivityEvent(networkInfo);
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  /// Refresh network info
  Future<void> refresh() async {
    try {
      final repository = ref.read(networkInfoRepositoryProvider);
      final networkInfo = await repository.getCurrentNetworkInfo();
      state = networkInfo;
    } catch (e) {
      // Handle error silently or emit error state
      if (kDebugMode) {
        print('Error refreshing network info: $e');
      }
    }
  }

  /// Check internet access
  Future<bool> checkInternetAccess() async {
    final repository = ref.read(networkInfoRepositoryProvider);
    return await repository.hasInternetAccess();
  }
}

// Additional providers
@riverpod
Future<bool> hasInternetAccess(Ref ref) async {
  final repository = ref.watch(networkInfoRepositoryProvider);
  return await repository.hasInternetAccess();
}

@riverpod
Future<List<Map<String, dynamic>>> connectivityHistory(
  Ref ref, {
  int limit = 50,
  bool forceRefresh = false,
}) async {
  final repository = ref.watch(networkInfoRepositoryProvider);
  return await repository.getConnectivityHistory(
    limit: limit,
    forceRefresh: forceRefresh,
  );
}

@riverpod
Future<Map<String, dynamic>> networkStatistics(
  Ref ref, {
  bool forceRefresh = false,
}) async {
  final repository = ref.watch(networkInfoRepositoryProvider);
  return await repository.getNetworkStatistics(forceRefresh: forceRefresh);
}
