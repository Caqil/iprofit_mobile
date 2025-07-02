// // lib/router/route_paths.dart

// /// Application route paths constants
// /// This class contains all the route paths used throughout the application
// /// to maintain consistency and avoid typos in navigation.
// class RoutePaths {
//   // Private constructor to prevent instantiation
//   RoutePaths._();

//   // ===== AUTH ROUTES =====
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String forgotPassword = '/forgot-password';
//   static const String resetPassword = '/reset-password';
//   static const String verifyEmail = '/verify-email';
//   static const String verifyOtp = '/verify-otp';

//   // ===== MAIN APP ROUTES =====
//   static const String splash = '/splash';
//   static const String onboarding = '/onboarding';
//   static const String dashboard = '/dashboard';
//   static const String home = '/'; // Same as dashboard

//   // ===== WALLET ROUTES =====
//   static const String wallet = '/wallet';
//   static const String walletDeposit = '/wallet/deposit';
//   static const String walletWithdraw = '/wallet/withdraw';
//   static const String walletHistory = '/wallet/history';
//   static const String walletTransfer = '/wallet/transfer';

//   // ===== PORTFOLIO ROUTES =====
//   static const String portfolio = '/portfolio';
//   static const String portfolioDetails = '/portfolio/details';
//   static const String investment = '/portfolio/investment';
//   static const String investmentDetails = '/portfolio/investment/:id';

//   // ===== LOANS ROUTES =====
//   static const String loans = '/loans';
//   static const String loanApplication = '/loans/apply';
//   static const String loanDetails = '/loans/:id';
//   static const String loanCalculator = '/loans/calculator';
//   static const String loanHistory = '/loans/history';

//   // ===== TASKS ROUTES =====
//   static const String tasks = '/tasks';
//   static const String taskDetails = '/tasks/:id';
//   static const String taskSubmission = '/tasks/:id/submit';
//   static const String taskHistory = '/tasks/history';

//   // ===== REFERRALS ROUTES =====
//   static const String referrals = '/referrals';
//   static const String referralDetails = '/referrals/details';
//   static const String referralEarnings = '/referrals/earnings';
//   static const String referralHistory = '/referrals/history';

//   // ===== KYC ROUTES =====
//   static const String kyc = '/kyc';
//   static const String kycVerification = '/kyc/verification';
//   static const String kycDocuments = '/kyc/documents';
//   static const String kycStatus = '/kyc/status';

//   // ===== PROFILE ROUTES =====
//   static const String profile = '/profile';
//   static const String profileEdit = '/profile/edit';
//   static const String profileSecurity = '/profile/security';
//   static const String profileDevices = '/profile/devices';
//   static const String profilePreferences = '/profile/preferences';

//   // ===== NOTIFICATIONS ROUTES =====
//   static const String notifications = '/notifications';
//   static const String notificationDetails = '/notifications/:id';
//   static const String notificationSettings = '/notifications/settings';

//   // ===== SETTINGS ROUTES =====
//   static const String settings = '/settings';
//   static const String settingsGeneral = '/settings/general';
//   static const String settingsAppearance = '/settings/appearance';
//   static const String settingsSecurity = '/settings/security';
//   static const String settingsNotifications = '/settings/notifications';
//   static const String settingsPrivacy = '/settings/privacy';
//   static const String settingsAccount = '/settings/account';
//   static const String settingsBiometric = '/settings/biometric';
//   static const String settingsLanguage = '/settings/language';
//   static const String settingsCurrency = '/settings/currency';

//   // ===== SUPPORT ROUTES =====
//   static const String support = '/support';
//   static const String supportTickets = '/support/tickets';
//   static const String supportTicketDetails = '/support/tickets/:id';
//   static const String supportFaq = '/support/faq';
//   static const String supportContact = '/support/contact';

//   // ===== NEWS & UPDATES ROUTES =====
//   static const String news = '/news';
//   static const String newsDetails = '/news/:id';
//   static const String announcements = '/announcements';
//   static const String announcementDetails = '/announcements/:id';

//   // ===== ACHIEVEMENTS ROUTES =====
//   static const String achievements = '/achievements';
//   static const String achievementDetails = '/achievements/:id';
//   static const String leaderboard = '/achievements/leaderboard';

//   // ===== PLANS & SUBSCRIPTIONS ROUTES =====
//   static const String plans = '/plans';
//   static const String planDetails = '/plans/:id';
//   static const String planUpgrade = '/plans/upgrade';
//   static const String planHistory = '/plans/history';

//   // ===== HELP & DOCUMENTATION ROUTES =====
//   static const String help = '/help';
//   static const String documentation = '/help/docs';
//   static const String tutorials = '/help/tutorials';
//   static const String faq = '/help/faq';

//   // ===== LEGAL ROUTES =====
//   static const String legal = '/legal';
//   static const String termsOfService = '/legal/terms';
//   static const String privacyPolicy = '/legal/privacy';
//   static const String cookiePolicy = '/legal/cookies';
//   static const String disclaimer = '/legal/disclaimer';

//   // ===== ERROR ROUTES =====
//   static const String notFound = '/404';
//   static const String error = '/error';
//   static const String maintenance = '/maintenance';

//   // ===== UTILITY METHODS =====

//   /// Get route with parameters replaced
//   static String withParams(String route, Map<String, String> params) {
//     String result = route;
//     params.forEach((key, value) {
//       result = result.replaceAll(':$key', value);
//     });
//     return result;
//   }

//   /// Get loan details route with ID
//   static String loanDetailsWithId(String loanId) {
//     return loanDetails.replaceAll(':id', loanId);
//   }

//   /// Get task details route with ID
//   static String taskDetailsWithId(String taskId) {
//     return taskDetails.replaceAll(':id', taskId);
//   }

//   /// Get notification details route with ID
//   static String notificationDetailsWithId(String notificationId) {
//     return notificationDetails.replaceAll(':id', notificationId);
//   }

//   /// Get investment details route with ID
//   static String investmentDetailsWithId(String investmentId) {
//     return investmentDetails.replaceAll(':id', investmentId);
//   }

//   /// Get task submission route with ID
//   static String taskSubmissionWithId(String taskId) {
//     return taskSubmission.replaceAll(':id', taskId);
//   }

//   /// Get support ticket details route with ID
//   static String supportTicketDetailsWithId(String ticketId) {
//     return supportTicketDetails.replaceAll(':id', ticketId);
//   }

//   /// Get news details route with ID
//   static String newsDetailsWithId(String newsId) {
//     return newsDetails.replaceAll(':id', newsId);
//   }

//   /// Get announcement details route with ID
//   static String announcementDetailsWithId(String announcementId) {
//     return announcementDetails.replaceAll(':id', announcementId);
//   }

//   /// Get achievement details route with ID
//   static String achievementDetailsWithId(String achievementId) {
//     return achievementDetails.replaceAll(':id', achievementId);
//   }

//   /// Get plan details route with ID
//   static String planDetailsWithId(String planId) {
//     return planDetails.replaceAll(':id', planId);
//   }

//   // ===== ROUTE GROUPS =====

//   /// Get all authentication routes
//   static List<String> get authRoutes => [
//     login,
//     register,
//     forgotPassword,
//     resetPassword,
//     verifyEmail,
//     verifyOtp,
//   ];

//   /// Get all main app routes (require authentication)
//   static List<String> get mainAppRoutes => [
//     dashboard,
//     wallet,
//     portfolio,
//     loans,
//     tasks,
//     referrals,
//     kyc,
//     profile,
//     notifications,
//     settings,
//     support,
//     news,
//     achievements,
//     plans,
//     help,
//   ];

//   /// Get all wallet-related routes
//   static List<String> get walletRoutes => [
//     wallet,
//     walletDeposit,
//     walletWithdraw,
//     walletHistory,
//     walletTransfer,
//   ];

//   /// Get all settings routes
//   static List<String> get settingsRoutes => [
//     settings,
//     settingsGeneral,
//     settingsAppearance,
//     settingsSecurity,
//     settingsNotifications,
//     settingsPrivacy,
//     settingsAccount,
//     settingsBiometric,
//     settingsLanguage,
//     settingsCurrency,
//   ];

//   /// Get all legal routes
//   static List<String> get legalRoutes => [
//     legal,
//     termsOfService,
//     privacyPolicy,
//     cookiePolicy,
//     disclaimer,
//   ];

//   /// Check if route requires authentication
//   static bool requiresAuth(String route) {
//     return !authRoutes.contains(route) &&
//         !legalRoutes.contains(route) &&
//         route != splash &&
//         route != onboarding &&
//         route != notFound &&
//         route != error &&
//         route != maintenance;
//   }

//   /// Check if route is an auth route
//   static bool isAuthRoute(String route) {
//     return authRoutes.contains(route);
//   }

//   /// Check if route is a main app route
//   static bool isMainAppRoute(String route) {
//     return mainAppRoutes.any((mainRoute) => route.startsWith(mainRoute));
//   }

//   /// Check if route is a settings route
//   static bool isSettingsRoute(String route) {
//     return settingsRoutes.any(
//       (settingsRoute) => route.startsWith(settingsRoute),
//     );
//   }

//   /// Get breadcrumb for route
//   static List<String> getBreadcrumb(String route) {
//     final segments = route.split('/').where((s) => s.isNotEmpty).toList();
//     final breadcrumb = <String>[];

//     for (int i = 0; i < segments.length; i++) {
//       final path = '/${segments.sublist(0, i + 1).join('/')}';
//       breadcrumb.add(path);
//     }

//     return breadcrumb;
//   }

//   /// Get parent route
//   static String? getParentRoute(String route) {
//     final segments = route.split('/').where((s) => s.isNotEmpty).toList();
//     if (segments.length <= 1) return null;

//     return '/${segments.sublist(0, segments.length - 1).join('/')}';
//   }

//   /// Get route name for display
//   static String getDisplayName(String route) {
//     switch (route) {
//       case dashboard:
//         return 'Dashboard';
//       case wallet:
//         return 'Wallet';
//       case portfolio:
//         return 'Portfolio';
//       case loans:
//         return 'Loans';
//       case tasks:
//         return 'Tasks';
//       case referrals:
//         return 'Referrals';
//       case kyc:
//         return 'KYC Verification';
//       case profile:
//         return 'Profile';
//       case notifications:
//         return 'Notifications';
//       case settings:
//         return 'Settings';
//       case support:
//         return 'Support';
//       case news:
//         return 'News';
//       case achievements:
//         return 'Achievements';
//       case plans:
//         return 'Plans';
//       case help:
//         return 'Help';
//       default:
//         // Convert route to display name
//         final segments = route.split('/').where((s) => s.isNotEmpty).toList();
//         if (segments.isEmpty) return 'Home';

//         final lastSegment = segments.last;
//         return lastSegment
//             .split('-')
//             .map((word) {
//               return word[0].toUpperCase() + word.substring(1);
//             })
//             .join(' ');
//     }
//   }
// }
