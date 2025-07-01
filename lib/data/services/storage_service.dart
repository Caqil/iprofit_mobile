import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/auth/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Hive boxes
  static late Box _cacheBox;
  static late Box _userBox;
  static late Box _settingsBox;

  // Box names
  static const String _cacheBoxName = 'cache_box';
  static const String _userBoxName = 'user_box';
  static const String _settingsBoxName = 'settings_box';

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _deviceIdKey = 'device_id';
  static const String _deviceFingerprintKey = 'device_fingerprint';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _firstLaunchKey = 'first_launch';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  static Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Open Hive boxes
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _userBox = await Hive.openBox(_userBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management (Secure Storage)
  static Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // User data management (Hive)
  static Future<void> setUser(UserModel user) async {
    await _userBox.put(_userKey, user.toJson());
  }

  static Future<UserModel?> getUser() async {
    try {
      final userData = _userBox.get(_userKey);
      if (userData != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(userData));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user: $e');
      }
      return null;
    }
  }

  // Device information (Shared Preferences)
  static Future<void> setDeviceId(String deviceId) async {
    await _prefs?.setString(_deviceIdKey, deviceId);
  }

  static Future<String?> getDeviceId() async {
    return _prefs?.getString(_deviceIdKey);
  }

  static Future<void> setDeviceFingerprint(String fingerprint) async {
    await _prefs?.setString(_deviceFingerprintKey, fingerprint);
  }

  static Future<String?> getDeviceFingerprint() async {
    return _prefs?.getString(_deviceFingerprintKey);
  }

  // Settings management (Hive)
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _settingsBox.put(_biometricEnabledKey, enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    return _settingsBox.get(_biometricEnabledKey, defaultValue: false);
  }

  static Future<void> setFirstLaunch(bool isFirst) async {
    await _settingsBox.put(_firstLaunchKey, isFirst);
  }

  static Future<bool> isFirstLaunch() async {
    return _settingsBox.get(_firstLaunchKey, defaultValue: true);
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await _settingsBox.put(_onboardingCompletedKey, completed);
  }

  static Future<bool> isOnboardingCompleted() async {
    return _settingsBox.get(_onboardingCompletedKey, defaultValue: false);
  }

  // Cache management (Hive)
  static Future<void> setCachedData(String key, dynamic data) async {
    try {
      await _cacheBox.put(key, {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error caching data for $key: $e');
      }
    }
  }

  static Future<dynamic> getCachedData(String key, {Duration? maxAge}) async {
    try {
      final cachedItem = _cacheBox.get(key);
      if (cachedItem != null) {
        final timestamp = cachedItem['timestamp'] as int;
        final data = cachedItem['data'];

        // Check if data is still valid based on maxAge
        if (maxAge != null) {
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final now = DateTime.now();
          if (now.difference(cacheTime) > maxAge) {
            await removeCachedData(key);
            return null;
          }
        }

        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached data for $key: $e');
      }
      return null;
    }
  }

  static Future<void> removeCachedData(String key) async {
    try {
      await _cacheBox.delete(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing cached data for $key: $e');
      }
    }
  }

  static Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }

  // Get cache size and info
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final keys = _cacheBox.keys.toList();
      final totalItems = keys.length;

      // Calculate approximate size (this is an estimation)
      int approximateSize = 0;
      for (final key in keys) {
        final item = _cacheBox.get(key);
        if (item != null) {
          approximateSize += jsonEncode(item).length;
        }
      }

      return {
        'totalItems': totalItems,
        'approximateSize': approximateSize,
        'keys': keys,
      };
    } catch (e) {
      return {
        'totalItems': 0,
        'approximateSize': 0,
        'keys': [],
        'error': e.toString(),
      };
    }
  }

  // Check if cache is stale
  static Future<bool> isCacheStale(String key, Duration maxAge) async {
    try {
      final cachedItem = _cacheBox.get(key);
      if (cachedItem == null) return true;

      final timestamp = cachedItem['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      return now.difference(cacheTime) > maxAge;
    } catch (e) {
      return true;
    }
  }

  // Batch operations
  static Future<void> setCachedDataBatch(Map<String, dynamic> dataMap) async {
    try {
      await _cacheBox.putAll(
        dataMap.map(
          (key, value) => MapEntry(key, {
            'data': value,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          }),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error batch caching data: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> getCachedDataBatch(
    List<String> keys, {
    Duration? maxAge,
  }) async {
    final result = <String, dynamic>{};

    for (final key in keys) {
      final data = await getCachedData(key, maxAge: maxAge);
      if (data != null) {
        result[key] = data;
      }
    }

    return result;
  }

  // Authentication helpers
  static Future<void> clearAuthData() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _userBox.delete(_userKey),
    ]);
  }

  static Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await Future.wait([
      clearAuthData(),
      clearCache(),
      _settingsBox.clear(),
      _prefs?.clear() ?? Future.value(),
    ]);
  }

  // Advanced cache management
  static Future<void> cleanupExpiredCache() async {
    try {
      final keys = _cacheBox.keys.toList();
      final now = DateTime.now();

      for (final key in keys) {
        final cachedItem = _cacheBox.get(key);
        if (cachedItem != null) {
          final timestamp = cachedItem['timestamp'] as int;
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

          // Remove items older than 7 days
          if (now.difference(cacheTime) > const Duration(days: 7)) {
            await _cacheBox.delete(key);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up expired cache: $e');
      }
    }
  }

  // Export/Import for backup
  static Future<Map<String, dynamic>> exportUserData() async {
    try {
      final user = await getUser();
      final settings = _settingsBox.toMap();

      return {
        'user': user?.toJson(),
        'settings': settings,
        'exportTime': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }

  static Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      if (data['user'] != null) {
        final user = UserModel.fromJson(data['user']);
        await setUser(user);
      }

      if (data['settings'] != null) {
        final settings = data['settings'] as Map;
        for (final entry in settings.entries) {
          await _settingsBox.put(entry.key, entry.value);
        }
      }
    } catch (e) {
      throw Exception('Failed to import user data: $e');
    }
  }

  // Memory management
  static Future<void> compactDatabase() async {
    try {
      await _cacheBox.compact();
      await _userBox.compact();
      await _settingsBox.compact();
    } catch (e) {
      if (kDebugMode) {
        print('Error compacting database: $e');
      }
    }
  }

  // Close all boxes (call this when app is terminating)
  static Future<void> dispose() async {
    try {
      await _cacheBox.close();
      await _userBox.close();
      await _settingsBox.close();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing storage service: $e');
      }
    }
  }
}
