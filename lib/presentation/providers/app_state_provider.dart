import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/network_info.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/biometric_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/auth/user_model.dart';

part 'app_state_provider.g.dart';

// ============================================================================
// APP STATE MODEL
// ============================================================================

/// Main application state model
class AppState {
  final bool isInitialized;
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? currentUser;
  final ThemeMode themeMode;
  final String language;
  final String currency;
  final bool isOnline;
  final bool isOfflineModeEnabled;
  final bool biometricsEnabled;
  final bool notificationsEnabled;
  final AppError? error;
  final Map<String, dynamic> userPreferences;
  final DateTime? lastSyncTime;

  const AppState({
    this.isInitialized = false,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.currentUser,
    this.themeMode = ThemeMode.system,
    this.language = AppConstants.defaultLanguage,
    this.currency = 'USD',
    this.isOnline = true,
    this.isOfflineModeEnabled = false,
    this.biometricsEnabled = false,
    this.notificationsEnabled = false,
    this.error,
    this.userPreferences = const {},
    this.lastSyncTime,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? currentUser,
    ThemeMode? themeMode,
    String? language,
    String? currency,
    bool? isOnline,
    bool? isOfflineModeEnabled,
    bool? biometricsEnabled,
    bool? notificationsEnabled,
    AppError? error,
    Map<String, dynamic>? userPreferences,
    DateTime? lastSyncTime,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      isOnline: isOnline ?? this.isOnline,
      isOfflineModeEnabled: isOfflineModeEnabled ?? this.isOfflineModeEnabled,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      error: error,
      userPreferences: userPreferences ?? this.userPreferences,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemMode => themeMode == ThemeMode.system;
  bool get hasError => error != null;
  bool get canUseOfflineFeatures => isOfflineModeEnabled && !isOnline;
}

/// App error model
class AppError {
  final String message;
  final String? code;
  final dynamic details;
  final DateTime timestamp;

  AppError({
    required this.message,
    this.code,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AppError.fromException(AppException exception) {
    return AppError(
      message: exception.userMessage,
      code: exception.runtimeType.toString(),
      details: exception.toString(),
    );
  }
}

// ============================================================================
// MAIN APP STATE PROVIDER
// ============================================================================

@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  Timer? _syncTimer;
  StreamSubscription? _authSubscription;
  ProviderSubscription? _networkSubscription;
  StreamSubscription? _notificationSubscription;

  @override
  AppState build() {
    _initializeApp();
    return const AppState();
  }

  // ===== INITIALIZATION =====

  /// Initialize the application
  Future<void> _initializeApp() async {
    try {
      state = state.copyWith(isLoading: true);

      // Load saved preferences
      await _loadSavedPreferences();

      // Initialize connectivity monitoring
      await _initializeConnectivity();

      // Check authentication status
      await _checkAuthenticationStatus();

      // Initialize biometrics
      await _initializeBiometrics();

      // Initialize notifications
      await _initializeNotifications();

      // Set up listeners
     // _setupListeners();

      // Start background sync
      _startBackgroundSync();

      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: AppError(
          message: 'Failed to initialize app: ${e.toString()}',
          details: e,
        ),
      );
    }
  }

  /// Load saved user preferences
  Future<void> _loadSavedPreferences() async {
    try {
      // Load theme
      final savedTheme = await StorageService.getString(StorageKeys.theme);
      final themeMode = _parseThemeMode(savedTheme);

      // Load language
      final language =
          await StorageService.getString(StorageKeys.language) ??
          AppConstants.defaultLanguage;

      // Load currency
      final currency =
          await StorageService.getString(StorageKeys.currency) ?? 'USD';

      // Load offline mode setting
      final offlineMode =
          await StorageService.getBool(StorageKeys.offlineMode) ?? false;

      // Load other preferences
      final preferences = <String, dynamic>{};
      for (final key in StorageKeys.getPreferenceKeys()) {
        final value = await StorageService.getString(key);
        if (value != null) {
          preferences[key] = value;
        }
      }

      state = state.copyWith(
        themeMode: themeMode,
        language: language,
        currency: currency,
        isOfflineModeEnabled: offlineMode,
        userPreferences: preferences,
      );
    } catch (e) {
      // Use defaults if loading fails
    }
  }

  /// Check authentication status on app start
  Future<void> _checkAuthenticationStatus() async {
    try {
      final authService = ref.read(authServiceProvider);
      final isAuthenticated = await authService.checkAuthStatus();

      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        currentUser: authService.currentUser,
      );
    } catch (e) {
      state = state.copyWith(isAuthenticated: false);
    }
  }

  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivity() async {
    try {
      final networkInfo = ref.read(networkInfoStateProvider);
      state = state.copyWith(isOnline: networkInfo.isConnected);
    } catch (e) {
      // Default to online if check fails
      state = state.copyWith(isOnline: true);
    }
  }

  /// Initialize biometric settings
  Future<void> _initializeBiometrics() async {
    try {
      final biometricService = ref.read(biometricServiceProvider);
      await biometricService.initialize();

      final isEnabled = await biometricService.isBiometricEnabled();
      state = state.copyWith(biometricsEnabled: isEnabled);
    } catch (e) {
      state = state.copyWith(biometricsEnabled: false);
    }
  }

  /// Initialize notification settings
  Future<void> _initializeNotifications() async {
    try {
      // final isEnabled = await NotificationService.areNotificationsEnabled();
      // state = state.copyWith(notificationsEnabled: isEnabled);
    } catch (e) {
      state = state.copyWith(notificationsEnabled: false);
    }
  }

  // ===== LISTENERS SETUP =====

  /// Set up real-time listeners for state changes
  // void _setupListeners() {
  //   // Listen to authentication changes
  //   final authService = ref.read(authServiceProvider);
  //   _authSubscription = authService.authStateStream.listen((authState) {
  //     final isAuthenticated = authState == AuthState.authenticated;
  //     state = state.copyWith(
  //       isAuthenticated: isAuthenticated,
  //       currentUser: isAuthenticated ? authService.currentUser : null,
  //     );
  //   });

  //   // Listen to user changes
  //   authService.userStream.listen((user) {
  //     state = state.copyWith(currentUser: user);
  //   });

  //   // Listen to network changes
  //   _networkSubscription = ref.listen(networkInfoStateProvider, (
  //     previous,
  //     next,
  //   ) {
  //     state = state.copyWith(isOnline: next.isConnected);
  //   });

  //   // Listen to notification changes
  //   final notificationService = ref.read(notificationServiceProvider);
  //   _notificationSubscription = notificationService.notificationStream.listen((
  //     notification,
  //   ) {
  //     // Handle incoming notifications
  //     _handleIncomingNotification(notification);
  //   });

  //   // Dispose listeners when provider is disposed
  //   ref.onDispose(() {
  //     _authSubscription?.cancel();
  //     _notificationSubscription?.cancel();
  //     _syncTimer?.cancel();
  //   });
  // }

  // ===== APP SETTINGS MANAGEMENT =====

  /// Update theme mode
  Future<void> updateTheme(ThemeMode themeMode) async {
    try {
      await StorageService.setString(StorageKeys.theme, themeMode.name);
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      _setError('Failed to update theme');
    }
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    try {
      await StorageService.setString(StorageKeys.language, language);
      state = state.copyWith(language: language);
    } catch (e) {
      _setError('Failed to update language');
    }
  }

  /// Update currency
  Future<void> updateCurrency(String currency) async {
    try {
      await StorageService.setString(StorageKeys.currency, currency);
      state = state.copyWith(currency: currency);
    } catch (e) {
      _setError('Failed to update currency');
    }
  }

  /// Toggle offline mode
  Future<void> toggleOfflineMode() async {
    try {
      final newValue = !state.isOfflineModeEnabled;
      await StorageService.setBool(StorageKeys.offlineMode, newValue);
      state = state.copyWith(isOfflineModeEnabled: newValue);
    } catch (e) {
      _setError('Failed to toggle offline mode');
    }
  }

  /// Update biometric settings
  Future<void> toggleBiometrics() async {
    try {
      final biometricService = ref.read(biometricServiceProvider);
      final newValue = await biometricService.toggleBiometric();
      state = state.copyWith(biometricsEnabled: newValue);
    } catch (e) {
      _setError('Failed to toggle biometrics');
    }
  }

  /// Update notification settings
  // Future<void> toggleNotifications() async {
  //   try {
  //     final currentValue = state.notificationsEnabled;
  //     final newValue = await NotificationService.requestPermissions();

  //     if (newValue != currentValue) {
  //       await StorageService.setBool(
  //         StorageKeys.notificationsEnabled,
  //         newValue,
  //       );
  //       state = state.copyWith(notificationsEnabled: newValue);
  //     }
  //   } catch (e) {
  //     _setError('Failed to toggle notifications');
  //   }
  // }

  // ===== DATA SYNCHRONIZATION =====

  /// Start background sync for app data
  void _startBackgroundSync() {
    if (!AppConfig.isProduction) return; // Only in production

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (state.isAuthenticated && state.isOnline) {
        _performBackgroundSync();
      }
    });
  }

  /// Perform background data synchronization
  Future<void> _performBackgroundSync() async {
    try {
      if (!state.isAuthenticated || !state.isOnline) return;

      // Update last sync time
      final now = DateTime.now();
      await StorageService.setString(
        StorageKeys.lastSyncTime,
        now.toIso8601String(),
      );

      state = state.copyWith(lastSyncTime: now);

      // Perform specific sync operations
      await _syncUserData();
     // await _syncNotifications();
    } catch (e) {
      // Silent fail for background sync
    }
  }

  /// Sync user data
  Future<void> _syncUserData() async {
    try {
      final authService = ref.read(authServiceProvider);
      if (authService.currentUser != null) {
        // Refresh user data from server
        // This could be expanded to sync specific user data
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Sync notifications
  // Future<void> _syncNotifications() async {
  //   try {
  //     // Re-register FCM token if needed
  //     await NotificationService.registerFcmToken();
  //   } catch (e) {
  //     // Silent fail
  //   }
  // }

  // ===== ERROR HANDLING =====

  /// Set error state
  void _setError(String message, {String? code, dynamic details}) {
    state = state.copyWith(
      error: AppError(message: message, code: code, details: details),
    );
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  // ===== UTILITY METHODS =====

  /// Handle incoming notifications
  void _handleIncomingNotification(dynamic notification) {
    // Process notification based on type
    // Update relevant app state if needed
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String? theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Force refresh app state
  Future<void> refresh() async {
    await _initializeApp();
  }

  /// Reset app to initial state (logout)
  Future<void> reset() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      // Reset state to defaults
      state = const AppState(isInitialized: true);

      // Reload preferences
      await _loadSavedPreferences();
    } catch (e) {
      _setError('Failed to reset app state');
    }
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Convenience provider for app state
@riverpod
AppState appState(Ref ref) {
  return ref.watch(appStateNotifierProvider);
}

/// Provider for checking if app is ready
@riverpod
bool isAppReady(Ref ref) {
  final appState = ref.watch(appStateNotifierProvider);
  return appState.isInitialized && !appState.isLoading;
}

/// Provider for current theme mode
@riverpod
ThemeMode themeMode(Ref ref) {
  return ref.watch(appStateNotifierProvider.select((state) => state.themeMode));
}

/// Provider for authentication status
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(
    appStateNotifierProvider.select((state) => state.isAuthenticated),
  );
}

/// Provider for current user
@riverpod
UserModel? currentUser(Ref ref) {
  return ref.watch(
    appStateNotifierProvider.select((state) => state.currentUser),
  );
}

/// Provider for connectivity status
@riverpod
bool isOnline(Ref ref) {
  return ref.watch(appStateNotifierProvider.select((state) => state.isOnline));
}

/// Provider for error state
@riverpod
AppError? appError(Ref ref) {
  return ref.watch(appStateNotifierProvider.select((state) => state.error));
}

// ============================================================================
// EXTENSION METHODS
// ============================================================================

extension StorageKeysExtension on StorageKeys {
  /// Get all preference keys
  static List<String> getPreferenceKeys() {
    return [
      StorageKeys.language,
      StorageKeys.currency,
      StorageKeys.theme,
      StorageKeys.offlineMode,
      StorageKeys.notificationsEnabled,
      StorageKeys.biometricEnabled,
      // Add other preference keys as needed
    ];
  }
}
