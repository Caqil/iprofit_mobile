// lib/data/models/auth/biometric_config.dart
import 'package:local_auth/local_auth.dart';

/// Configuration model for biometric authentication settings
class BiometricConfig {
  /// Whether the device supports biometric authentication
  final bool isSupported;

  /// Whether biometric authentication is available (enrolled)
  final bool isAvailable;

  /// Whether biometric authentication is enabled by the user
  final bool isEnabled;

  /// List of available biometric types on the device
  final List<BiometricType> availableTypes;

  /// Preferred biometric type for authentication
  final BiometricType? preferredType;

  /// Date when biometric authentication was first set up
  final DateTime? lastSetupDate;

  /// Number of failed authentication attempts
  final int failedAttempts;

  /// Whether biometric authentication is currently locked out
  final bool isLockedOut;

  BiometricConfig({
    required this.isSupported,
    required this.isAvailable,
    required this.isEnabled,
    required this.availableTypes,
    this.preferredType,
    this.lastSetupDate,
    this.failedAttempts = 0,
    this.isLockedOut = false,
  });

  /// Create a copy with updated values
  BiometricConfig copyWith({
    bool? isSupported,
    bool? isAvailable,
    bool? isEnabled,
    List<BiometricType>? availableTypes,
    BiometricType? preferredType,
    DateTime? lastSetupDate,
    int? failedAttempts,
    bool? isLockedOut,
  }) {
    return BiometricConfig(
      isSupported: isSupported ?? this.isSupported,
      isAvailable: isAvailable ?? this.isAvailable,
      isEnabled: isEnabled ?? this.isEnabled,
      availableTypes: availableTypes ?? this.availableTypes,
      preferredType: preferredType ?? this.preferredType,
      lastSetupDate: lastSetupDate ?? this.lastSetupDate,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      isLockedOut: isLockedOut ?? this.isLockedOut,
    );
  }

  /// Get user-friendly description of available biometrics
  String get availableBiometricsDescription {
    if (availableTypes.isEmpty) {
      return 'No biometric authentication available';
    }

    final descriptions = <String>[];
    for (final type in availableTypes) {
      switch (type) {
        case BiometricType.face:
          descriptions.add('Face recognition');
          break;
        case BiometricType.fingerprint:
          descriptions.add('Fingerprint');
          break;
        case BiometricType.iris:
          descriptions.add('Iris scan');
          break;
        case BiometricType.weak:
          descriptions.add('Pattern/PIN');
          break;
        case BiometricType.strong:
          descriptions.add('Strong biometric');
          break;
      }
    }

    return descriptions.join(', ');
  }

  /// Get status description
  String get statusDescription {
    if (!isSupported) {
      return 'Biometric authentication is not supported on this device';
    }
    if (!isAvailable) {
      return 'No biometric credentials are enrolled on this device';
    }
    if (isLockedOut) {
      return 'Biometric authentication is temporarily locked due to failed attempts';
    }
    if (!isEnabled) {
      return 'Biometric authentication is available but not enabled';
    }
    return 'Biometric authentication is ready to use';
  }

  @override
  String toString() {
    return 'BiometricConfig{isSupported: $isSupported, isAvailable: $isAvailable, '
        'isEnabled: $isEnabled, availableTypes: $availableTypes, '
        'preferredType: $preferredType, failedAttempts: $failedAttempts, '
        'isLockedOut: $isLockedOut}';
  }
}

// ============================================================================

// lib/data/models/auth/biometric_result.dart

/// Result model for biometric authentication operations
class BiometricResult {
  /// Whether the authentication was successful
  final bool isSuccess;

  /// Error type if authentication failed
  final BiometricError? error;

  /// Error message if authentication failed
  final String? message;

  /// Additional data from the authentication process
  final Map<String, dynamic>? data;

  /// Timestamp when the authentication was performed
  final DateTime timestamp;

  BiometricResult({
    required this.isSuccess,
    this.error,
    this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a successful result
  factory BiometricResult.success({Map<String, dynamic>? data}) {
    return BiometricResult(isSuccess: true, data: data);
  }

  /// Create a failure result
  factory BiometricResult.failure({
    required BiometricError error,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return BiometricResult(
      isSuccess: false,
      error: error,
      message: message,
      data: data,
    );
  }

  /// Get user-friendly error message
  String get friendlyMessage {
    if (isSuccess) {
      return 'Authentication successful';
    }

    if (message != null && message!.isNotEmpty) {
      return message!;
    }

    switch (error) {
      case BiometricError.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricError.notEnrolled:
        return 'No biometric credentials are set up. Please set up biometric authentication in your device settings';
      case BiometricError.notEnabled:
        return 'Biometric authentication is not enabled for this app';
      case BiometricError.lockedOut:
        return 'Biometric authentication is temporarily locked due to too many failed attempts';
      case BiometricError.permanentlyLockedOut:
        return 'Biometric authentication is permanently locked. Please use your device passcode';
      case BiometricError.userCancel:
        return 'Authentication was cancelled';
      case BiometricError.notSupported:
        return 'Biometric authentication is not supported on this device';
      case BiometricError.passcodeNotSet:
        return 'Device passcode is not set. Please set up a passcode in your device settings';
      case BiometricError.unknown:
      case null:
        return 'An unknown error occurred during authentication';
    }
  }

  /// Whether the error is recoverable (user can try again)
  bool get isRecoverable {
    switch (error) {
      case BiometricError.userCancel:
      case BiometricError.lockedOut:
        return true;
      case BiometricError.notAvailable:
      case BiometricError.notEnrolled:
      case BiometricError.notEnabled:
      case BiometricError.permanentlyLockedOut:
      case BiometricError.notSupported:
      case BiometricError.passcodeNotSet:
      case BiometricError.unknown:
      case null:
        return false;
    }
  }

  /// Whether the user should be directed to settings
  bool get shouldRedirectToSettings {
    switch (error) {
      case BiometricError.notEnrolled:
      case BiometricError.passcodeNotSet:
      case BiometricError.permanentlyLockedOut:
        return true;
      case BiometricError.notAvailable:
      case BiometricError.notEnabled:
      case BiometricError.lockedOut:
      case BiometricError.userCancel:
      case BiometricError.notSupported:
      case BiometricError.unknown:
      case null:
        return false;
    }
  }

  @override
  String toString() {
    return 'BiometricResult{isSuccess: $isSuccess, error: $error, '
        'message: $message, timestamp: $timestamp}';
  }
}

/// Enumeration of possible biometric authentication errors
enum BiometricError {
  /// Biometric authentication is not available on this device
  notAvailable,

  /// No biometric credentials are enrolled on this device
  notEnrolled,

  /// Biometric authentication is not enabled by the user
  notEnabled,

  /// Too many failed attempts, temporarily locked out
  lockedOut,

  /// Permanently locked out, must use device passcode
  permanentlyLockedOut,

  /// User cancelled the authentication
  userCancel,

  /// Biometric authentication is not supported on this device
  notSupported,

  /// Device passcode is not set
  passcodeNotSet,

  /// Unknown error occurred
  unknown,
}
