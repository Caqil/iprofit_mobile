/// Storage keys for SharedPreferences and Secure Storage
/// This class contains all the keys used for local storage to maintain consistency
/// and avoid typos throughout the application.
class StorageKeys {
  // Private constructor to prevent instantiation
  StorageKeys._();

  // ===== AUTHENTICATION KEYS =====
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastLoginTime = 'last_login_time';
  static const String loginAttempts = 'login_attempts';
  static const String lockoutTime = 'lockout_time';
  static const String rememberMe = 'remember_me';
  static const String biometricEnabled = 'biometric_enabled';
  static const String pinCode = 'pin_code';
  static const String autoLockEnabled = 'auto_lock_enabled';
  static const String autoLockDuration = 'auto_lock_duration';
  static const String sessionId = 'session_id';

  // ===== USER DATA KEYS =====
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String userPhone = 'user_phone';
  static const String userProfilePicture = 'user_profile_picture';
  static const String userBalance = 'user_balance';
  static const String userStatus = 'user_status';
  static const String userKycStatus = 'user_kyc_status';
  static const String userReferralCode = 'user_referral_code';
  static const String userPlan = 'user_plan';
  static const String userPreferences = 'user_preferences';
  static const String userAddress = 'user_address';
  static const String userDateOfBirth = 'user_date_of_birth';
  static const String emailVerified = 'email_verified';
  static const String phoneVerified = 'phone_verified';
  static const String twoFactorEnabled = 'two_factor_enabled';

  // ===== DEVICE INFORMATION KEYS =====
  static const String deviceId = 'device_id';
  static const String deviceFingerprint = 'device_fingerprint';
  static const String deviceName = 'device_name';
  static const String deviceModel = 'device_model';
  static const String deviceBrand = 'device_brand';
  static const String deviceOs = 'device_os';
  static const String deviceOsVersion = 'device_os_version';
  static const String appVersion = 'app_version';
  static const String firstInstallTime = 'first_install_time';
  static const String lastUpdateTime = 'last_update_time';
  static const String fcmToken = 'fcm_token';
  static const String fcmTokenRegistered = 'fcm_token_registered';

  // ===== APP PREFERENCES KEYS =====
  static const String language = 'language';
  static const String currency = 'currency';
  static const String theme = 'theme';
  static const String isFirstLaunch = 'is_first_launch';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String lastSyncTime = 'last_sync_time';
  static const String offlineMode = 'offline_mode';
  static const String cacheEnabled = 'cache_enabled';
  static const String analyticsEnabled = 'analytics_enabled';
  static const String crashReportingEnabled = 'crash_reporting_enabled';

  // ===== NOTIFICATION PREFERENCES KEYS =====
  static const String notificationsEnabled = 'notifications_enabled';
  static const String pushNotificationsEnabled = 'push_notifications_enabled';
  static const String emailNotificationsEnabled = 'email_notifications_enabled';
  static const String smsNotificationsEnabled = 'sms_notifications_enabled';
  static const String inAppNotificationsEnabled =
      'in_app_notifications_enabled';
  static const String notificationKyc = 'notification_kyc';
  static const String notificationTransactions = 'notification_transactions';
  static const String notificationLoans = 'notification_loans';
  static const String notificationReferrals = 'notification_referrals';
  static const String notificationTasks = 'notification_tasks';
  static const String notificationSystem = 'notification_system';
  static const String notificationMarketing = 'notification_marketing';
  static const String notificationSecurity = 'notification_security';
  static const String notificationSound = 'notification_sound';
  static const String notificationVibration = 'notification_vibration';

  // ===== SECURITY PREFERENCES KEYS =====
  static const String passwordChangedAt = 'password_changed_at';
  static const String securityQuestionsSet = 'security_questions_set';
  static const String loginNotifications = 'login_notifications';
  static const String suspiciousActivityAlerts = 'suspicious_activity_alerts';
  static const String deviceRegistrationNotifications =
      'device_registration_notifications';
  static const String sessionTimeout = 'session_timeout';
  static const String requirePinForTransactions =
      'require_pin_for_transactions';
  static const String requireBiometricForLogin = 'require_biometric_for_login';

  // ===== PRIVACY PREFERENCES KEYS =====
  static const String profileVisibility = 'profile_visibility';
  static const String showBalance = 'show_balance';
  static const String showTransactions = 'show_transactions';
  static const String showReferrals = 'show_referrals';
  static const String allowContact = 'allow_contact';
  static const String dataUsageOptIn = 'data_usage_opt_in';
  static const String marketingOptIn = 'marketing_opt_in';

  // ===== DASHBOARD PREFERENCES KEYS =====
  static const String dashboardLayout = 'dashboard_layout';
  static const String quickActionsEnabled = 'quick_actions_enabled';
  static const String portfolioWidgetEnabled = 'portfolio_widget_enabled';
  static const String recentTransactionsCount = 'recent_transactions_count';
  static const String balanceVisibility = 'balance_visibility';
  static const String refreshInterval = 'refresh_interval';

  // ===== WALLET PREFERENCES KEYS =====
  static const String preferredCurrency = 'preferred_currency';
  static const String autoConvertCurrency = 'auto_convert_currency';
  static const String transactionLimit = 'transaction_limit';
  static const String dailyLimit = 'daily_limit';
  static const String weeklyLimit = 'weekly_limit';
  static const String monthlyLimit = 'monthly_limit';
  static const String defaultGateway = 'default_gateway';
  static const String savedPaymentMethods = 'saved_payment_methods';

  // ===== CACHE KEYS =====
  static const String cachedDashboardData = 'cached_dashboard_data';
  static const String cachedWalletHistory = 'cached_wallet_history';
  static const String cachedPortfolioData = 'cached_portfolio_data';
  static const String cachedTasksList = 'cached_tasks_list';
  static const String cachedReferralData = 'cached_referral_data';
  static const String cachedNotifications = 'cached_notifications';
  static const String cachedUserProfile = 'cached_user_profile';
  static const String cachedKycStatus = 'cached_kyc_status';
  static const String cachedLoansData = 'cached_loans_data';
  static const String cacheExpiry = 'cache_expiry';
  static const String lastCacheCleanup = 'last_cache_cleanup';

  // ===== TEMPORARY DATA KEYS =====
  static const String tempRegistrationData = 'temp_registration_data';
  static const String tempKycData = 'temp_kyc_data';
  static const String tempLoanApplication = 'temp_loan_application';
  static const String tempTaskSubmission = 'temp_task_submission';
  static const String tempDepositData = 'temp_deposit_data';
  static const String tempWithdrawalData = 'temp_withdrawal_data';
  static const String draftSupportTicket = 'draft_support_ticket';

  // ===== SYNC STATUS KEYS =====
  static const String lastProfileSync = 'last_profile_sync';
  static const String lastTransactionSync = 'last_transaction_sync';
  static const String lastPortfolioSync = 'last_portfolio_sync';
  static const String lastNotificationSync = 'last_notification_sync';
  static const String lastKycSync = 'last_kyc_sync';
  static const String lastTaskSync = 'last_task_sync';
  static const String pendingSyncOperations = 'pending_sync_operations';
  static const String syncInProgress = 'sync_in_progress';

  // ===== FEATURE FLAGS KEYS =====
  static const String featureBiometrics = 'feature_biometrics';
  static const String featurePushNotifications = 'feature_push_notifications';
  static const String featureAnalytics = 'feature_analytics';
  static const String featureCrashReporting = 'feature_crash_reporting';
  static const String featureOfflineMode = 'feature_offline_mode';
  static const String featureAutoSync = 'feature_auto_sync';
  static const String featureAdvancedSecurity = 'feature_advanced_security';

  // ===== TUTORIAL & HELP KEYS =====
  static const String tutorialCompleted = 'tutorial_completed';
  static const String dashboardTutorialShown = 'dashboard_tutorial_shown';
  static const String walletTutorialShown = 'wallet_tutorial_shown';
  static const String portfolioTutorialShown = 'portfolio_tutorial_shown';
  static const String kycTutorialShown = 'kyc_tutorial_shown';
  static const String tasksTutorialShown = 'tasks_tutorial_shown';
  static const String referralsTutorialShown = 'referrals_tutorial_shown';
  static const String helpTooltipsEnabled = 'help_tooltips_enabled';

  // ===== ANALYTICS KEYS =====
  static const String analyticsUserId = 'analytics_user_id';
  static const String analyticsSessionId = 'analytics_session_id';
  static const String analyticsInstallationId = 'analytics_installation_id';
  static const String lastAnalyticsSync = 'last_analytics_sync';
  static const String analyticsOptOut = 'analytics_opt_out';

  // ===== DEBUG & DEVELOPMENT KEYS =====
  static const String debugMode = 'debug_mode';
  static const String logsEnabled = 'logs_enabled';
  static const String networkLogsEnabled = 'network_logs_enabled';
  static const String performanceMonitoringEnabled =
      'performance_monitoring_enabled';
  static const String mockDataEnabled = 'mock_data_enabled';
  static const String skipApiCalls = 'skip_api_calls';

  // ===== BACKUP & RESTORE KEYS =====
  static const String lastBackupTime = 'last_backup_time';
  static const String backupEnabled = 'backup_enabled';
  static const String autoBackupEnabled = 'auto_backup_enabled';
  static const String backupFrequency = 'backup_frequency';
  static const String cloudBackupEnabled = 'cloud_backup_enabled';

  // ===== EXPERIMENTAL FEATURES KEYS =====
  static const String experimentalFeaturesEnabled =
      'experimental_features_enabled';
  static const String betaFeaturesOptIn = 'beta_features_opt_in';
  static const String experimentalDashboard = 'experimental_dashboard';
  static const String experimentalPortfolio = 'experimental_portfolio';
  static const String experimentalSecurity = 'experimental_security';

  // ===== UTILITY METHODS =====

  /// Get all authentication related keys
  static List<String> getAuthKeys() {
    return [
      accessToken,
      refreshToken,
      tokenExpiry,
      isLoggedIn,
      lastLoginTime,
      loginAttempts,
      lockoutTime,
      rememberMe,
      biometricEnabled,
      pinCode,
      autoLockEnabled,
      autoLockDuration,
      sessionId,
    ];
  }

  /// Get all user data related keys
  static List<String> getUserDataKeys() {
    return [
      userId,
      userEmail,
      userName,
      userPhone,
      userProfilePicture,
      userBalance,
      userStatus,
      userKycStatus,
      userReferralCode,
      userPlan,
      userPreferences,
      userAddress,
      userDateOfBirth,
      emailVerified,
      phoneVerified,
      twoFactorEnabled,
    ];
  }

  /// Get all cache related keys
  static List<String> getCacheKeys() {
    return [
      cachedDashboardData,
      cachedWalletHistory,
      cachedPortfolioData,
      cachedTasksList,
      cachedReferralData,
      cachedNotifications,
      cachedUserProfile,
      cachedKycStatus,
      cachedLoansData,
      cacheExpiry,
      lastCacheCleanup,
    ];
  }

  /// Get all temporary data keys
  static List<String> getTempDataKeys() {
    return [
      tempRegistrationData,
      tempKycData,
      tempLoanApplication,
      tempTaskSubmission,
      tempDepositData,
      tempWithdrawalData,
      draftSupportTicket,
    ];
  }

  /// Get all preference keys
  static List<String> getPreferenceKeys() {
    return [
      language,
      currency,
      theme,
      isFirstLaunch,
      onboardingCompleted,
      lastSyncTime,
      offlineMode,
      cacheEnabled,
      analyticsEnabled,
      crashReportingEnabled,
      ...getNotificationPreferenceKeys(),
      ...getSecurityPreferenceKeys(),
      ...getPrivacyPreferenceKeys(),
    ];
  }

  /// Get all notification preference keys
  static List<String> getNotificationPreferenceKeys() {
    return [
      notificationsEnabled,
      pushNotificationsEnabled,
      emailNotificationsEnabled,
      smsNotificationsEnabled,
      inAppNotificationsEnabled,
      notificationKyc,
      notificationTransactions,
      notificationLoans,
      notificationReferrals,
      notificationTasks,
      notificationSystem,
      notificationMarketing,
      notificationSecurity,
      notificationSound,
      notificationVibration,
    ];
  }

  /// Get all security preference keys
  static List<String> getSecurityPreferenceKeys() {
    return [
      passwordChangedAt,
      securityQuestionsSet,
      loginNotifications,
      suspiciousActivityAlerts,
      deviceRegistrationNotifications,
      sessionTimeout,
      requirePinForTransactions,
      requireBiometricForLogin,
    ];
  }

  /// Get all privacy preference keys
  static List<String> getPrivacyPreferenceKeys() {
    return [
      profileVisibility,
      showBalance,
      showTransactions,
      showReferrals,
      allowContact,
      dataUsageOptIn,
      marketingOptIn,
    ];
  }

  /// Get all sensitive keys that should be stored in secure storage
  static List<String> getSensitiveKeys() {
    return [
      accessToken,
      refreshToken,
      pinCode,
      userEmail,
      userPhone,
      deviceFingerprint,
      fcmToken,
    ];
  }

  /// Get all keys that should be cleared on logout
  static List<String> getLogoutClearKeys() {
    return [
      ...getAuthKeys(),
      ...getUserDataKeys(),
      ...getCacheKeys(),
      ...getTempDataKeys(),
      fcmTokenRegistered,
      analyticsUserId,
      analyticsSessionId,
    ];
  }

  /// Check if a key should be stored in secure storage
  static bool shouldUseSecureStorage(String key) {
    return getSensitiveKeys().contains(key);
  }

  /// Check if a key should be cleared on logout
  static bool shouldClearOnLogout(String key) {
    return getLogoutClearKeys().contains(key);
  }

  /// Get all debug and development keys
  static List<String> getDebugKeys() {
    return [
      debugMode,
      logsEnabled,
      networkLogsEnabled,
      performanceMonitoringEnabled,
      mockDataEnabled,
      skipApiCalls,
    ];
  }

  /// Get all feature flag keys
  static List<String> getFeatureFlagKeys() {
    return [
      featureBiometrics,
      featurePushNotifications,
      featureAnalytics,
      featureCrashReporting,
      featureOfflineMode,
      featureAutoSync,
      featureAdvancedSecurity,
    ];
  }
}
