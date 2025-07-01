import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/data_loader_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/notification_service.dart';

part 'splash_provider.g.dart';

@riverpod
class Splash extends _$Splash {
  @override
  SplashState build() {
    return const SplashState();
  }

  Future<void> initializeApp() async {
    try {
      state = state.copyWith(
        isLoading: true,
        progress: 0.0,
        message: 'Initializing app...',
      );

      // Initialize core services
      await _initializeCoreServices();

      // Check if user is logged in and load data
      await _loadAppData();

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        progress: 1.0,
        message: 'Ready!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        error: e.toString(),
        message: 'Initialization failed',
      );
    }
  }

  Future<void> _initializeCoreServices() async {
    state = state.copyWith(progress: 0.1, message: 'Initializing storage...');

    // Initialize storage service
    await StorageService.initialize();

    state = state.copyWith(
      progress: 0.2,
      message: 'Setting up notifications...',
    );

    // Initialize notification service
    await NotificationService.initialize();

    state = state.copyWith(progress: 0.3, message: 'Cleaning up cache...');

    // Cleanup expired cache
    await StorageService.cleanupExpiredCache();

    state = state.copyWith(progress: 0.4, message: 'Services initialized');
  }

  Future<void> _loadAppData() async {
    state = state.copyWith(
      progress: 0.5,
      message: 'Checking authentication...',
    );

    final dataLoader = ref.read(dataLoaderServiceProvider);

    // Load app data with progress updates
    final result = await dataLoader.loadAppData(
      onProgress: (message) {
        // Update progress based on loading state
        double progress = 0.5;
        if (message.contains('dashboard'))
          progress = 0.6;
        else if (message.contains('wallet'))
          progress = 0.7;
        else if (message.contains('portfolio'))
          progress = 0.75;
        else if (message.contains('tasks'))
          progress = 0.8;
        else if (message.contains('referrals'))
          progress = 0.85;
        else if (message.contains('notifications'))
          progress = 0.9;
        else if (message.contains('KYC'))
          progress = 0.95;
        else if (message.contains('successfully'))
          progress = 1.0;

        state = state.copyWith(progress: progress, message: message);
      },
    );

    // Update state based on loading result
    state = state.copyWith(
      dataLoadResult: result,
      isAuthenticated: result.isAuthenticated,
      progress: 1.0,
    );

    // If authentication failed, clear any stale data
    if (!result.isAuthenticated) {
      await StorageService.clearAuthData();
    }

    // Register for push notifications if authenticated
    if (result.isAuthenticated) {
      try {
        await NotificationService.registerFCMToken();
      } catch (e) {
        // Non-critical error, continue without notifications
      }
    }
  }

  Future<void> retryInitialization() async {
    state = const SplashState();
    await initializeApp();
  }

  Future<void> refreshData() async {
    if (!state.isAuthenticated) return;

    try {
      state = state.copyWith(isRefreshing: true, message: 'Refreshing data...');

      final dataLoader = ref.read(dataLoaderServiceProvider);
      final result = await dataLoader.loadAppData(forceRefresh: true);

      state = state.copyWith(
        isRefreshing: false,
        dataLoadResult: result,
        message: 'Data refreshed',
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
        message: 'Refresh failed',
      );
    }
  }

  Future<void> logout() async {
    try {
      // Clear all data
      await StorageService.clearAllData();

      // Unregister from notifications
      await NotificationService.unregisterFCMToken();

      // Reset state
      state = const SplashState();
    } catch (e) {
      // Force clear even if logout fails
      await StorageService.clearAllData();
      state = const SplashState();
    }
  }
}

class SplashState {
  final bool isLoading;
  final bool isInitialized;
  final bool isAuthenticated;
  final bool isRefreshing;
  final bool hasError;
  final double progress;
  final String message;
  final String? error;
  final AppDataLoadResult? dataLoadResult;

  const SplashState({
    this.isLoading = false,
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.isRefreshing = false,
    this.hasError = false,
    this.progress = 0.0,
    this.message = 'Starting up...',
    this.error,
    this.dataLoadResult,
  });

  SplashState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? isAuthenticated,
    bool? isRefreshing,
    bool? hasError,
    double? progress,
    String? message,
    String? error,
    AppDataLoadResult? dataLoadResult,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasError: hasError ?? this.hasError,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: error ?? this.error,
      dataLoadResult: dataLoadResult ?? this.dataLoadResult,
    );
  }

  bool get canProceed => isInitialized && !hasError;

  bool get hasOfflineData =>
      dataLoadResult?.hasCoreData == true ||
      (dataLoadResult?.user != null && dataLoadResult?.walletBalance != null);

  List<String> get failedModules => dataLoadResult?.failedModules ?? [];

  double get dataLoadingProgress => dataLoadResult?.loadingProgress ?? 0.0;
}
