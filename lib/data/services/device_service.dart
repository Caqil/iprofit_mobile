import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/storage_service.dart';

class DeviceService {
  static DeviceInfoPlugin? _deviceInfo;

  static DeviceInfoPlugin get deviceInfo {
    _deviceInfo ??= DeviceInfoPlugin();
    return _deviceInfo!;
  }

  static Future<String> getDeviceId() async {
    String? deviceId = await StorageService.getDeviceId();

    if (deviceId == null) {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId =
            androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId =
            iosInfo.identifierForVendor ??
            'unknown_ios_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }

      await StorageService.setDeviceId(deviceId);
    }

    return deviceId;
  }

  static Future<String> getDeviceFingerprint() async {
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
  }

  static Future<Map<String, dynamic>> _getDeviceData() async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'platform': 'android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'manufacturer': androidInfo.manufacturer,
        'version': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
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
        },
      };
    }

    return {'platform': 'unknown'};
  }

  static Future<Map<String, dynamic>> getFullDeviceInfo() async {
    final deviceData = await _getDeviceData();
    final deviceId = await getDeviceId();
    final fingerprint = await getDeviceFingerprint();

    return {
      ...deviceData,
      'deviceId': deviceId,
      'fingerprint': fingerprint,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
