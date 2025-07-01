import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/portfolio/portfolio_model.dart';
import '../models/portfolio/investment_model.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/storage_service.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(ref.read(apiClientProvider));
});

class PortfolioRepository {
  final ApiClient _apiClient;
  static const String _cacheKeyPortfolio = 'portfolio_overview';
  static const String _cacheKeyInvestments = 'investments';
  static const String _cacheKeyProfits = 'profit_history';
  static const String _cacheKeyAnalytics = 'portfolio_analytics';
  static const Duration _cacheExpiry = Duration(minutes: 15);

  PortfolioRepository(this._apiClient);

  /// Get portfolio overview
  Future<ApiResponse<PortfolioModel>> getPortfolio({
    bool includeAnalytics = true,
    String period = 'monthly',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyPortfolio}_${period}_$includeAnalytics';

      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedPortfolio(cacheKey);
        if (cached != null) {
          return ApiResponse<PortfolioModel>(
            success: true,
            data: cached,
            message: 'Portfolio loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final queryParams = <String, dynamic>{
        'includeAnalytics': includeAnalytics,
        'period': period,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(ApiConstants.portfolio, queryParams),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<PortfolioModel>.fromJson(
          response.data!,
          (json) => PortfolioModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cachePortfolio(cacheKey, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch portfolio');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get investments with pagination
  Future<PaginatedResponse<InvestmentModel>> getInvestments({
    int page = 1,
    int limit = 20,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyInvestments}_${page}_${limit}_$status';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedInvestments(cacheKey);
        if (cached != null) {
          return cached;
        }
      }

      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
        ApiConstants.sortByParam: sortBy,
        ApiConstants.sortOrderParam: sortOrder,
      };

      if (status != 'all') {
        queryParams[ApiConstants.statusParam] = status;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          ApiConstants.investments,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse = PaginatedResponse<InvestmentModel>.fromJson(
          response.data!,
          (json) => InvestmentModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheInvestments(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch investments');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get investment details by ID
  Future<ApiResponse<InvestmentModel>> getInvestmentDetails(
    String investmentId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.investmentDetails}/$investmentId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<InvestmentModel>.fromJson(
          response.data!,
          (json) => InvestmentModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw AppException.serverError('Failed to fetch investment details');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get portfolio analytics
  Future<ApiResponse<PortfolioAnalytics>> getPortfolioAnalytics({
    String period = 'monthly',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyAnalytics}_$period';

      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedAnalytics(cacheKey);
        if (cached != null) {
          return ApiResponse<PortfolioAnalytics>(
            success: true,
            data: cached,
            message: 'Analytics loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(ApiConstants.portfolioAnalytics, {
          'period': period,
        }),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<PortfolioAnalytics>.fromJson(
          response.data!,
          (json) => PortfolioAnalytics.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheAnalytics(cacheKey, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch portfolio analytics');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get portfolio performance
  Future<ApiResponse<Map<String, dynamic>>> getPortfolioPerformance({
    String period = 'monthly',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          ApiConstants.portfolioPerformance,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch portfolio performance');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get profit history with pagination
  Future<PaginatedResponse<Map<String, dynamic>>> getProfitHistory({
    int page = 1,
    int limit = 50,
    String period = 'monthly',
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyProfits}_${page}_${limit}_$period';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedProfitHistory(cacheKey);
        if (cached != null) {
          return cached;
        }
      }

      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
        'period': period,
      };

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          ApiConstants.portfolioHistory,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse =
            PaginatedResponse<Map<String, dynamic>>.fromJson(
              response.data!,
              (json) => json as Map<String, dynamic>,
            );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheProfitHistory(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch profit history');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Create new investment
  Future<ApiResponse<InvestmentModel>> createInvestment({
    required String planId,
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.investments,
        data: {'planId': planId, 'amount': amount, 'currency': currency},
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        final apiResponse = ApiResponse<InvestmentModel>.fromJson(
          response.data!,
          (json) => InvestmentModel.fromJson(json as Map<String, dynamic>),
        );

        // Clear cache after new investment
        await _clearPortfolioCache();

        return apiResponse;
      }

      throw AppException.serverError('Investment creation failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Withdraw from investment
  Future<ApiResponse<Map<String, dynamic>>> withdrawFromInvestment({
    required String investmentId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.investments}/$investmentId/withdraw',
        data: {'amount': amount, if (reason != null) 'reason': reason},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear cache after withdrawal
        await _clearPortfolioCache();

        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Investment withdrawal failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get available investment plans
  Future<ApiResponse<List<Map<String, dynamic>>>> getInvestmentPlans() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.portfolio}/plans',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch investment plans');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get portfolio comparison data
  Future<ApiResponse<Map<String, dynamic>>> getPortfolioComparison({
    String period = 'monthly',
    List<String>? benchmarks,
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};

      if (benchmarks != null && benchmarks.isNotEmpty) {
        queryParams['benchmarks'] = benchmarks.join(',');
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.portfolio}/comparison',
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch portfolio comparison');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get portfolio recommendations
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecommendations() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.portfolio}/recommendations',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch recommendations');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cachePortfolio(String key, PortfolioModel portfolio) async {
    await StorageService.setCachedData(key, {
      'data': portfolio.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PortfolioModel?> _getCachedPortfolio(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PortfolioModel.fromJson(cached['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheInvestments(
    String key,
    PaginatedResponse<InvestmentModel> investments,
  ) async {
    await StorageService.setCachedData(key, {
      'data': investments.toJson((investment) => investment.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<InvestmentModel>?> _getCachedInvestments(
    String key,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<InvestmentModel>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => InvestmentModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheAnalytics(String key, PortfolioAnalytics analytics) async {
    await StorageService.setCachedData(key, {
      'data': analytics.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PortfolioAnalytics?> _getCachedAnalytics(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PortfolioAnalytics.fromJson(
          cached['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheProfitHistory(
    String key,
    PaginatedResponse<Map<String, dynamic>> profits,
  ) async {
    await StorageService.setCachedData(key, {
      'data': profits.toJson((profit) => profit),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<Map<String, dynamic>>?> _getCachedProfitHistory(
    String key,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<Map<String, dynamic>>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => json as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearPortfolioCache() async {
    final keys = await StorageService.getCacheInfo();
    final portfolioKeys = (keys['keys'] as List)
        .where(
          (key) =>
              key.toString().startsWith(_cacheKeyPortfolio) ||
              key.toString().startsWith(_cacheKeyInvestments) ||
              key.toString().startsWith(_cacheKeyAnalytics),
        )
        .toList();

    for (final key in portfolioKeys) {
      await StorageService.removeCachedData(key.toString());
    }
  }

  /// Clear all portfolio cache
  Future<void> clearPortfolioCache() async {
    await _clearPortfolioCache();
  }

  /// Get portfolio summary for offline mode
  Future<Map<String, dynamic>?> getPortfolioSummary() async {
    try {
      final cached = await _getCachedPortfolio(
        '${_cacheKeyPortfolio}_monthly_true',
      );
      if (cached != null) {
        return {
          'totalValue': cached.overview.totalValue,
          'totalInvested': cached.overview.totalInvested,
          'totalProfits': cached.overview.totalProfits,
          'activeInvestments': cached.overview.activeInvestments,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached portfolio (for offline mode)
  Future<PortfolioModel?> getCachedPortfolio() async {
    return await _getCachedPortfolio('${_cacheKeyPortfolio}_monthly_true');
  }

  /// Utility methods
  bool isInvestmentActive(InvestmentModel investment) {
    return investment.status.toLowerCase() == 'active';
  }

  bool isInvestmentCompleted(InvestmentModel investment) {
    return investment.status.toLowerCase() == 'completed';
  }

  double calculateROI(InvestmentModel investment) {
    if (investment.amount == 0) return 0;
    return ((investment.currentValue - investment.amount) / investment.amount) *
        100;
  }

  double calculateDailyReturn(InvestmentModel investment) {
    if (investment.duration == 0) return 0;
    final totalReturn = investment.currentValue - investment.amount;
    return totalReturn / investment.duration;
  }

  int getDaysRemaining(InvestmentModel investment) {
    if (investment.endDate == null) return 0;
    final now = DateTime.now();
    final daysRemaining = investment.endDate!.difference(now).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  bool isInvestmentExpiringSoon(
    InvestmentModel investment, {
    int daysThreshold = 7,
  }) {
    final daysRemaining = getDaysRemaining(investment);
    return daysRemaining > 0 && daysRemaining <= daysThreshold;
  }

  String getInvestmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return '#4CAF50'; // Green
      case 'completed':
        return '#2196F3'; // Blue
      case 'pending':
        return '#FF9800'; // Orange
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }
}
