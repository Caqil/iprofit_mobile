class ApiConstants {
  static const String baseUrl = 'https://your-iprofit-domain.com';

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh';

  // User endpoints
  static const String dashboard = '/api/users/dashboard';
  static const String profile = '/api/users';
  static const String preferences = '/api/users/preferences';

  // Wallet endpoints
  static const String walletDeposit = '/api/users/wallet/deposit';
  static const String walletWithdraw = '/api/users/wallet/withdraw';
  static const String walletHistory = '/api/users/wallet/history';

  // Portfolio endpoints
  static const String portfolio = '/api/users/portfolio';

  // Loans endpoints
  static const String loans = '/api/users/loans';
  static const String loanApplication = '/api/users/loans';
  static const String emiCalculator = '/api/loans/emi-calculator';

  // Tasks endpoints
  static const String tasks = '/api/users/tasks';
  static const String taskSubmissions = '/api/users/tasks/submissions';

  // Referrals endpoints
  static const String referrals = '/api/users/referrals';
  static const String referralLink = '/api/users/referrals/link';
  static const String referralEarnings = '/api/users/referrals/earnings';

  // KYC endpoints
  static const String kycUpload = '/api/users/kyc/upload';
  static const String kycSubmit = '/api/users/kyc/submit';
  static const String kycStatus = '/api/users/kyc/status';

  // Notifications endpoints
  static const String notifications = '/api/users/notifications';
  static const String registerDevice = '/api/notifications/register-device';

  // Support endpoints
  static const String supportTickets = '/api/users/support/tickets';

  // Mobile endpoints
  static const String mobileDevices = '/api/mobile/devices';
  static const String deviceUpdate = '/api/mobile/device-update';

  // Achievements endpoints
  static const String achievements = '/api/users/achievements';

  // Profits endpoints
  static const String profits = '/api/users/profits';
  static const String earnings = '/api/users/earnings';
}
