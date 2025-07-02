import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iprofit_mobile/data/services/notification_service.dart';
import 'package:iprofit_mobile/data/services/storage_service.dart';
import 'environment.dart';
import '../utils/device_utils.dart';

class AppConfig {
  static Environment _environment = Environment.development;
  static bool _isInitialized = false;

  // App Info
  static const String appName = 'IProfit';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String packageName = 'com.iprofit.mobile';

  // Environment Configuration
  static Environment get environment => _environment;
  static bool get isInitialized => _isInitialized;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Feature Flags
  static bool get enableBiometrics => true;
  static bool get enablePushNotifications => true;
  static bool get enableDeviceFingerprinting => true;
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashlytics => isProduction;
  static bool get enablePerformanceMonitoring => isProduction;
  static bool get enableDebugLogging => !isProduction;

  // Security Configuration
  static const int sessionTimeoutMinutes = 30;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int pinCodeLength = 6;
  static const int otpLength = 6;
  static const Duration otpValidityDuration = Duration(minutes: 5);

  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  static const int maxFileUploads = 5;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration imageCacheExpiry = Duration(days: 7);

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const Duration rateLimitWindow = Duration(minutes: 1);

  // Currency Configuration
  static const String defaultCurrency = 'USD';
  static const List<String> supportedCurrencies = ['USD', 'BDT'];
  static const Map<String, String> currencySymbols = {'USD': '\$', 'BDT': '৳'};

  // Language Configuration
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'bn'];

  // Theme Configuration
  static const String defaultTheme = 'system';
  static const List<String> availableThemes = ['light', 'dark', 'system'];

  // Payment Gateway Configuration
  static const List<String> supportedPaymentGateways = [
    'CoinGate',
    'UddoktaPay',
    'Manual',
  ];

  // Minimum amounts for operations
  static const double minDepositAmount = 10.0;
  static const double maxDepositAmount = 100000.0;
  static const double minWithdrawalAmount = 100.0;
  static const double maxWithdrawalAmount = 100000.0;
  static const double minLoanAmount = 100.0;
  static const double maxLoanAmount = 50000.0;

  // Initialize the application
  static Future<void> initialize({Environment? env}) async {
    try {
      // Set environment
      _environment = env ?? _determineEnvironment();

      // Initialize Firebase
      if (!Firebase.apps.isNotEmpty) {
        await Firebase.initializeApp();
      }

      // Initialize services
      await StorageService.initialize();
      await NotificationService.initialize();

      // Initialize device utilities
      await DeviceUtils.getDeviceId();
      await DeviceUtils.getDeviceFingerprint();

      // Set initialization flag
      _isInitialized = true;

      if (enableDebugLogging) {
        debugPrint(
          'AppConfig: Initialized successfully for ${_environment.name}',
        );
      }
    } catch (e) {
      debugPrint('AppConfig: Initialization failed: $e');
      rethrow;
    }
  }

  // Determine environment based on build mode
  static Environment _determineEnvironment() {
    if (kDebugMode) {
      return Environment.development;
    } else if (kProfileMode) {
      return Environment.staging;
    } else {
      return Environment.production;
    }
  }

  // Get current environment configuration
  static EnvironmentConfig get currentConfig {
    switch (_environment) {
      case Environment.development:
        return EnvironmentConfig.development;
      case Environment.staging:
        return EnvironmentConfig.staging;
      case Environment.production:
        return EnvironmentConfig.production;
    }
  }

  // Get API base URL for current environment
  static String get baseUrl => currentConfig.apiBaseUrl;

  // Get WebSocket URL for current environment
  static String get wsUrl => currentConfig.wsBaseUrl;

  // Get app environment display name
  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  // Check if feature is enabled
  static bool isFeatureEnabled(String feature) {
    switch (feature) {
      case 'biometrics':
        return enableBiometrics;
      case 'push_notifications':
        return enablePushNotifications;
      case 'device_fingerprinting':
        return enableDeviceFingerprinting;
      case 'analytics':
        return enableAnalytics;
      case 'crashlytics':
        return enableCrashlytics;
      case 'performance_monitoring':
        return enablePerformanceMonitoring;
      case 'debug_logging':
        return enableDebugLogging;
      default:
        return false;
    }
  }

  // Get user agent string
  static String get userAgent {
    return 'IProfit-Flutter/$appVersion ($environmentName; ${DeviceUtils.getPlatformName()})';
  }

  // Validate file type
  static bool isValidFileType(String fileName, String category) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (category) {
      case 'image':
        return allowedImageTypes.contains(extension);
      case 'document':
        return allowedDocumentTypes.contains(extension);
      default:
        return [
          ...allowedImageTypes,
          ...allowedDocumentTypes,
        ].contains(extension);
    }
  }

  // Get currency symbol
  static String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode.toUpperCase()] ?? currencyCode;
  }

  // Check if currency is supported
  static bool isSupportedCurrency(String currencyCode) {
    return supportedCurrencies.contains(currencyCode.toUpperCase());
  }

  // Get supported payment gateways for currency
  static List<String> getPaymentGatewaysForCurrency(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return ['CoinGate', 'Manual'];
      case 'BDT':
        return ['UddoktaPay', 'Manual'];
      default:
        return ['Manual'];
    }
  }

  // Reset configuration (for testing)
  static void reset() {
    _isInitialized = false;
    _environment = Environment.development;
  }
}
