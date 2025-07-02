// lib/presentation/providers/splash_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iprofit_mobile/core/constants/storage_keys.dart';
import 'package:iprofit_mobile/core/network/network_info.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/device_service.dart';
import '../../data/services/data_loader_service.dart';
import '../providers/auth_provider.dart';

part 'splash_provider.g.dart';

// ============================================================================
// SPLASH STATE MODEL
// ============================================================================

/// Splash screen states
enum SplashStatus { initializing, checkingAuth, loadingData, completed, error }

/// Splash provider state model
class SplashState {
  final SplashStatus status;
  final String message;
  final double progress;
  final String? error;
  final bool isFirstLaunch;
  final bool needsOnboarding;
  final bool hasInternetConnection;
  final bool isAuthValid;
  final Map<String, bool> initializationSteps;

  const SplashState({
    this.status = SplashStatus.initializing,
    this.message = 'Initializing...',
    this.progress = 0.0,
    this.error,
    this.isFirstLaunch = false,
    this.needsOnboarding = false,
    this.hasInternetConnection = true,
    this.isAuthValid = false,
    this.initializationSteps = const {},
  });

  SplashState copyWith({
    SplashStatus? status,
    String? message,
    double? progress,
    String? error,
    bool? isFirstLaunch,
    bool? needsOnboarding,
    bool? hasInternetConnection,
    bool? isAuthValid,
    Map<String, bool>? initializationSteps,
  }) {
    return SplashState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      error: error,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      hasInternetConnection:
          hasInternetConnection ?? this.hasInternetConnection,
      isAuthValid: isAuthValid ?? this.isAuthValid,
      initializationSteps: initializationSteps ?? this.initializationSteps,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get isCompleted => status == SplashStatus.completed;
  bool get isLoading =>
      status != SplashStatus.completed && status != SplashStatus.error;
  bool get canProceed => isCompleted && !hasError;

  /// Get next route based on app state
  String get nextRoute {
    if (hasError) return '/error';
    if (isFirstLaunch || needsOnboarding) return '/onboarding';
    if (!isAuthValid) return '/login';
    return '/dashboard';
  }
}

// ============================================================================
// SPLASH PROVIDER
// ============================================================================

@riverpod
class Splash extends _$Splash {
  @override
  SplashState build() {
    return const SplashState();
  }

  // ===== INITIALIZATION PROCESS =====

  /// Start the app initialization process
  Future<void> initializeApp() async {
    try {
      await _performInitializationSequence();
    } catch (e) {
      state = state.copyWith(
        status: SplashStatus.error,
        error: _getErrorMessage(e),
        message: 'Initialization failed',
      );
    }
  }

  /// Perform the complete initialization sequence
  Future<void> _performInitializationSequence() async {
    final steps = {
      'storage': false,
      'network': false,
      'device': false,
      'notifications': false,
      'auth': false,
      'data': false,
    };

    state = state.copyWith(
      status: SplashStatus.initializing,
      initializationSteps: steps,
    );

    // Step 1: Initialize storage
    await _updateStep('storage', 'Initializing storage...', 10.0, () async {
      await StorageService.initialize();
      await _checkFirstLaunch();
    });

    // Step 2: Check network connectivity
    await _updateStep('network', 'Checking connectivity...', 20.0, () async {
      await _checkNetworkConnectivity();
    });

    // Step 3: Initialize device services
    await _updateStep('device', 'Setting up device...', 30.0, () async {
      await _initializeDeviceServices();
    });

    // Step 4: Initialize notifications
    await _updateStep(
      'notifications',
      'Setting up notifications...',
      40.0,
      () async {
       // await _initializeNotifications();
      },
    );

    // Step 5: Check authentication
    await _updateStep('auth', 'Checking authentication...', 60.0, () async {
      await _checkAuthentication();
    });

    // Step 6: Load initial data (if authenticated)
    if (state.isAuthValid) {
      await _updateStep('data', 'Loading your data...', 90.0, () async {
        await _loadInitialData();
      });
    } else {
      _markStepComplete('data', 90.0);
    }

    // Finalize initialization
    state = state.copyWith(
      status: SplashStatus.completed,
      message: 'Ready!',
      progress: 100.0,
    );

    // Small delay to show completion
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Update initialization step
  Future<void> _updateStep(
    String stepName,
    String message,
    double progress,
    Future<void> Function() action,
  ) async {
    state = state.copyWith(message: message, progress: progress);

    try {
      await action();
      _markStepComplete(stepName, progress);
    } catch (e) {
      throw AppException.unknown('Failed to $message: ${e.toString()}');
    }
  }

  /// Mark step as complete
  void _markStepComplete(String stepName, double progress) {
    final updatedSteps = Map<String, bool>.from(state.initializationSteps);
    updatedSteps[stepName] = true;

    state = state.copyWith(
      initializationSteps: updatedSteps,
      progress: progress,
    );
  }

  // ===== INITIALIZATION STEPS =====

  /// Check if this is the first app launch
  Future<void> _checkFirstLaunch() async {
    final hasLaunched =
        await StorageService.getBool(StorageKeys.isFirstLaunch) ?? false;
    final hasCompletedOnboarding =
        await StorageService.getBool(StorageKeys.onboardingCompleted) ?? false;

    if (!hasLaunched) {
      await StorageService.setBool(StorageKeys.isFirstLaunch, true);
    }

    state = state.copyWith(
      isFirstLaunch: !hasLaunched,
      needsOnboarding: !hasCompletedOnboarding,
    );
  }

  /// Check network connectivity
  Future<void> _checkNetworkConnectivity() async {
    final networkService = ref.read(networkInfoStateProvider);
    final isConnected = networkService.isInternetAccessible;

    state = state.copyWith(hasInternetConnection: isConnected);

    if (!isConnected) {
      // Still continue initialization in offline mode
      // The app should handle offline scenarios gracefully
    }
  }

  /// Initialize device services
  Future<void> _initializeDeviceServices() async {
    try {

      // Get device info for debugging/analytics
      final deviceInfo = await DeviceService.getFullDeviceInfo();

      // Store device fingerprint if needed
      final deviceId = await DeviceService.getDeviceId();
      await StorageService.setString(StorageKeys.deviceId, deviceId);
    } catch (e) {
      // Non-critical error, continue initialization
    }
  }

  /// Initialize notification services
  // Future<void> _initializeNotifications() async {
  //   try {
  //     await NotificationService.initialize();

  //     // Request permissions if needed
  //     final hasPermission = await NotificationService.requestPermissions();

  //     if (hasPermission) {
  //       // Register FCM token
  //       await NotificationService.registerFcmToken();
  //     }
  //   } catch (e) {
  //     // Non-critical error, continue initialization
  //   }
  // }

  /// Check authentication status
  Future<void> _checkAuthentication() async {
    state = state.copyWith(status: SplashStatus.checkingAuth);

    try {
      final authService = ref.read(authServiceProvider);
      final isAuthenticated = await authService.checkAuthStatus();

      state = state.copyWith(isAuthValid: isAuthenticated);

      if (isAuthenticated) {
        // Update auth provider state
        final authNotifier = ref.read(authProvider.notifier);
        await authNotifier.refreshUser();
      }
    } catch (e) {
      // Authentication check failed, treat as unauthenticated
      state = state.copyWith(isAuthValid: false);
    }
  }

  /// Load initial app data
  Future<void> _loadInitialData() async {
    if (!state.isAuthValid || !state.hasInternetConnection) {
      return; // Skip data loading if not authenticated or offline
    }

    state = state.copyWith(status: SplashStatus.loadingData);

    try {
      final dataLoaderService = ref.read(dataLoaderServiceProvider);

      // Load critical data only (non-blocking)
      await dataLoaderService.loadAppData(
        onProgress: (message) {
          state = state.copyWith(message: message);
        },
      );

      // Load remaining data in background after splash
      _loadBackgroundData();
    } catch (e) {
      // Data loading failed, but continue to app
      // The app should handle missing data gracefully
    }
  }

  /// Load non-critical data in background
  void _loadBackgroundData() {
    // Don't await this - let it load in background
    Future.microtask(() async {
      try {
        final dataLoaderService = ref.read(dataLoaderServiceProvider);
        await dataLoaderService.loadAppData();
      } catch (e) {
        // Silent fail for background data loading
      }
    });
  }

  // ===== VERSION CHECK =====

  /// Check for app updates
  Future<void> checkForUpdates() async {
    try {
      // Implement version check logic here
      // You might want to call your API to check for updates

      final currentVersion = AppConstants.appVersion;

      // For now, just simulate a version check
      await Future.delayed(const Duration(milliseconds: 500));

      // If update is required, you could navigate to update screen
      // or show a dialog
    } catch (e) {
      // Silent fail for version check
    }
  }

  // ===== MAINTENANCE CHECK =====

  /// Check if app is under maintenance
  Future<bool> checkMaintenanceStatus() async {
    try {
      // Implement maintenance check logic here
      // Call your API to check maintenance status

      await Future.delayed(const Duration(milliseconds: 300));

      // For now, return false (no maintenance)
      return false;
    } catch (e) {
      // If check fails, assume no maintenance
      return false;
    }
  }

  // ===== ERROR HANDLING =====

  /// Retry initialization
  Future<void> retryInitialization() async {
    state = const SplashState(); // Reset state
    await initializeApp();
  }

  /// Skip to login (for testing or debug purposes)
  void skipToLogin() {
    state = state.copyWith(
      status: SplashStatus.completed,
      isAuthValid: false,
      progress: 100.0,
      message: 'Ready!',
    );
  }

  /// Force complete initialization
  void forceComplete() {
    state = state.copyWith(
      status: SplashStatus.completed,
      progress: 100.0,
      message: 'Ready!',
    );
  }

  // ===== UTILITY METHODS =====

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return 'Something went wrong during initialization';
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get initialization progress percentage
  double getStepProgress() {
    final completedSteps = state.initializationSteps.values
        .where((completed) => completed)
        .length;
    final totalSteps = state.initializationSteps.length;

    if (totalSteps == 0) return 0.0;
    return (completedSteps / totalSteps) * 100.0;
  }

  /// Check if specific step is completed
  bool isStepCompleted(String stepName) {
    return state.initializationSteps[stepName] ?? false;
  }

  /// Get list of failed steps
  List<String> getFailedSteps() {
    return state.initializationSteps.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for splash status
@riverpod
SplashStatus splashStatus(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.status));
}

/// Provider for splash progress
@riverpod
double splashProgress(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.progress));
}

/// Provider for splash message
@riverpod
String splashMessage(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.message));
}

/// Provider for checking if splash is completed
@riverpod
bool isSplashCompleted(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.isCompleted));
}

/// Provider for splash error
@riverpod
String? splashError(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.error));
}

/// Provider for first launch status
@riverpod
bool isFirstLaunch(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.isFirstLaunch));
}

/// Provider for onboarding requirement
@riverpod
bool needsOnboarding(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.needsOnboarding));
}

/// Provider for next route
@riverpod
String nextRoute(Ref ref) {
  return ref.watch(splashProvider.select((state) => state.nextRoute));
}

/// Provider for internet connectivity status
@riverpod
bool hasInternetConnection(Ref ref) {
  return ref.watch(
    splashProvider.select((state) => state.hasInternetConnection),
  );
}
