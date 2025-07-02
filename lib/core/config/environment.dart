enum Environment { development, staging, production }

class EnvironmentConfig {
  final String name;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final String firebaseProjectId;
  final String sentryDsn;
  final bool enableLogging;
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final Map<String, dynamic> paymentConfig;
  final Map<String, dynamic> features;

  const EnvironmentConfig({
    required this.name,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.firebaseProjectId,
    required this.sentryDsn,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.paymentConfig,
    required this.features,
  });

  // Development Environment
  static const EnvironmentConfig development = EnvironmentConfig(
    name: 'Development',
    apiBaseUrl:
        'https://9548-2001-448a-10b0-5eb1-c1e9-2d8d-c8d4-4452.ngrok-free.app',
    wsBaseUrl: 'wss://dev-ws.iprofit.com',
    firebaseProjectId: 'iprofit-dev',
    sentryDsn: '', // Empty for development
    enableLogging: true,
    enableCrashReporting: false,
    enableAnalytics: false,
    paymentConfig: {
      'coingate': {
        'environment': 'sandbox',
        'authToken': 'dev-token-here',
        'testMode': true,
      },
      'uddoktapay': {
        'environment': 'sandbox',
        'apiKey': 'dev-key-here',
        'apiSecret': 'dev-secret-here',
        'testMode': true,
      },
    },
    features: {
      'enableMockData': true,
      'enableDebugMode': true,
      'enableDevTools': true,
      'enablePerformanceOverlay': false,
      'enableNetworkLogging': true,
      'skipAuthentication': false,
      'enableBiometrics': true,
      'enablePushNotifications': false,
      'enableLocationServices': false,
      'enableCameraAccess': true,
      'enableFileAccess': true,
      'maxUploadSize': 10 * 1024 * 1024, // 10MB
      'cacheExpiration': 300, // 5 minutes
      'apiTimeout': 60, // 60 seconds
    },
  );

  // Staging Environment
  static const EnvironmentConfig staging = EnvironmentConfig(
    name: 'Staging',
    apiBaseUrl: 'https://staging-api.iprofit.com',
    wsBaseUrl: 'wss://staging-ws.iprofit.com',
    firebaseProjectId: 'iprofit-staging',
    sentryDsn: 'https://your-sentry-dsn-for-staging@sentry.io/project-id',
    enableLogging: true,
    enableCrashReporting: true,
    enableAnalytics: false,
    paymentConfig: {
      'coingate': {
        'environment': 'sandbox',
        'authToken': 'staging-token-here',
        'testMode': true,
      },
      'uddoktapay': {
        'environment': 'sandbox',
        'apiKey': 'staging-key-here',
        'apiSecret': 'staging-secret-here',
        'testMode': true,
      },
    },
    features: {
      'enableMockData': false,
      'enableDebugMode': true,
      'enableDevTools': true,
      'enablePerformanceOverlay': false,
      'enableNetworkLogging': true,
      'skipAuthentication': false,
      'enableBiometrics': true,
      'enablePushNotifications': true,
      'enableLocationServices': false,
      'enableCameraAccess': true,
      'enableFileAccess': true,
      'maxUploadSize': 10 * 1024 * 1024, // 10MB
      'cacheExpiration': 600, // 10 minutes
      'apiTimeout': 45, // 45 seconds
    },
  );

  // Production Environment
  static const EnvironmentConfig production = EnvironmentConfig(
    name: 'Production',
    apiBaseUrl: 'https://api.iprofit.com',
    wsBaseUrl: 'wss://ws.iprofit.com',
    firebaseProjectId: 'iprofit-prod',
    sentryDsn: 'https://your-sentry-dsn-for-production@sentry.io/project-id',
    enableLogging: false,
    enableCrashReporting: true,
    enableAnalytics: true,
    paymentConfig: {
      'coingate': {
        'environment': 'live',
        'authToken': 'prod-token-here',
        'testMode': false,
      },
      'uddoktapay': {
        'environment': 'live',
        'apiKey': 'prod-key-here',
        'apiSecret': 'prod-secret-here',
        'testMode': false,
      },
    },
    features: {
      'enableMockData': false,
      'enableDebugMode': false,
      'enableDevTools': false,
      'enablePerformanceOverlay': false,
      'enableNetworkLogging': false,
      'skipAuthentication': false,
      'enableBiometrics': true,
      'enablePushNotifications': true,
      'enableLocationServices': true,
      'enableCameraAccess': true,
      'enableFileAccess': true,
      'maxUploadSize': 50 * 1024 * 1024, // 50MB
      'cacheExpiration': 3600, // 1 hour
      'apiTimeout': 30, // 30 seconds
    },
  );

  // Helper methods
  bool get isProduction => name == 'Production';
  bool get isStaging => name == 'Staging';
  bool get isDevelopment => name == 'Development';

  // Get feature flag value
  T getFeature<T>(String key, T defaultValue) {
    return features[key] as T? ?? defaultValue;
  }

  // Get payment gateway configuration
  Map<String, dynamic>? getPaymentConfig(String gateway) {
    return paymentConfig[gateway.toLowerCase()] as Map<String, dynamic>?;
  }

  // Get API endpoint with base URL
  String getApiEndpoint(String path) {
    return '$apiBaseUrl$path';
  }

  // Get WebSocket endpoint with base URL
  String getWsEndpoint(String path) {
    return '$wsBaseUrl$path';
  }

  // Environment-specific configurations
  Duration get apiTimeout => Duration(seconds: getFeature('apiTimeout', 30));
  Duration get cacheExpiration =>
      Duration(seconds: getFeature('cacheExpiration', 3600));
  int get maxUploadSize => getFeature('maxUploadSize', 10 * 1024 * 1024);

  // Security configurations
  Map<String, dynamic> get securityConfig => {
    'enableSSLPinning': isProduction,
    'enableCertificateTransparency': isProduction,
    'enableJailbreakDetection': isProduction,
    'enableRootDetection': isProduction,
    'enableTamperDetection': isProduction,
    'enableDebuggerDetection': isProduction,
    'enableHookDetection': isProduction,
    'minTlsVersion': '1.2',
    'allowSelfSignedCertificates': isDevelopment,
  };

  // Analytics configurations
  Map<String, dynamic> get analyticsConfig => {
    'enableFirebaseAnalytics': enableAnalytics,
    'enableCrashlytics': enableCrashReporting,
    'enablePerformanceMonitoring': isProduction,
    'enableCustomEvents': true,
    'enableScreenTracking': true,
    'enableUserProperties': true,
    'sessionTimeoutDuration': 1800, // 30 minutes
    'enableAutomaticScreenTracking': true,
  };

  // Notification configurations
  Map<String, dynamic> get notificationConfig => {
    'enablePushNotifications': getFeature('enablePushNotifications', true),
    'enableLocalNotifications': true,
    'enableInAppNotifications': true,
    'enableEmailNotifications': true,
    'enableSmsNotifications': isProduction,
    'notificationChannels': {
      'general': {
        'id': 'general',
        'name': 'General Notifications',
        'description': 'General app notifications',
        'importance': 'high',
      },
      'transactions': {
        'id': 'transactions',
        'name': 'Transaction Notifications',
        'description': 'Wallet and transaction updates',
        'importance': 'high',
      },
      'security': {
        'id': 'security',
        'name': 'Security Alerts',
        'description': 'Security and login alerts',
        'importance': 'max',
      },
      'marketing': {
        'id': 'marketing',
        'name': 'Marketing',
        'description': 'Promotional notifications',
        'importance': 'default',
      },
    },
  };

  // Storage configurations
  Map<String, dynamic> get storageConfig => {
    'enableEncryption': true,
    'encryptionKeySize': 256,
    'enableBiometricProtection': true,
    'enableAutoBackup': isProduction,
    'maxCacheSize': 100 * 1024 * 1024, // 100MB
    'enableOfflineMode': true,
    'syncInterval': isProduction
        ? 300
        : 60, // 5 minutes in prod, 1 minute in dev
  };

  @override
  String toString() {
    return 'EnvironmentConfig(name: $name, apiBaseUrl: $apiBaseUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnvironmentConfig && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
