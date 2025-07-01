import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';

part 'network_info.g.dart';

/// Network information and connectivity management
class NetworkInfo {
  final Connectivity _connectivity;
  final List<String> _testHosts;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<NetworkStatus> _statusController = StreamController<NetworkStatus>.broadcast();

  NetworkInfo({
    Connectivity? connectivity,
    List<String>? testHosts,
  }) : _connectivity = connectivity ?? Connectivity(),
       _testHosts = testHosts ?? [
         'google.com',
         'cloudflare.com',
         '8.8.8.8',
         AppConfig.baseUrl.replaceAll('https://', '').replaceAll('http://', ''),
       ];

  /// Stream of network status changes
  Stream<NetworkStatus> get onStatusChanged => _statusController.stream;

  /// Start monitoring network connectivity
  void startMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        _statusController.add(NetworkStatus.disconnected);
      },
    );
  }

  /// Stop monitoring network connectivity
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Get current connectivity status
  Future<ConnectivityResult> getConnectivityStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty ? results.first : ConnectivityResult.none;
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    final connectivityResult = await getConnectivityStatus();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    
    // Test actual internet connectivity
    return await hasInternetAccess();
  }

  /// Test actual internet access by pinging test hosts
  Future<bool> hasInternetAccess() async {
    try {
      for (final host in _testHosts) {
        if (await _canReachHost(host)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get detailed network information
  Future<NetworkDetails> getNetworkDetails() async {
    final connectivityResult = await getConnectivityStatus();
    final hasInternet = await hasInternetAccess();
    final connectionSpeed = await getConnectionSpeed();
    
    return NetworkDetails(
      connectivityResult: connectivityResult,
      hasInternetAccess: hasInternet,
      status: _getNetworkStatus(connectivityResult, hasInternet),
      connectionSpeed: connectionSpeed,
      timestamp: DateTime.now(),
    );
  }

  /// Estimate connection speed
  Future<ConnectionSpeed> getConnectionSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Try to reach a fast, reliable host
      final reachable = await _canReachHost('8.8.8.8', timeout: 3);
      
      stopwatch.stop();
      
      if (!reachable) {
        return ConnectionSpeed.none;
      }
      
      final latency = stopwatch.elapsedMilliseconds;
      
      if (latency < 100) {
        return ConnectionSpeed.excellent;
      } else if (latency < 200) {
        return ConnectionSpeed.good;
      } else if (latency < 500) {
        return ConnectionSpeed.fair;
      } else {
        return ConnectionSpeed.poor;
      }
    } catch (e) {
      return ConnectionSpeed.unknown;
    }
  }

  /// Test specific host reachability
  Future<bool> canReachHost(String host) async {
    return await _canReachHost(host);
  }

  /// Test API server connectivity
  Future<bool> canReachApiServer() async {
    final apiHost = AppConfig.baseUrl
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .split('/').first;
    
    return await _canReachHost(apiHost);
  }

  /// Get network type description
  String getNetworkTypeDescription(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
    }
  }

  /// Wait for internet connection with timeout
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<bool>();
    Timer? timeoutTimer;
    StreamSubscription<NetworkStatus>? subscription;

    // Set up timeout
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    // Check current status first
    if (await isConnected()) {
      timeoutTimer.cancel();
      return true;
    }

    // Listen for status changes
    subscription = onStatusChanged.listen((status) {
      if (status == NetworkStatus.connected) {
        timeoutTimer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    final result = await completer.future;
    timeoutTimer?.cancel();
    subscription?.cancel();
    
    return result;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _statusController.close();
  }

  // Private methods

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    if (result == ConnectivityResult.none) {
      _statusController.add(NetworkStatus.disconnected);
      return;
    }

    // Test actual internet access
    final hasInternet = await hasInternetAccess();
    final status = _getNetworkStatus(result, hasInternet);
    _statusController.add(status);
  }

  NetworkStatus _getNetworkStatus(ConnectivityResult connectivity, bool hasInternet) {
    if (connectivity == ConnectivityResult.none) {
      return NetworkStatus.disconnected;
    }
    
    if (!hasInternet) {
      return NetworkStatus.limited;
    }
    
    return NetworkStatus.connected;
  }

  Future<bool> _canReachHost(String host, {int timeout = 5}) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(Duration(seconds: timeout));
      
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        // Try to create a socket connection
        final socket = await Socket.connect(
          result.first,
          80,
          timeout: Duration(seconds: timeout),
        );
        socket.destroy();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Network status enumeration
enum NetworkStatus {
  connected,    // Connected with internet access
  limited,      // Connected but no internet access
  disconnected, // No network connection
}

/// Connection speed categories
enum ConnectionSpeed {
  none,
  poor,      // > 500ms
  fair,      // 200-500ms
  good,      // 100-200ms
  excellent, // < 100ms
  unknown,
}

/// Detailed network information
class NetworkDetails {
  final ConnectivityResult connectivityResult;
  final bool hasInternetAccess;
  final NetworkStatus status;
  final ConnectionSpeed connectionSpeed;
  final DateTime timestamp;

  const NetworkDetails({
    required this.connectivityResult,
    required this.hasInternetAccess,
    required this.status,
    required this.connectionSpeed,
    required this.timestamp,
  });

  String get connectionType {
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobile';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'None';
    }
  }

  String get speedDescription {
    switch (connectionSpeed) {
      case ConnectionSpeed.excellent:
        return 'Excellent';
      case ConnectionSpeed.good:
        return 'Good';
      case ConnectionSpeed.fair:
        return 'Fair';
      case ConnectionSpeed.poor:
        return 'Poor';
      case ConnectionSpeed.none:
        return 'No Connection';
      case ConnectionSpeed.unknown:
        return 'Unknown';
    }
  }

  String get statusDescription {
    switch (status) {
      case NetworkStatus.connected:
        return 'Connected';
      case NetworkStatus.limited:
        return 'Limited Connectivity';
      case NetworkStatus.disconnected:
        return 'Disconnected';
    }
  }

  bool get isUsable => status == NetworkStatus.connected;
  
  bool get isOptimal => status == NetworkStatus.connected && 
                       (connectionSpeed == ConnectionSpeed.excellent || 
                        connectionSpeed == ConnectionSpeed.good);

  Map<String, dynamic> toMap() {
    return {
      'connectivityResult': connectivityResult.name,
      'hasInternetAccess': hasInternetAccess,
      'status': status.name,
      'connectionSpeed': connectionSpeed.name,
      'connectionType': connectionType,
      'speedDescription': speedDescription,
      'statusDescription': statusDescription,
      'isUsable': isUsable,
      'isOptimal': isOptimal,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'NetworkDetails(type: $connectionType, status: $statusDescription, speed: $speedDescription)';
  }
}

/// Riverpod provider for NetworkInfo
@riverpod
NetworkInfo networkInfo(Ref ref) {
  final networkInfo = NetworkInfo();
  
  // Start monitoring when provider is created
  networkInfo.startMonitoring();
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    networkInfo.dispose();
  });
  
  return networkInfo;
}

/// Riverpod provider for current network status
@riverpod
class NetworkStatus extends _$NetworkStatus {
  @override
  Future<NetworkDetails> build() async {
    final networkInfo = ref.watch(networkInfoProvider);
    
    // Listen to status changes
    ref.listen(networkStatusStreamProvider, (previous, next) {
      next.whenData((status) {
        // Invalidate this provider when status changes
        ref.invalidateSelf();
      });
    });
    
    return await networkInfo.getNetworkDetails();
  }

  /// Refresh network status
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final networkInfo = ref.read(networkInfoProvider);
      final details = await networkInfo.getNetworkDetails();
      state = AsyncValue.data(details);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Check if connected
  Future<bool> isConnected() async {
    final networkInfo = ref.read(networkInfoProvider);
    return await networkInfo.isConnected();
  }

  /// Wait for connection
  Future<bool> waitForConnection({Duration? timeout}) async {
    final networkInfo = ref.read(networkInfoProvider);
    return await networkInfo.waitForConnection(
      timeout: timeout ?? const Duration(seconds: 30),
    );
  }
}

/// Riverpod provider for network status stream
@riverpod
Stream<NetworkDetails> networkStatusStream(NetworkStatusStreamRef ref) async* {
  final networkInfo = ref.watch(networkInfoProvider);
  
  // Emit initial status
  yield await networkInfo.getNetworkDetails();
  
  // Listen to connectivity changes and emit new status
  await for (final status in networkInfo.onStatusChanged) {
    yield await networkInfo.getNetworkDetails();
  }
}

/// Extension methods for NetworkStatus enum
extension NetworkStatusX on NetworkStatus {
  bool get isConnected => this == NetworkStatus.connected;
  bool get isDisconnected => this == NetworkStatus.disconnected;
  bool get isLimited => this == NetworkStatus.limited;
  bool get hasLimitedAccess => this == NetworkStatus.limited;
  
  String get description {
    switch (this) {
      case NetworkStatus.connected:
        return 'Connected to internet';
      case NetworkStatus.limited:
        return 'Connected but no internet access';
      case NetworkStatus.disconnected:
        return 'No network connection';
    }
  }
  
  String get userMessage {
    switch (this) {
      case NetworkStatus.connected:
        return 'You\'re online';
      case NetworkStatus.limited:
        return 'Limited connectivity - check your internet connection';
      case NetworkStatus.disconnected:
        return 'No internet connection';
    }
  }
}

/// Extension methods for ConnectionSpeed enum
extension ConnectionSpeedX on ConnectionSpeed {
  bool get isGood => this == ConnectionSpeed.good || this == ConnectionSpeed.excellent;
  bool get isPoor => this == ConnectionSpeed.poor || this == ConnectionSpeed.none;
  
  String get emoji {
    switch (this) {
      case ConnectionSpeed.excellent:
        return '🚀';
      case ConnectionSpeed.good:
        return '✅';
      case ConnectionSpeed.fair:
        return '⚠️';
      case ConnectionSpeed.poor:
        return '🐌';
      case ConnectionSpeed.none:
        return '❌';
      case ConnectionSpeed.unknown:
        return '❓';
    }
  }
  
  String get description {
    switch (this) {
      case ConnectionSpeed.excellent:
        return 'Excellent connection';
      case ConnectionSpeed.good:
        return 'Good connection';
      case ConnectionSpeed.fair:
        return 'Fair connection';
      case ConnectionSpeed.poor:
        return 'Poor connection';
      case ConnectionSpeed.none:
        return 'No connection';
      case ConnectionSpeed.unknown:
        return 'Unknown speed';
    }
  }
}