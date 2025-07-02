// lib/data/services/biometric_service.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/utils/device_utils.dart';
import '../models/auth/biometric_config.dart';
import 'storage_service.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Biometric authentication service that handles fingerprint, face recognition,
/// and other biometric authentication methods across Android and iOS platforms
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Stream controller for biometric state changes
  final _biometricStateController =
      StreamController<BiometricState>.broadcast();

  // Current biometric state
  BiometricState _currentState = BiometricState.unknown;

  // Storage keys for biometric data
  static const String _biometricFailedAttemptsKey = 'biometric_failed_attempts';
  static const String _biometricLockoutTimeKey = 'biometric_lockout_time';
  static const String _biometricLastAuthTimeKey = 'biometric_last_auth_time';
  static const String _biometricSetupDateKey = 'biometric_setup_date';

  // ===== GETTERS =====

  /// Current biometric state
  BiometricState get currentState => _currentState;

  /// Stream of biometric state changes
  Stream<BiometricState> get biometricStateStream =>
      _biometricStateController.stream;

  // ===== INITIALIZATION =====

  /// Initialize biometric service
  Future<void> initialize() async {
    await _updateBiometricState();
  }

  // ===== AVAILABILITY CHECKS =====

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking device support: $e');
      }
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await DeviceUtils.isBiometricAvailable();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking biometric availability: $e');
      }
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await DeviceUtils.getAvailableBiometrics();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available biometrics: $e');
      }
      return [];
    }
  }

  /// Get biometric configuration for the device
  Future<BiometricConfig> getBiometricConfig() async {
    final isSupported = await isDeviceSupported();
    final isAvailable = await isBiometricAvailable();
    final availableTypes = await getAvailableBiometrics();
    final isEnabled = await isBiometricEnabled();

    return BiometricConfig(
      isSupported: isSupported,
      isAvailable: isAvailable,
      isEnabled: isEnabled,
      availableTypes: availableTypes,
      preferredType: _getPreferredBiometricType(availableTypes),
      lastSetupDate: await _getLastSetupDate(),
      failedAttempts: await _getFailedAttempts(),
      isLockedOut: await _isLockedOut(),
    );
  }

  // ===== AUTHENTICATION METHODS =====

  /// Authenticate user with biometrics
  Future<BiometricResult> authenticate({
    String? localizedFallbackTitle,
    String? cancelButtonText,
    bool stickyAuth = true,
    bool sensitiveTransaction = false,
    bool useErrorDialogs = true,
  }) async {
    try {
      // Check if biometrics are available
      if (!await isBiometricAvailable()) {
        return BiometricResult.failure(
          error: BiometricError.notAvailable,
          message: 'Biometric authentication is not available',
        );
      }

      // Check if biometrics are enabled by user
      if (!await isBiometricEnabled()) {
        return BiometricResult.failure(
          error: BiometricError.notEnabled,
          message: 'Biometric authentication is not enabled',
        );
      }

      // Check if locked out due to too many failed attempts
      if (await _isLockedOut()) {
        return BiometricResult.failure(
          error: BiometricError.lockedOut,
          message: 'Biometric authentication is temporarily locked',
        );
      }

      // Perform authentication
      final authOptions = AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: stickyAuth,
        sensitiveTransaction: sensitiveTransaction,
        useErrorDialogs: useErrorDialogs,
      );

      final authenticated = await _localAuth.authenticate(
        localizedReason: _getLocalizedReason(sensitiveTransaction),

        options: authOptions,
      );

      if (authenticated) {
        // Reset failed attempts on successful authentication
        await _resetFailedAttempts();

        // Update last successful authentication time
        await _updateLastAuthTime();

        return BiometricResult.success();
      } else {
        // Track failed attempt
        await _trackFailedAttempt();

        return BiometricResult.failure(
          error: BiometricError.userCancel,
          message: 'Authentication was cancelled by user',
        );
      }
    } on PlatformException catch (e) {
      await _trackFailedAttempt();
      return _handlePlatformException(e);
    } catch (e) {
      await _trackFailedAttempt();
      return BiometricResult.failure(
        error: BiometricError.unknown,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Quick authentication for low-security operations
  Future<BiometricResult> quickAuthenticate() async {
    return authenticate(
      stickyAuth: false,
      sensitiveTransaction: false,
      useErrorDialogs: false,
    );
  }

  /// Secure authentication for high-security operations
  Future<BiometricResult> secureAuthenticate() async {
    return authenticate(
      stickyAuth: true,
      sensitiveTransaction: true,
      useErrorDialogs: true,
    );
  }

  // ===== SETTINGS MANAGEMENT =====

  /// Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      // Check if biometrics are available
      if (!await isBiometricAvailable()) {
        return false;
      }

      // Test authentication to ensure it works
      final result = await authenticate();

      if (result.isSuccess) {
        await StorageService.setBiometricEnabled(true);
        await _updateSetupDate();
        await _updateBiometricState();
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error enabling biometric: $e');
      }
      return false;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      await StorageService.setBiometricEnabled(false);
      await _clearBiometricData();
      await _updateBiometricState();
    } catch (e) {
      if (kDebugMode) {
        print('Error disabling biometric: $e');
      }
    }
  }

  /// Check if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    try {
      return await StorageService.isBiometricEnabled();
    } catch (e) {
      return false;
    }
  }

  /// Toggle biometric authentication
  Future<bool> toggleBiometric() async {
    final isEnabled = await isBiometricEnabled();

    if (isEnabled) {
      await disableBiometric();
      return false;
    } else {
      return await enableBiometric();
    }
  }

  // ===== SECURITY METHODS =====

  /// Check if biometric authentication is locked out
  Future<bool> _isLockedOut() async {
    try {
      final lockoutTime = await StorageService.getString(
        _biometricLockoutTimeKey,
      );
      if (lockoutTime != null) {
        final lockout = DateTime.parse(lockoutTime);
        return DateTime.now().isBefore(lockout);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get failed attempts count
  Future<int> _getFailedAttempts() async {
    try {
      return await StorageService.getInt(_biometricFailedAttemptsKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Track failed authentication attempt
  Future<void> _trackFailedAttempt() async {
    try {
      final attempts = await _getFailedAttempts() + 1;
      await StorageService.setInt(_biometricFailedAttemptsKey, attempts);

      // Lock out after 5 failed attempts for 30 minutes
      if (attempts >= 5) {
        final lockoutTime = DateTime.now().add(const Duration(minutes: 30));
        await StorageService.setString(
          _biometricLockoutTimeKey,
          lockoutTime.toIso8601String(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking failed attempt: $e');
      }
    }
  }

  /// Reset failed attempts counter
  Future<void> _resetFailedAttempts() async {
    try {
      await StorageService.setInt(_biometricFailedAttemptsKey, 0);
      await StorageService.setString(_biometricLockoutTimeKey, '');
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting failed attempts: $e');
      }
    }
  }

  /// Update last successful authentication time
  Future<void> _updateLastAuthTime() async {
    try {
      await StorageService.setString(
        _biometricLastAuthTimeKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating last auth time: $e');
      }
    }
  }

  /// Update biometric setup date
  Future<void> _updateSetupDate() async {
    try {
      await StorageService.setString(
        _biometricSetupDateKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating setup date: $e');
      }
    }
  }

  /// Get last setup date
  Future<DateTime?> _getLastSetupDate() async {
    try {
      final dateStr = await StorageService.getString(_biometricSetupDateKey);
      return dateStr != null && dateStr.isNotEmpty
          ? DateTime.parse(dateStr)
          : null;
    } catch (e) {
      return null;
    }
  }

  /// Clear all biometric-related data
  Future<void> _clearBiometricData() async {
    try {
      await StorageService.setInt(_biometricFailedAttemptsKey, 0);
      await StorageService.setString(_biometricLockoutTimeKey, '');
      await StorageService.setString(_biometricLastAuthTimeKey, '');
      await StorageService.setString(_biometricSetupDateKey, '');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing biometric data: $e');
      }
    }
  }

  // ===== UTILITY METHODS =====

  /// Get preferred biometric type based on availability
  BiometricType? _getPreferredBiometricType(List<BiometricType> available) {
    if (available.isEmpty) return null;

    // Prefer face recognition on iOS, fingerprint on Android
    if (Platform.isIOS && available.contains(BiometricType.face)) {
      return BiometricType.face;
    }

    if (available.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    }

    return available.first;
  }

  /// Get localized reason for authentication
  String _getLocalizedReason(bool sensitiveTransaction) {
    if (sensitiveTransaction) {
      return 'Please verify your identity to complete this sensitive transaction';
    }
    return 'Please verify your identity to access your account';
  }

  /// Handle platform-specific exceptions
  BiometricResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricResult.failure(
          error: BiometricError.notAvailable,
          message: 'Biometric authentication is not available on this device',
        );
      case 'NotEnrolled':
        return BiometricResult.failure(
          error: BiometricError.notEnrolled,
          message: 'No biometric credentials are enrolled on this device',
        );
      case 'LockedOut':
        return BiometricResult.failure(
          error: BiometricError.lockedOut,
          message:
              'Biometric authentication is temporarily locked due to too many failed attempts',
        );
      case 'PermanentlyLockedOut':
        return BiometricResult.failure(
          error: BiometricError.permanentlyLockedOut,
          message:
              'Biometric authentication is permanently locked. Please use device passcode.',
        );
      case 'BiometricOnlyNotSupported':
        return BiometricResult.failure(
          error: BiometricError.notSupported,
          message:
              'Biometric-only authentication is not supported on this device',
        );
      default:
        return BiometricResult.failure(
          error: BiometricError.unknown,
          message:
              e.message ??
              'An unknown error occurred during biometric authentication',
        );
    }
  }

  /// Update biometric state
  Future<void> _updateBiometricState() async {
    BiometricState newState;

    if (!await isDeviceSupported()) {
      newState = BiometricState.notSupported;
    } else if (!await isBiometricAvailable()) {
      newState = BiometricState.notAvailable;
    } else if (await _isLockedOut()) {
      newState = BiometricState.lockedOut;
    } else if (await isBiometricEnabled()) {
      newState = BiometricState.enabled;
    } else {
      newState = BiometricState.available;
    }

    if (_currentState != newState) {
      _currentState = newState;
      _biometricStateController.add(newState);
    }
  }

  /// Generate biometric signature for additional security
  Future<String?> generateBiometricSignature(String data) async {
    try {
      if (!await isBiometricEnabled()) {
        return null;
      }

      final deviceId = await DeviceUtils.getDeviceId();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final combined = '$data:$deviceId:$timestamp';

      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error generating biometric signature: $e');
      }
      return null;
    }
  }

  /// Verify biometric signature
  Future<bool> verifyBiometricSignature(
    String data,
    String signature, {
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    try {
      // Implementation would depend on your specific security requirements
      // This is a basic example
      final deviceId = await DeviceUtils.getDeviceId();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Try different timestamps within the maxAge window
      for (int i = 0; i < maxAge.inMinutes; i++) {
        final testTimestamp = (now - (i * 60000)).toString();
        final combined = '$data:$deviceId:$testTimestamp';
        final bytes = utf8.encode(combined);
        final digest = sha256.convert(bytes);

        if (digest.toString() == signature) {
          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying biometric signature: $e');
      }
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _biometricStateController.close();
  }
}

/// Biometric authentication state
enum BiometricState {
  /// State is unknown (not initialized)
  unknown,
  failure,
  success,
authenticating,waiting,
  /// Device does not support biometric authentication
  notSupported,

  /// Biometric authentication is not available (no biometrics enrolled)
  notAvailable,

  /// Biometric authentication is available but not enabled by user
  available,

  /// Biometric authentication is enabled and ready to use
  enabled,

  /// Biometric authentication is temporarily locked out
  lockedOut,
}
