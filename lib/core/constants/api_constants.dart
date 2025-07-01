import '../config/app_config.dart';

class ApiConstants {
  // Base URL - dynamically determined from AppConfig
  static String get baseUrl => AppConfig.baseUrl;

  // API Version
  static const String apiVersion = 'v1';
  static String get apiPrefix => '/api';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorizationHeader = 'Authorization';
  static const String deviceIdHeader = 'x-device-id';
  static const String fingerprintHeader = 'x-fingerprint';
  static const String userAgentHeader = 'User-Agent';

  // ===== AUTHENTICATION ENDPOINTS =====
  static const String authPrefix = '/api/auth';
  static const String login = '$authPrefix/login';
  static const String register = '$authPrefix/register';
  static const String logout = '$authPrefix/logout';
  static const String refreshToken = '$authPrefix/refresh';
  static const String forgotPassword = '$authPrefix/forgot-password';
  static const String resetPassword = '$authPrefix/reset-password';
  static const String verifyEmail = '$authPrefix/verify-email';
  static const String resendVerification = '$authPrefix/resend-verification';
  static const String verifyOtp = '$authPrefix/verify-otp';
  static const String changePassword = '$authPrefix/change-password';

  // ===== USER ENDPOINTS =====
  static const String userPrefix = '/api/users';
  static const String dashboard = '$userPrefix/dashboard';
  static const String profile = userPrefix; // /api/users/{id}
  static const String updateProfile = userPrefix; // PUT /api/users/{id}
  static const String preferences = '$userPrefix/preferences';
  static const String uploadProfile = '$userPrefix/upload/profile';
  static const String uploadDocument = '$userPrefix/upload/document';

  // ===== WALLET ENDPOINTS =====
  static const String walletPrefix = '$userPrefix/wallet';
  static const String walletBalance = '$walletPrefix/balance';
  static const String walletDeposit = '$walletPrefix/deposit';
  static const String walletWithdraw = '$walletPrefix/withdraw';
  static const String walletHistory = '$walletPrefix/history';
  static const String walletTransfer = '$walletPrefix/transfer';
  static const String walletLimits = '$walletPrefix/limits';

  // ===== PORTFOLIO ENDPOINTS =====
  static const String portfolioPrefix = '$userPrefix/portfolio';
  static const String portfolio = portfolioPrefix;
  static const String portfolioAnalytics = '$portfolioPrefix/analytics';
  static const String portfolioPerformance = '$portfolioPrefix/performance';
  static const String portfolioHistory = '$portfolioPrefix/history';
  static const String investments = '$portfolioPrefix/investments';
  static const String investmentDetails =
      '$portfolioPrefix/investments'; // /{id}

  // ===== LOANS ENDPOINTS =====
  static const String loansPrefix = '$userPrefix/loans';
  static const String loans = loansPrefix;
  static const String loanApplication = loansPrefix;
  static const String loanDetails = loansPrefix; // /{id}
  static const String loanRepaymentSchedule =
      loansPrefix; // /{id}/repayment-schedule
  static const String loanRepayment = loansPrefix; // /{id}/repayment
  static const String emiCalculator = '/api/loans/emi-calculator';
  static const String loanEligibility = '/api/loans/eligibility';

  // ===== TASKS ENDPOINTS =====
  static const String tasksPrefix = '$userPrefix/tasks';
  static const String tasks = tasksPrefix;
  static const String taskDetails = tasksPrefix; // /{id}
  static const String taskSubmit = tasksPrefix; // /{id}/submit
  static const String taskSubmissions = '$tasksPrefix/submissions';
  static const String taskCategories = '/api/tasks/categories';
  static const String taskFilters = '/api/tasks/filters';

  // ===== REFERRALS ENDPOINTS =====
  static const String referralsPrefix = '$userPrefix/referrals';
  static const String referrals = referralsPrefix;
  static const String referralLink = '$referralsPrefix/link';
  static const String referralEarnings = '$referralsPrefix/earnings';
  static const String referralStats = '$referralsPrefix/stats';
  static const String referralHistory = '$referralsPrefix/history';

  // ===== KYC ENDPOINTS =====
  static const String kycPrefix = '$userPrefix/kyc';
  static const String kycStatus = '$kycPrefix/status';
  static const String kycUpload = '$kycPrefix/upload';
  static const String kycSubmit = '$kycPrefix/submit';
  static const String kycDocuments = '$kycPrefix/documents';
  static const String kycHistory = '$kycPrefix/history';

  // ===== NOTIFICATIONS ENDPOINTS =====
  static const String notificationsPrefix = '$userPrefix/notifications';
  static const String notifications = notificationsPrefix;
  static const String notificationRead = notificationsPrefix; // /{id}/read
  static const String notificationMarkAllRead =
      '$notificationsPrefix/mark-all-read';
  static const String notificationSettings = '$notificationsPrefix/settings';
  static const String registerDevice = '/api/notifications/register-device';
  static const String unregisterDevice = '/api/notifications/unregister-device';

  // ===== SUPPORT ENDPOINTS =====
  static const String supportPrefix = '$userPrefix/support';
  static const String supportTickets = '$supportPrefix/tickets';
  static const String ticketDetails = '$supportPrefix/tickets'; // /{id}
  static const String ticketReplies = '$supportPrefix/tickets'; // /{id}/replies
  static const String supportFaq = '/api/support/faq';
  static const String supportCategories = '/api/support/categories';

  // ===== MOBILE DEVICE ENDPOINTS =====
  static const String mobilePrefix = '/api/mobile';
  static const String mobileDevices = '$mobilePrefix/devices';
  static const String deviceUpdate = '$mobilePrefix/device-update';
  static const String deviceRemove = '$mobilePrefix/devices'; // /{deviceId}

  // ===== ACHIEVEMENTS ENDPOINTS =====
  static const String achievementsPrefix = '$userPrefix/achievements';
  static const String achievements = achievementsPrefix;
  static const String achievementDetails = achievementsPrefix; // /{id}
  static const String achievementClaim = achievementsPrefix; // /{id}/claim

  // ===== PROFITS & EARNINGS ENDPOINTS =====
  static const String profitsPrefix = '$userPrefix/profits';
  static const String profits = profitsPrefix;
  static const String earnings = '$userPrefix/earnings';
  static const String earningsBreakdown = '$userPrefix/earnings/breakdown';
  static const String earningsHistory = '$userPrefix/earnings/history';

  // ===== PLANS & SUBSCRIPTIONS ENDPOINTS =====
  static const String plansPrefix = '/api/plans';
  static const String plans = plansPrefix;
  static const String planDetails = plansPrefix; // /{id}
  static const String planUpgrade = '$userPrefix/plan/upgrade';
  static const String planDowngrade = '$userPrefix/plan/downgrade';
  static const String planHistory = '$userPrefix/plan/history';

  // ===== NEWS & UPDATES ENDPOINTS =====
  static const String newsPrefix = '$userPrefix/news';
  static const String news = newsPrefix;
  static const String newsDetails = newsPrefix; // /{id}
  static const String newsCategories = '/api/news/categories';

  // ===== SECURITY ENDPOINTS =====
  static const String securityPrefix = '$userPrefix/security';
  static const String securitySettings = '$securityPrefix/settings';
  static const String securityChangePassword =
      '$securityPrefix/change-password';
  static const String securityLoginHistory = '$securityPrefix/login-history';
  static const String security2faSetup = '$userPrefix/2fa/setup';
  static const String security2faEnable = '$userPrefix/2fa/enable';
  static const String security2faDisable = '$userPrefix/2fa/disable';
  static const String security2faVerify = '$userPrefix/2fa/verify';

  // ===== FILE UPLOAD ENDPOINTS =====
  static const String uploadPrefix = '/api/upload';
  static const String uploadImage = '$uploadPrefix/image';
  static const String uploadAvatar = '$uploadPrefix/avatar';
  static const String uploadKycDocument = '$uploadPrefix/kyc-document';

  // ===== SYSTEM ENDPOINTS =====
  static const String systemPrefix = '/api/system';
  static const String systemHealth = '$systemPrefix/health';
  static const String systemVersion = '$systemPrefix/version';
  static const String systemMaintenance = '$systemPrefix/maintenance';
  static const String systemAnnouncements = '$systemPrefix/announcements';

  // ===== HTTP METHODS =====
  static const String get = 'GET';
  static const String post = 'POST';
  static const String put = 'PUT';
  static const String patch = 'PATCH';
  static const String delete = 'DELETE';

  // ===== QUERY PARAMETERS =====
  static const String pageParam = 'page';
  static const String limitParam = 'limit';
  static const String sortByParam = 'sortBy';
  static const String sortOrderParam = 'sortOrder';
  static const String statusParam = 'status';
  static const String typeParam = 'type';
  static const String categoryParam = 'category';
  static const String fromDateParam = 'fromDate';
  static const String toDateParam = 'toDate';
  static const String searchParam = 'search';
  static const String includeParam = 'include';

  // ===== STATUS CODES =====
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusMethodNotAllowed = 405;
  static const int statusUnprocessableEntity = 422;
  static const int statusTooManyRequests = 429;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;

  // ===== TIMEOUTS =====
  static Duration get connectTimeout => AppConfig.connectionTimeout;
  static Duration get receiveTimeout => AppConfig.receiveTimeout;
  static Duration get sendTimeout => AppConfig.connectionTimeout;

  // ===== PAGINATION DEFAULTS =====
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 5;

  // ===== SORTING OPTIONS =====
  static const String sortAsc = 'asc';
  static const String sortDesc = 'desc';
  static const String sortByCreatedAt = 'createdAt';
  static const String sortByUpdatedAt = 'updatedAt';
  static const String sortByAmount = 'amount';
  static const String sortByName = 'name';
  static const String sortByDate = 'date';

  // ===== HELPER METHODS =====

  /// Get full API endpoint URL
  static String getEndpoint(String path) {
    return '$baseUrl$path';
  }

  /// Get endpoint with query parameters
  static String getEndpointWithQuery(String path, Map<String, dynamic> params) {
    final uri = Uri.parse('$baseUrl$path');
    final newUri = uri.replace(queryParameters: _cleanQueryParams(params));
    return newUri.toString();
  }

  /// Clean query parameters (remove null values)
  static Map<String, String> _cleanQueryParams(Map<String, dynamic> params) {
    final cleanParams = <String, String>{};
    params.forEach((key, value) {
      if (value != null) {
        cleanParams[key] = value.toString();
      }
    });
    return cleanParams;
  }

  /// Get user-specific endpoint
  static String getUserEndpoint(String userId, String path) {
    return '$baseUrl$userPrefix/$userId$path';
  }

  /// Get paginated endpoint
  static String getPaginatedEndpoint(
    String path, {
    int page = 1,
    int limit = defaultPageSize,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = <String, dynamic>{pageParam: page, limitParam: limit};

    if (sortBy != null) params[sortByParam] = sortBy;
    if (sortOrder != null) params[sortOrderParam] = sortOrder;

    return getEndpointWithQuery(path, params);
  }

  /// Check if status code indicates success
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if status code indicates client error
  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if status code indicates server error
  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Get error message for status code
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case statusBadRequest:
        return 'Bad request';
      case statusUnauthorized:
        return 'Unauthorized access';
      case statusForbidden:
        return 'Access forbidden';
      case statusNotFound:
        return 'Resource not found';
      case statusMethodNotAllowed:
        return 'Method not allowed';
      case statusUnprocessableEntity:
        return 'Validation error';
      case statusTooManyRequests:
        return 'Too many requests';
      case statusInternalServerError:
        return 'Internal server error';
      case statusBadGateway:
        return 'Bad gateway';
      case statusServiceUnavailable:
        return 'Service unavailable';
      default:
        return 'Unknown error';
    }
  }
}
