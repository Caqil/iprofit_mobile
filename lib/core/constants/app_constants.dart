import 'package:flutter/material.dart';

class AppConstants {
  // ===== APP INFORMATION =====
  static const String appName = 'IProfit';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;
  static const String packageName = 'com.iprofit.mobile';
  static const String appDescription =
      'Smart Investment & Financial Management Platform';
  static const String companyName = 'IProfit Technologies';
  static const String supportEmail = 'support@iprofit.com';
  static const String websiteUrl = 'https://iprofit.com';

  // ===== UI DIMENSIONS =====

  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(spaceXS);
  static const EdgeInsets paddingSM = EdgeInsets.all(spaceSM);
  static const EdgeInsets paddingMD = EdgeInsets.all(spaceMD);
  static const EdgeInsets paddingLG = EdgeInsets.all(spaceLG);
  static const EdgeInsets paddingXL = EdgeInsets.all(spaceXL);

  // Horizontal Padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: spaceSM,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: spaceMD,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: spaceLG,
  );

  // Vertical Padding
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: spaceSM,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: spaceMD,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: spaceLG,
  );

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 6.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;

  // Border Radius Objects
  static const BorderRadius borderRadiusXS = BorderRadius.all(
    Radius.circular(radiusXS),
  );
  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );
  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadiusXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // Avatar Sizes
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;

  // Button Heights
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;

  // Input Field Heights
  static const double inputHeightSM = 36.0;
  static const double inputHeightMD = 44.0;
  static const double inputHeightLG = 52.0;

  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;

  // ===== FINANCIAL CONSTANTS =====

  // Currency
  static const String defaultCurrency = 'USD';
  static const String secondaryCurrency = 'BDT';
  static const List<String> supportedCurrencies = ['USD', 'BDT'];

  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'BDT': '৳',
    'EUR': '€',
    'GBP': '£',
  };

  static const Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'BDT': 'Bangladeshi Taka',
    'EUR': 'Euro',
    'GBP': 'British Pound',
  };

  // Amount Limits
  static const double minDepositAmount = 10.0;
  static const double maxDepositAmount = 100000.0;
  static const double minWithdrawalAmount = 100.0;
  static const double maxWithdrawalAmount = 100000.0;
  static const double minLoanAmount = 100.0;
  static const double maxLoanAmount = 50000.0;
  static const double minInvestmentAmount = 50.0;
  static const double maxInvestmentAmount = 50000.0;

  // Interest Rates
  static const double minInterestRate = 0.1;
  static const double maxInterestRate = 50.0;
  static const double defaultInterestRate = 12.5;

  // Loan Terms
  static const int minLoanTenure = 3; // months
  static const int maxLoanTenure = 60; // months
  static const int defaultLoanTenure = 12; // months

  // ===== TRANSACTION TYPES =====
  static const String transactionTypeDeposit = 'deposit';
  static const String transactionTypeWithdrawal = 'withdrawal';
  static const String transactionTypeBonus = 'bonus';
  static const String transactionTypeProfit = 'profit';
  static const String transactionTypePenalty = 'penalty';
  static const String transactionTypeReferralBonus = 'referral_bonus';
  static const String transactionTypeTaskReward = 'task_reward';
  static const String transactionTypeInvestment = 'investment';
  static const String transactionTypeLoanDisbursement = 'loan_disbursement';
  static const String transactionTypeLoanRepayment = 'loan_repayment';

  // ===== TRANSACTION STATUSES =====
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusProcessing = 'processing';
  static const String statusFailed = 'failed';
  static const String statusCancelled = 'cancelled';
  static const String statusCompleted = 'completed';

  // ===== KYC DOCUMENT TYPES =====
  static const String kycNationalId = 'national_id';
  static const String kycPassport = 'passport';
  static const String kycDrivingLicense = 'driving_license';
  static const String kycUtilityBill = 'utility_bill';
  static const String kycBankStatement = 'bank_statement';
  static const String kycSelfieWithId = 'selfie_with_id';
  static const String kycAddressProof = 'address_proof';
  static const String kycIncomeProof = 'income_proof';

  // ===== KYC STATUSES =====
  static const String kycStatusPending = 'pending';
  static const String kycStatusApproved = 'approved';
  static const String kycStatusRejected = 'rejected';
  static const String kycStatusIncomplete = 'incomplete';
  static const String kycStatusUnderReview = 'under_review';

  // ===== TASK CATEGORIES =====
  static const String taskCategorySocialMedia = 'Social Media';
  static const String taskCategoryAppInstallation = 'App Installation';
  static const String taskCategorySurvey = 'Survey';
  static const String taskCategoryReview = 'Review';
  static const String taskCategoryReferral = 'Referral';
  static const String taskCategoryVideoWatch = 'Video Watch';
  static const String taskCategoryArticleRead = 'Article Read';
  static const String taskCategoryRegistration = 'Registration';

  // ===== TASK DIFFICULTIES =====
  static const String taskDifficultyEasy = 'easy';
  static const String taskDifficultyMedium = 'medium';
  static const String taskDifficultyHard = 'hard';

  // ===== PAYMENT GATEWAYS =====
  static const String gatewayCoingate = 'CoinGate';
  static const String gatewayUddoktapay = 'UddoktaPay';
  static const String gatewayManual = 'Manual';
  static const String gatewayBankTransfer = 'Bank Transfer';
  static const String gatewayCrypto = 'Cryptocurrency';
  static const String gatewayMobileBanking = 'Mobile Banking';

  // ===== NOTIFICATION TYPES =====
  static const String notificationTypeGeneral = 'general';
  static const String notificationTypeTransaction = 'transaction';
  static const String notificationTypeSecurity = 'security';
  static const String notificationTypeMarketing = 'marketing';
  static const String notificationTypeKyc = 'kyc';
  static const String notificationTypeLoan = 'loan';
  static const String notificationTypeTask = 'task';
  static const String notificationTypeReferral = 'referral';
  static const String notificationTypeSystem = 'system';

  // ===== FILE CONSTANTS =====
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxDocumentSize = 10 * 1024 * 1024; // 10MB

  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];

  static const List<String> allowedImageMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  static const List<String> allowedDocumentMimeTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];

  // ===== SECURITY CONSTANTS =====
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;
  static const int sessionTimeoutMinutes = 30;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int pinCodeLength = 6;
  static const int otpLength = 6;
  static const int otpValidityMinutes = 5;

  // ===== VALIDATION PATTERNS =====
  static const String emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String strongPasswordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$';
  static const String namePattern = r'^[a-zA-Z\s]{2,50}$';
  static const String deviceIdPattern = r'^[a-zA-Z0-9_-]{1,100}$';
  static const String referralCodePattern = r'^[A-Z0-9]{3,20}$';

  // ===== PAGINATION CONSTANTS =====
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 5;

  // ===== CACHE CONSTANTS =====
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration imageCacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // ===== ANIMATION DURATIONS =====
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 1000);

  // ===== LANGUAGE & LOCALE =====
  static const String defaultLanguage = 'en';
  static const String defaultCountry = 'US';
  static const Locale defaultLocale = Locale('en', 'US');

  static const List<String> supportedLanguages = ['en', 'bn'];
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('bn', 'BD'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'bn': 'বাংলা',
  };

  // ===== THEME CONSTANTS =====
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';

  // ===== DATE & TIME FORMATS =====
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // ===== SOCIAL MEDIA PLATFORMS =====
  static const String platformFacebook = 'facebook';
  static const String platformInstagram = 'instagram';
  static const String platformTwitter = 'twitter';
  static const String platformYoutube = 'youtube';
  static const String platformLinkedin = 'linkedin';
  static const String platformTiktok = 'tiktok';
  static const String platformTelegram = 'telegram';
  static const String platformWhatsapp = 'whatsapp';

  // ===== ERROR MESSAGES =====
  static const String errorGeneral = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'No internet connection. Please check your network.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnauthorized =
      'Session expired. Please login again.';
  static const String errorForbidden =
      'You do not have permission to access this resource.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorServerError =
      'Server error. Please try again later.';
  static const String errorValidation =
      'Please check your input and try again.';

  // ===== SUCCESS MESSAGES =====
  static const String successGeneral = 'Operation completed successfully.';
  static const String successLogin = 'Login successful.';
  static const String successRegister = 'Registration successful.';
  static const String successDeposit =
      'Deposit request submitted successfully.';
  static const String successWithdrawal =
      'Withdrawal request submitted successfully.';
  static const String successKycSubmit =
      'KYC documents submitted successfully.';
  static const String successTaskSubmit = 'Task submitted successfully.';
  static const String successPasswordChange = 'Password changed successfully.';

  // ===== APP STORE LINKS =====
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$packageName';
  static const String appStoreUrl = 'https://apps.apple.com/app/id123456789';

  // ===== SOCIAL LINKS =====
  static const String facebookUrl = 'https://facebook.com/iprofit';
  static const String twitterUrl = 'https://twitter.com/iprofit';
  static const String instagramUrl = 'https://instagram.com/iprofit';
  static const String youtubeUrl = 'https://youtube.com/iprofit';
  static const String linkedinUrl = 'https://linkedin.com/company/iprofit';

  // ===== HELP & SUPPORT =====
  static const String helpCenterUrl = 'https://help.iprofit.com';
  static const String privacyPolicyUrl = 'https://iprofit.com/privacy';
  static const String termsOfServiceUrl = 'https://iprofit.com/terms';
  static const String supportPhone = '+1-800-IPROFIT';
  static const String supportWhatsapp = '+1234567890';

  // ===== REGEX PATTERNS =====
  static final RegExp emailRegex = RegExp(emailPattern);
  static final RegExp phoneRegex = RegExp(phonePattern);
  static final RegExp strongPasswordRegex = RegExp(strongPasswordPattern);
  static final RegExp nameRegex = RegExp(namePattern);
  static final RegExp deviceIdRegex = RegExp(deviceIdPattern);
  static final RegExp referralCodeRegex = RegExp(referralCodePattern);

  // ===== UTILITY METHODS =====

  /// Get currency symbol for given currency code
  static String getCurrencySymbol(String currencyCode) {
    return currencySymbols[currencyCode.toUpperCase()] ?? currencyCode;
  }

  /// Get currency name for given currency code
  static String getCurrencyName(String currencyCode) {
    return currencyNames[currencyCode.toUpperCase()] ?? currencyCode;
  }

  /// Check if currency is supported
  static bool isSupportedCurrency(String currencyCode) {
    return supportedCurrencies.contains(currencyCode.toUpperCase());
  }

  /// Get language name for given language code
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode.toLowerCase()] ?? languageCode;
  }

  /// Check if language is supported
  static bool isSupportedLanguage(String languageCode) {
    return supportedLanguages.contains(languageCode.toLowerCase());
  }

  /// Get file extension from filename
  static String getFileExtension(String filename) {
    return filename.split('.').last.toLowerCase();
  }

  /// Check if file type is allowed for images
  static bool isAllowedImageType(String filename) {
    final extension = getFileExtension(filename);
    return allowedImageExtensions.contains(extension);
  }

  /// Check if file type is allowed for documents
  static bool isAllowedDocumentType(String filename) {
    final extension = getFileExtension(filename);
    return allowedDocumentExtensions.contains(extension);
  }

  /// Format file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if amount is within deposit limits
  static bool isValidDepositAmount(double amount) {
    return amount >= minDepositAmount && amount <= maxDepositAmount;
  }

  /// Check if amount is within withdrawal limits
  static bool isValidWithdrawalAmount(double amount) {
    return amount >= minWithdrawalAmount && amount <= maxWithdrawalAmount;
  }

  /// Check if amount is within loan limits
  static bool isValidLoanAmount(double amount) {
    return amount >= minLoanAmount && amount <= maxLoanAmount;
  }

  /// Check if tenure is within loan limits
  static bool isValidLoanTenure(int months) {
    return months >= minLoanTenure && months <= maxLoanTenure;
  }
}
