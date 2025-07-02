import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iprofit_mobile/data/models/wallet/transaction_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/loans_repository.dart';
import '../repositories/tasks_repository.dart';
import '../repositories/referrals_repository.dart';
import '../repositories/notifications_repository.dart';
import '../repositories/kyc_repository.dart';
import '../models/auth/user_model.dart';
import '../models/wallet/wallet_history.dart';
import '../models/portfolio/portfolio_model.dart';
import '../models/portfolio/investment_model.dart';
import '../models/loans/loan_model.dart';
import '../models/tasks/task_model.dart';
import '../models/tasks/task_submission.dart';
import '../models/tasks/task_category.dart';
import '../models/referrals/referral_model.dart';
import '../models/referrals/referral_earnings.dart';
import '../models/notifications/notification_model.dart';
import '../models/kyc/kyc_model.dart';

final dataLoaderServiceProvider = Provider<DataLoaderService>((ref) {
  return DataLoaderService(
    authRepository: ref.read(authRepositoryProvider),
    userRepository: ref.read(userRepositoryProvider),
    walletRepository: ref.read(walletRepositoryProvider),
    portfolioRepository: ref.read(portfolioRepositoryProvider),
    loansRepository: ref.read(loansRepositoryProvider),
    tasksRepository: ref.read(tasksRepositoryProvider),
    referralsRepository: ref.read(referralsRepositoryProvider),
    notificationsRepository: ref.read(notificationsRepositoryProvider),
    kycRepository: ref.read(kycRepositoryProvider),
  );
});

class DataLoaderService {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final WalletRepository _walletRepository;
  final PortfolioRepository _portfolioRepository;
  final LoansRepository _loansRepository;
  final TasksRepository _tasksRepository;
  final ReferralsRepository _referralsRepository;
  final NotificationsRepository _notificationsRepository;
  final KYCRepository _kycRepository;

  DataLoaderService({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required WalletRepository walletRepository,
    required PortfolioRepository portfolioRepository,
    required LoansRepository loansRepository,
    required TasksRepository tasksRepository,
    required ReferralsRepository referralsRepository,
    required NotificationsRepository notificationsRepository,
    required KYCRepository kycRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _walletRepository = walletRepository,
       _portfolioRepository = portfolioRepository,
       _loansRepository = loansRepository,
       _tasksRepository = tasksRepository,
       _referralsRepository = referralsRepository,
       _notificationsRepository = notificationsRepository,
       _kycRepository = kycRepository;

  /// Load all essential data during app startup
  Future<AppDataLoadResult> loadAppData({
    bool forceRefresh = false,
    void Function(String)? onProgress,
  }) async {
    final result = AppDataLoadResult();

    try {
      // Check authentication status first
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (!isLoggedIn) {
        result.isAuthenticated = false;
        return result;
      }

      result.isAuthenticated = true;
      onProgress?.call('Loading user data...');

      // Get current user from storage
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        result.isAuthenticated = false;
        return result;
      }

      result.user = currentUser;

      // Load all data in parallel with error handling
      await Future.wait([
        _loadDashboardData(result, onProgress),
        _loadWalletData(result, onProgress),
        _loadPortfolioData(result, onProgress),
        _loadLoansData(result, onProgress),
        _loadTasksData(result, onProgress),
        _loadReferralsData(result, onProgress),
        _loadNotificationsData(result, onProgress),
        _loadKYCData(result, onProgress),
      ], eagerError: false);

      result.loadedSuccessfully = true;
      onProgress?.call('Data loaded successfully!');
    } catch (e) {
      result.error = e.toString();
      result.loadedSuccessfully = false;
    }

    return result;
  }

  Future<void> _loadDashboardData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading dashboard...');

      // Load dashboard data
      final dashboardResponse = await _userRepository.getDashboard();
      if (dashboardResponse.success && dashboardResponse.data != null) {
        result.dashboardData = dashboardResponse.data!;
      }

      // Load user profile
      if (result.user != null) {
        final userResponse = await _userRepository.getUserProfile(
          result.user!.id,
        );
        if (userResponse.success && userResponse.data != null) {
          result.user = userResponse.data!;
        }
      }

      // Load user preferences
      final preferencesResponse = await _userRepository.getUserPreferences();
      if (preferencesResponse.success && preferencesResponse.data != null) {
        result.userPreferences = UserPreferences.fromJson(
          preferencesResponse.data!,
        );
      }

      result.dashboardLoaded = true;
    } catch (e) {
      result.dashboardError = e.toString();
    }
  }

  Future<void> _loadWalletData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading wallet data...');

      // Load wallet balance
      final balanceResponse = await _walletRepository.getWalletBalance();
      if (balanceResponse.success && balanceResponse.data != null) {
        result.walletBalance = balanceResponse.data!;
      }

      // Load wallet history (first page)
      final historyResponse = await _walletRepository.getWalletHistory(
        limit: 20,
      );
      if (historyResponse.success) {
        result.walletHistory = historyResponse.data;
      }

      // Load payment methods
      final paymentMethodsResponse = await _walletRepository
          .getPaymentMethods();
      if (paymentMethodsResponse.success &&
          paymentMethodsResponse.data != null) {
        result.paymentMethods = paymentMethodsResponse.data!;
      }

      result.walletLoaded = true;
    } catch (e) {
      result.walletError = e.toString();
    }
  }

  Future<void> _loadPortfolioData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading portfolio...');

      // Load portfolio overview
      final portfolioResponse = await _portfolioRepository.getPortfolio();
      if (portfolioResponse.success && portfolioResponse.data != null) {
        result.portfolio = portfolioResponse.data!;
      }

      // Load investments
      final investmentsResponse = await _portfolioRepository.getInvestments(
        limit: 20,
      );
      if (investmentsResponse.success) {
        result.investments = investmentsResponse.data;
      }

      // Load profit history
      final profitsResponse = await _portfolioRepository.getProfitHistory(
        limit: 30,
      );
      if (profitsResponse.success) {
        result.profitHistory = profitsResponse.data;
      }

      result.portfolioLoaded = true;
    } catch (e) {
      result.portfolioError = e.toString();
    }
  }

  Future<void> _loadLoansData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading loans...');

      // Load user loans
      final loansResponse = await _loansRepository.getUserLoans(limit: 20);
      if (loansResponse.success) {
        result.loans = loansResponse.data;
      }

      result.loansLoaded = true;
    } catch (e) {
      result.loansError = e.toString();
    }
  }

  Future<void> _loadTasksData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading tasks...');

      // Load available tasks
      final tasksResponse = await _tasksRepository.getTasks(limit: 20);
      if (tasksResponse.success) {
        result.tasks = tasksResponse.data;
      }

      // Load task submissions
      final submissionsResponse = await _tasksRepository.getTaskSubmissions(
        limit: 20,
      );
      if (submissionsResponse.success) {
        result.taskSubmissions = submissionsResponse.data;
      }

      // Load task categories
      final categoriesResponse = await _tasksRepository.getTaskCategories();
      if (categoriesResponse.success && categoriesResponse.data != null) {
        result.taskCategories = categoriesResponse.data!;
      }

      result.tasksLoaded = true;
    } catch (e) {
      result.tasksError = e.toString();
    }
  }

  Future<void> _loadReferralsData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading referrals...');

      // Load referral overview
      final overviewResponse = await _referralsRepository.getReferralOverview();
      if (overviewResponse.success && overviewResponse.data != null) {
        result.referralOverview = overviewResponse.data!;
      }

      // Load referral link
      final linkResponse = await _referralsRepository.getReferralLink();
      if (linkResponse.success && linkResponse.data != null) {
        result.referralLink = linkResponse.data!;
      }

      // Load referrals
      final referralsResponse = await _referralsRepository.getReferrals(
        limit: 20,
      );
      if (referralsResponse.success) {
        result.referrals = referralsResponse.data;
      }

      // Load referral earnings
      final earningsResponse = await _referralsRepository.getReferralEarnings(
        limit: 30,
      );
      if (earningsResponse.success) {
        result.referralEarnings = earningsResponse.data;
      }

      result.referralsLoaded = true;
    } catch (e) {
      result.referralsError = e.toString();
    }
  }

  Future<void> _loadNotificationsData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading notifications...');

      // Load notifications
      final notificationsResponse = await _notificationsRepository
          .getNotifications(limit: 20);
      if (notificationsResponse.success) {
        result.notifications = notificationsResponse.data;
      }

      // Load unread count
      final unreadResponse = await _notificationsRepository.getUnreadCount();
      if (unreadResponse.success && unreadResponse.data != null) {
        result.unreadNotificationsCount = unreadResponse.data!;
      }

      result.notificationsLoaded = true;
    } catch (e) {
      result.notificationsError = e.toString();
    }
  }

  Future<void> _loadKYCData(
    AppDataLoadResult result,
    void Function(String)? onProgress,
  ) async {
    try {
      onProgress?.call('Loading KYC status...');

      // Load KYC status
      final kycResponse = await _kycRepository.getKYCStatus();
      if (kycResponse.success && kycResponse.data != null) {
        result.kycData = kycResponse.data!;
      }

      result.kycLoaded = true;
    } catch (e) {
      result.kycError = e.toString();
    }
  }

  /// Refresh specific module data
  Future<bool> refreshModuleData(DataModule module) async {
    try {
      switch (module) {
        case DataModule.dashboard:
          final response = await _userRepository.getDashboard();
          return response.success;

        case DataModule.wallet:
          final responses = await Future.wait([
            _walletRepository.getWalletBalance(),
            _walletRepository.getWalletHistory(forceRefresh: true),
          ]);
          return responses.every(
            (r) => r.toString() == responses[0].toString(),
          );

        case DataModule.portfolio:
          final responses = await Future.wait([
            _portfolioRepository.getPortfolio(forceRefresh: true),
            _portfolioRepository.getInvestments(forceRefresh: true),
          ]);
          return responses.every((r) => r.hashCode == responses[0].hashCode);

        case DataModule.loans:
          final response = await _loansRepository.getUserLoans(
            forceRefresh: true,
          );
          return response.success;

        case DataModule.tasks:
          final responses = await Future.wait([
            _tasksRepository.getTasks(forceRefresh: true),
            _tasksRepository.getTaskSubmissions(forceRefresh: true),
          ]);
          return responses.every((r) => r.success);

        case DataModule.referrals:
          final responses = await Future.wait([
            _referralsRepository.getReferralOverview(),
            _referralsRepository.getReferrals(forceRefresh: true),
          ]);
          return responses.every((r) => r.hashCode == responses[0].hashCode);

        case DataModule.notifications:
          final response = await _notificationsRepository.getNotifications(
            forceRefresh: true,
          );
          return response.success;

        case DataModule.kyc:
          final response = await _kycRepository.getKYCStatus();
          return response.success;
      }
    } catch (e) {
      return false;
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await Future.wait([
      _userRepository.clearUserCache(),
      _walletRepository.clearWalletCache(),
      _portfolioRepository.clearPortfolioCache(),
      _loansRepository.clearLoansCache(),
      _tasksRepository.clearTasksCache(),
      _referralsRepository.clearReferralsCache(),
      _notificationsRepository.clearNotificationsCache(),
      _kycRepository.clearKYCCache(),
    ]);
  }

  /// Get cached data summary for offline mode
  Future<Map<String, dynamic>> getCachedDataSummary() async {
    final summaries = await Future.wait([
      _userRepository.getUserSummary(),
      _walletRepository.getWalletSummary(),
      _portfolioRepository.getPortfolioSummary(),
      _loansRepository.getLoansSummary(),
      _tasksRepository.getTasksSummary(),
      _referralsRepository.getReferralsSummary(),
    ]);

    return {
      'user': summaries[0],
      'wallet': summaries[1],
      'portfolio': summaries[2],
      'loans': summaries[3],
      'tasks': summaries[4],
      'referrals': summaries[5],
      'lastSyncTime': DateTime.now().toIso8601String(),
    };
  }

  /// Check if essential data is available offline
  Future<bool> hasEssentialDataCached() async {
    final checks = await Future.wait([
      _userRepository.getCachedUser().then((data) => data != null),
      _walletRepository.getCachedWalletBalance().then((data) => data != null),
      _portfolioRepository.getCachedPortfolio().then((data) => data != null),
    ]);

    return checks.every((hasData) => hasData);
  }
}

enum DataModule {
  dashboard,
  wallet,
  portfolio,
  loans,
  tasks,
  referrals,
  notifications,
  kyc,
}

class AppDataLoadResult {
  bool isAuthenticated = false;
  bool loadedSuccessfully = false;
  String? error;

  // User data
  UserModel? user;
  Map<String, dynamic>? dashboardData;
  UserPreferences? userPreferences;
  bool dashboardLoaded = false;
  String? dashboardError;

  // Wallet data
  Map<String, dynamic>? walletBalance;
  List<TransactionModel>? walletHistory;
  List<Map<String, dynamic>>? paymentMethods;
  bool walletLoaded = false;
  String? walletError;

  // Portfolio data
  PortfolioModel? portfolio;
  List<InvestmentModel>? investments;
  List<Map<String, dynamic>>? profitHistory;
  bool portfolioLoaded = false;
  String? portfolioError;

  // Loans data
  List<LoanModel>? loans;
  bool loansLoaded = false;
  String? loansError;

  // Tasks data
  List<TaskModel>? tasks;
  List<TaskSubmissionResponse>? taskSubmissions;
  List<TaskCategory>? taskCategories;
  bool tasksLoaded = false;
  String? tasksError;

  // Referrals data
  ReferralOverview? referralOverview;
  ReferralLink? referralLink;
  List<ReferralModel>? referrals;
  List<EarningTransaction>? referralEarnings;
  bool referralsLoaded = false;
  String? referralsError;

  // Notifications data
  List<NotificationModel>? notifications;
  int unreadNotificationsCount = 0;
  bool notificationsLoaded = false;
  String? notificationsError;

  // KYC data
  KYCModel? kycData;
  bool kycLoaded = false;
  String? kycError;

  /// Get loading progress percentage
  double get loadingProgress {
    final modules = [
      dashboardLoaded,
      walletLoaded,
      portfolioLoaded,
      loansLoaded,
      tasksLoaded,
      referralsLoaded,
      notificationsLoaded,
      kycLoaded,
    ];

    final loadedCount = modules.where((loaded) => loaded).length;
    return loadedCount / modules.length;
  }

  /// Get list of modules that failed to load
  List<String> get failedModules {
    final failures = <String>[];

    if (dashboardError != null) failures.add('Dashboard');
    if (walletError != null) failures.add('Wallet');
    if (portfolioError != null) failures.add('Portfolio');
    if (loansError != null) failures.add('Loans');
    if (tasksError != null) failures.add('Tasks');
    if (referralsError != null) failures.add('Referrals');
    if (notificationsError != null) failures.add('Notifications');
    if (kycError != null) failures.add('KYC');

    return failures;
  }

  /// Check if core data is available (minimum required for app to function)
  bool get hasCoreData {
    return isAuthenticated &&
        user != null &&
        dashboardData != null &&
        walletBalance != null;
  }
}
