// lib/presentation/providers/portfolio_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../data/models/portfolio/portfolio_model.dart';
import '../../data/models/portfolio/investment_model.dart';
import '../../data/models/common/pagination.dart';

part 'portfolio_provider.g.dart';

// ============================================================================
// PORTFOLIO STATE MODEL
// ============================================================================

/// Portfolio provider state model
class PortfolioState {
  final PortfolioModel? portfolio;
  final List<InvestmentModel> investments;
  final Pagination? investmentsPagination;
  final List<Map<String, dynamic>> profitHistory;
  final Pagination? profitHistoryPagination;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? performance;
  final bool isLoading;
  final bool isLoadingInvestments;
  final bool isLoadingHistory;
  final bool isLoadingAnalytics;
  final String? error;
  final String currentTimeframe;
  final String currentInvestmentFilter;
  final String? lastUpdated;

  const PortfolioState({
    this.portfolio,
    this.investments = const [],
    this.investmentsPagination,
    this.profitHistory = const [],
    this.profitHistoryPagination,
    this.analytics,
    this.performance,
    this.isLoading = false,
    this.isLoadingInvestments = false,
    this.isLoadingHistory = false,
    this.isLoadingAnalytics = false,
    this.error,
    this.currentTimeframe = '30d',
    this.currentInvestmentFilter = 'all',
    this.lastUpdated,
  });

  PortfolioState copyWith({
    PortfolioModel? portfolio,
    List<InvestmentModel>? investments,
    Pagination? investmentsPagination,
    List<Map<String, dynamic>>? profitHistory,
    Pagination? profitHistoryPagination,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? performance,
    bool? isLoading,
    bool? isLoadingInvestments,
    bool? isLoadingHistory,
    bool? isLoadingAnalytics,
    String? error,
    String? currentTimeframe,
    String? currentInvestmentFilter,
    String? lastUpdated,
  }) {
    return PortfolioState(
      portfolio: portfolio ?? this.portfolio,
      investments: investments ?? this.investments,
      investmentsPagination:
          investmentsPagination ?? this.investmentsPagination,
      profitHistory: profitHistory ?? this.profitHistory,
      profitHistoryPagination:
          profitHistoryPagination ?? this.profitHistoryPagination,
      analytics: analytics ?? this.analytics,
      performance: performance ?? this.performance,
      isLoading: isLoading ?? this.isLoading,
      isLoadingInvestments: isLoadingInvestments ?? this.isLoadingInvestments,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      error: error,
      currentTimeframe: currentTimeframe ?? this.currentTimeframe,
      currentInvestmentFilter:
          currentInvestmentFilter ?? this.currentInvestmentFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasPortfolio => portfolio != null;
  bool get hasInvestments => investments.isNotEmpty;
  bool get hasMoreInvestments => investmentsPagination?.hasNextPage ?? false;
  bool get hasMoreHistory => profitHistoryPagination?.hasNextPage ?? false;
  bool get hasAnalytics => analytics != null;
  bool get hasPerformance => performance != null;

  // Portfolio statistics
  double get totalInvestment => portfolio?.overview.totalInvested ?? 0.0;
  double get currentValue => portfolio?.overview.totalValue ?? 0.0;
  double get totalProfit => portfolio?.overview.totalProfits ?? 0.0;
  double get totalProfitPercentage =>
      totalInvestment > 0 ? (totalProfit / totalInvestment) * 100 : 0.0;
  double get todayProfit => performance?['todayProfit']?.toDouble() ?? 0.0;
  double get todayProfitPercentage =>
      performance?['todayProfitPercentage']?.toDouble() ?? 0.0;

  bool get isProfitable => totalProfit > 0;
  bool get isBreakeven => totalProfit == 0;
  bool get isLoss => totalProfit < 0;

  // Investment categories
  List<InvestmentModel> get activeInvestments =>
      investments.where((i) => i.status == 'active').toList();
  List<InvestmentModel> get completedInvestments =>
      investments.where((i) => i.status == 'completed').toList();
  List<InvestmentModel> get pendingInvestments =>
      investments.where((i) => i.status == 'pending').toList();

  // Performance metrics
  double get portfolioROI =>
      portfolio?.activeInvestment?.performance.roi ?? 0.0;
  double get monthlyReturn => performance?['monthlyReturn']?.toDouble() ?? 0.0;
  double get yearlyReturn => performance?['yearlyReturn']?.toDouble() ?? 0.0;
  double get volatility => performance?['volatility']?.toDouble() ?? 0.0;
  double get sharpeRatio => performance?['sharpeRatio']?.toDouble() ?? 0.0;
}

// ============================================================================
// PORTFOLIO PROVIDER
// ============================================================================

@riverpod
class Portfolio extends _$Portfolio {
  Timer? _refreshTimer;

  @override
  PortfolioState build() {
    // Initialize portfolio data on provider creation
    _initializePortfolio();

    // Set up auto-refresh for real-time updates
    _setupAutoRefresh();

    // Clean up when provider is disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return const PortfolioState();
  }

  // ===== INITIALIZATION =====

  /// Initialize portfolio data
  Future<void> _initializePortfolio() async {
    await Future.wait([loadPortfolio(), loadInvestments(), loadAnalytics()]);
  }

  /// Setup auto-refresh for portfolio data
  void _setupAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
     loadPortfolio(forceRefresh: true); // Silently update portfolio
      
    });
  }

  // ===== PORTFOLIO MANAGEMENT =====

  /// Load portfolio overview
  Future<void> loadPortfolio({bool forceRefresh = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.getPortfolio(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          portfolio: response.data!,
          isLoading: false,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load portfolio',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
    }
  }

  /// Refresh portfolio data
  Future<void> refreshPortfolio() async {
    await loadPortfolio(forceRefresh: true);
  }

  // ===== INVESTMENTS MANAGEMENT =====

  /// Load investments with pagination and filtering
  Future<void> loadInvestments({
    int page = 1,
    String status = 'all',
    String type = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoadingInvestments: true,
          error: null,
          currentInvestmentFilter: status,
        );
      } else {
        state = state.copyWith(isLoadingInvestments: true, error: null);
      }

      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.getInvestments(
        page: page,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<InvestmentModel> updatedInvestments;

        if (page == 1) {
          updatedInvestments = response.data;
        } else {
          updatedInvestments = [...state.investments, ...response.data];
        }

        state = state.copyWith(
          investments: updatedInvestments,
          investmentsPagination: response.pagination,
          isLoadingInvestments: false,
        );
      } else {
        state = state.copyWith(
          isLoadingInvestments: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingInvestments: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more investments (pagination)
  Future<void> loadMoreInvestments() async {
    if (state.isLoadingInvestments || !state.hasMoreInvestments) return;

    final nextPage = (state.investmentsPagination?.currentPage ?? 0) + 1;
    await loadInvestments(
      page: nextPage,
      status: state.currentInvestmentFilter,
    );
  }

  /// Filter investments by status
  Future<void> filterInvestments(String status) async {
    if (state.currentInvestmentFilter == status) return;

    await loadInvestments(status: status);
  }

  /// Refresh investments list
  Future<void> refreshInvestments() async {
    await loadInvestments(
      status: state.currentInvestmentFilter,
      forceRefresh: true,
    );
  }

  // ===== PROFIT HISTORY =====

  /// Load profit history
  Future<void> loadProfitHistory({
    int page = 1,
    String timeframe = '30d',
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoadingHistory: true,
          error: null,
          currentTimeframe: timeframe,
        );
      } else {
        state = state.copyWith(isLoadingHistory: true, error: null);
      }

      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.getProfitHistory(
        page: page,
        period: timeframe,
        startDate: startDate?.toIso8601String().split('T')[0],
        endDate: endDate?.toIso8601String().split('T')[0],
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<Map<String, dynamic>> updatedHistory;

        if (page == 1) {
          updatedHistory = response.data;
        } else {
          updatedHistory = [...state.profitHistory, ...response.data];
        }

        state = state.copyWith(
          profitHistory: updatedHistory,
          profitHistoryPagination: response.pagination,
          isLoadingHistory: false,
        );
      } else {
        state = state.copyWith(
          isLoadingHistory: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingHistory: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more profit history (pagination)
  Future<void> loadMoreProfitHistory() async {
    if (state.isLoadingHistory || !state.hasMoreHistory) return;

    final nextPage = (state.profitHistoryPagination?.currentPage ?? 0) + 1;
    await loadProfitHistory(page: nextPage, timeframe: state.currentTimeframe);
  }

  /// Change timeframe for profit history
  Future<void> changeTimeframe(String timeframe) async {
    if (state.currentTimeframe == timeframe) return;

    await loadProfitHistory(timeframe: timeframe);
  }

  // ===== ANALYTICS AND PERFORMANCE =====

  /// Load portfolio analytics
  Future<void> loadAnalytics({
    String timeframe = '30d',
    bool forceRefresh = false,
  }) async {
    try {
      state = state.copyWith(isLoadingAnalytics: true, error: null);

      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.getPortfolioAnalytics(
        period: timeframe,
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          analytics: response.data!.toJson(),
          isLoadingAnalytics: false,
        );
      } else {
        state = state.copyWith(
          isLoadingAnalytics: false,
          error: response.message ?? 'Failed to load analytics',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingAnalytics: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load portfolio performance metrics
  Future<void> loadPerformance({
    String timeframe = '1y',
    bool forceRefresh = false,
  }) async {
    try {
      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.getPortfolioPerformance(
        period: timeframe,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(performance: response.data!);
      }
    } catch (e) {
      // Silent fail for performance metrics
    }
  }

  // ===== INVESTMENT DETAILS =====

  /// Get investment details
  Future<InvestmentModel?> getInvestmentDetails(String investmentId) async {
    try {
      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.getInvestmentDetails(
        investmentId,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load investment details',
        );
      }
    } catch (e) {
      throw AppException.fromException(e as Exception);
    }
  }

  // ===== INVESTMENT ACTIONS =====

  /// Create new investment
  Future<bool> createInvestment({
    required double amount,
    required String planId,
    String currency = 'USD',
  }) async {
    try {
      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.createInvestment(
        amount: amount,
        planId: planId,
        currency: currency,
      );

      if (response.success) {
        // Refresh portfolio and investments
        await Future.wait([refreshPortfolio(), refreshInvestments()]);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to create investment',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
      return false;
    }
  }

  /// Withdraw from investment
  Future<bool> withdrawInvestment({
    required String investmentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final portfolioRepository = ref.read(portfolioRepositoryProvider);
      final response = await portfolioRepository.withdrawFromInvestment(
        investmentId: investmentId,
        amount: amount,
        reason: reason,
      );

      if (response.success) {
        // Refresh portfolio and investments
        await Future.wait([refreshPortfolio(), refreshInvestments()]);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to withdraw investment',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== UTILITY METHODS =====

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.userMessage;
    }
    return error.toString();
  }

  /// Get investment by ID
  InvestmentModel? getInvestmentById(String investmentId) {
    try {
      return state.investments.firstWhere((i) => i.id == investmentId);
    } catch (e) {
      return null;
    }
  }

  /// Get profit data for chart
  List<Map<String, dynamic>> getProfitChartData({
    String timeframe = '30d',
    int maxPoints = 30,
  }) {
    final history = state.profitHistory.take(maxPoints).toList();
    return history.reversed.toList(); // Reverse to show chronological order
  }

  /// Get investment distribution data
  Map<String, double> getInvestmentDistribution() {
    final distribution = <String, double>{};

    for (final investment in state.activeInvestments) {
      final type = 'Others';
      distribution[type] = (distribution[type] ?? 0.0) + investment.amount;
    }

    return distribution;
  }

  /// Force refresh all portfolio data
  Future<void> refresh() async {
    await Future.wait([
      refreshPortfolio(),
      refreshInvestments(),
      loadAnalytics(forceRefresh: true),
      loadPerformance(forceRefresh: true),
    ]);
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for portfolio total value
@riverpod
double portfolioTotalValue(Ref ref) {
  return ref.watch(portfolioProvider.select((state) => state.currentValue));
}

/// Provider for portfolio total profit
@riverpod
double portfolioTotalProfit(Ref ref) {
  return ref.watch(portfolioProvider.select((state) => state.totalProfit));
}

/// Provider for portfolio ROI
@riverpod
double portfolioROI(Ref ref) {
  return ref.watch(portfolioProvider.select((state) => state.portfolioROI));
}

/// Provider for active investments
@riverpod
List<InvestmentModel> activeInvestments(Ref ref) {
  return ref.watch(
    portfolioProvider.select((state) => state.activeInvestments),
  );
}

/// Provider for portfolio loading state
@riverpod
bool isPortfolioLoading(Ref ref) {
  return ref.watch(portfolioProvider.select((state) => state.isLoading));
}

/// Provider for portfolio error
@riverpod
String? portfolioError(Ref ref) {
  return ref.watch(portfolioProvider.select((state) => state.error));
}

/// Provider for today's profit
@riverpod
double todayProfit(Ref ref) {
  return ref.watch(portfolioProvider.select((state) => state.todayProfit));
}

/// Provider for checking if portfolio is profitable
@riverpod
bool isPortfolioProfitable(Ref ref) {
  return ref.watch(portfolioProvider.select((state) => state.isProfitable));
}

/// Provider for investment distribution
@riverpod
Map<String, double> investmentDistribution(Ref ref) {
  final portfolioNotifier = ref.watch(portfolioProvider.notifier);
  return portfolioNotifier.getInvestmentDistribution();
}
