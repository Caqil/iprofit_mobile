import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../../data/services/storage_service.dart';

class DeviceUtils {
  static DeviceInfoPlugin? _deviceInfo;
  static LocalAuthentication? _localAuth;
  static Connectivity? _connectivity;

  static DeviceInfoPlugin get deviceInfo {
    _deviceInfo ??= DeviceInfoPlugin();
    return _deviceInfo!;
  }

  static LocalAuthentication get localAuth {
    _localAuth ??= LocalAuthentication();
    return _localAuth!;
  }

  static Connectivity get connectivity {
    _connectivity ??= Connectivity();
    return _connectivity!;
  }

  /// Get unique device ID
  static Future<String> getDeviceId() async {
    try {
      String? deviceId = await StorageService.getDeviceId();

      if (deviceId == null) {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor;
        }

        // Fallback to timestamp-based ID if platform ID is null
        deviceId ??= 'device_${DateTime.now().millisecondsSinceEpoch}';

        await StorageService.setDeviceId(deviceId);
      }

      return deviceId;
    } catch (e) {
      // Fallback device ID
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Generate device fingerprint for security
  static Future<String> getDeviceFingerprint() async {
    try {
      String? fingerprint = await StorageService.getDeviceFingerprint();

      if (fingerprint == null) {
        final deviceData = await _getDeviceData();
        final fingerprintData = json.encode(deviceData);
        final bytes = utf8.encode(fingerprintData);
        final hash = sha256.convert(bytes);
        fingerprint = hash.toString();

        await StorageService.setDeviceFingerprint(fingerprint);
      }

      return fingerprint;
    } catch (e) {
      // Fallback fingerprint
      final fallbackData = {
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final bytes = utf8.encode(json.encode(fallbackData));
      return sha256.convert(bytes).toString();
    }
  }

  /// Get comprehensive device data
  static Future<Map<String, dynamic>> _getDeviceData() async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'manufacturer': androidInfo.manufacturer,
        'product': androidInfo.product,
        'device': androidInfo.device,
        'hardware': androidInfo.hardware,
        'version': {
          'release': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'incremental': androidInfo.version.incremental,
          'codename': androidInfo.version.codename,
        },
        'display': {
          'width': androidInfo.displayMetrics.widthPx,
          'height': androidInfo.displayMetrics.heightPx,
          'density': androidInfo.displayMetrics.density,
          'densityDpi': androidInfo.displayMetrics.densityDpi,
        },
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'platform': 'ios',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'localizedModel': iosInfo.localizedModel,
        'utsname': {
          'machine': iosInfo.utsname.machine,
          'nodename': iosInfo.utsname.nodename,
          'release': iosInfo.utsname.release,
          'sysname': iosInfo.utsname.sysname,
          'version': iosInfo.utsname.version,
        },
        'isPhysicalDevice': iosInfo.isPhysicalDevice,
      };
    }

    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
    };
  }

  /// Get device info for API headers
  static Future<Map<String, String>> getApiHeaders() async {
    final deviceId = await getDeviceId();
    final fingerprint = await getDeviceFingerprint();

    return {
      'x-device-id': deviceId,
      'x-fingerprint': fingerprint,
      'User-Agent': await _getUserAgent(),
    };
  }

  /// Generate user agent string
  static Future<String> _getUserAgent() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return 'IProfit-Flutter/${AppConstants.appVersion} (Android ${androidInfo.version.release}; ${androidInfo.model})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return 'IProfit-Flutter/${AppConstants.appVersion} (iOS ${iosInfo.systemVersion}; ${iosInfo.model})';
      }
    } catch (e) {
      // Fallback
    }

    return 'IProfit-Flutter/${AppConstants.appVersion}';
  }

  /// Check if device supports biometric authentication
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      final availableBiometrics = await localAuth.getAvailableBiometrics();

      return isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check device connectivity
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  /// Get connectivity type
  static Future<ConnectivityResult> getConnectivityType() async {
    try {
      return await connectivity.checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// Check if device is physical (not emulator)
  static Future<bool> isPhysicalDevice() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice;
      }
    } catch (e) {
      // Assume physical device if can't determine
    }
    return true;
  }

  /// Get device platform name
  static String getPlatformName() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return Platform.operatingSystem;
  }

  /// Vibrate device (if supported)
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Vibration not supported
    }
  }

  /// Light haptic feedback
  static Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic not supported
    }
  }

  /// Heavy haptic feedback
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Haptic not supported
    }
  }
}
