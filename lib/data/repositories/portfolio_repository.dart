import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/portfolio/portfolio_model.dart';
import '../models/portfolio/investment_model.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(ref.read(apiServiceProvider));
});

class PortfolioRepository {
  final ApiService _apiService;
  static const String _portfolioCacheKey = 'portfolio_data';
  static const String _investmentsCacheKey = 'investments_data';
  static const String _profitsCacheKey = 'profits_data';

  PortfolioRepository(this._apiService);

  Future<ApiResponse<PortfolioModel>> getPortfolio({
    bool includeAnalytics = true,
    String period = 'monthly',
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = {
        'includeAnalytics': includeAnalytics.toString(),
        'period': period,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.portfolio,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<PortfolioModel>.fromJson(
          response.data!,
          (json) => PortfolioModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache portfolio data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _portfolioCacheKey,
            apiResponse.data!.toJson(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(_portfolioCacheKey);
      if (cachedData != null) {
        return ApiResponse<PortfolioModel>(
          success: true,
          data: PortfolioModel.fromJson(cachedData),
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<PaginatedResponse<InvestmentModel>> getInvestments({
    int page = 1,
    int limit = 10,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'status': status,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/investments',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse = PaginatedResponse<InvestmentModel>.fromJson(
          response.data!,
          (json) => InvestmentModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache investments data locally (first page only)
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _investmentsCacheKey,
            paginatedResponse.data
                .map((investment) => investment.toJson())
                .toList(),
          );
        }

        return paginatedResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(
          _investmentsCacheKey,
        );
        if (cachedData != null) {
          final investments = (cachedData as List)
              .map((json) => InvestmentModel.fromJson(json))
              .toList();

          return PaginatedResponse<InvestmentModel>(
            success: true,
            data: investments,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: investments.length,
              itemsPerPage: investments.length,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
            timestamp: DateTime.now(),
          );
        }
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<InvestmentModel>> getInvestmentDetails(
    String investmentId,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/investments/$investmentId',
      );

      if (response.data != null) {
        return ApiResponse<InvestmentModel>.fromJson(
          response.data!,
          (json) => InvestmentModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<InvestmentModel>> createInvestment({
    required String planId,
    required double amount,
    String? currency,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/investments',
        data: {
          'planId': planId,
          'amount': amount,
          if (currency != null) 'currency': currency,
        },
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<InvestmentModel>.fromJson(
          response.data!,
          (json) => InvestmentModel.fromJson(json as Map<String, dynamic>),
        );

        // Refresh portfolio and investments cache after new investment
        if (apiResponse.success) {
          await getPortfolio(forceRefresh: true);
          await getInvestments(forceRefresh: true);
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> withdrawInvestment(String investmentId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/investments/$investmentId/withdraw',
      );

      if (response.data != null) {
        // Refresh portfolio and investments cache after withdrawal
        await getPortfolio(forceRefresh: true);
        await getInvestments(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<PaginatedResponse<Map<String, dynamic>>> getProfitHistory({
    int page = 1,
    int limit = 50,
    String period = 'monthly',
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'period': period,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.profits,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse =
            PaginatedResponse<Map<String, dynamic>>.fromJson(
              response.data!,
              (json) => json as Map<String, dynamic>,
            );

        // Cache profits data locally (first page only)
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _profitsCacheKey,
            paginatedResponse.data,
          );
        }

        return paginatedResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(_profitsCacheKey);
        if (cachedData != null) {
          final profits = cachedData as List<Map<String, dynamic>>;

          return PaginatedResponse<Map<String, dynamic>>(
            success: true,
            data: profits,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: profits.length,
              itemsPerPage: profits.length,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
            timestamp: DateTime.now(),
          );
        }
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getEarningsSummary({
    String type = 'all',
    String period = 'monthly',
    bool includeBreakdown = true,
  }) async {
    try {
      final queryParams = {
        'type': type,
        'period': period,
        'includeBreakdown': includeBreakdown.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.earnings,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getPerformanceHistory({
    String period = 'daily',
    int days = 30,
  }) async {
    try {
      final queryParams = {'period': period, 'days': days.toString()};

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/portfolio/performance',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAvailablePlans({
    String type = 'all',
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = {'type': type, 'active': activeOnly.toString()};

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.plans,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPortfolioAnalytics({
    String period = 'monthly',
    bool includeProjections = true,
  }) async {
    try {
      final queryParams = {
        'period': period,
        'includeProjections': includeProjections.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/portfolio/analytics',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> reinvestProfits({
    required String investmentId,
    required double amount,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/investments/$investmentId/reinvest',
        data: {'amount': amount},
      );

      if (response.data != null) {
        // Refresh portfolio and investments cache after reinvestment
        await getPortfolio(forceRefresh: true);
        await getInvestments(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getInvestmentProjections({
    required String planId,
    required double amount,
    int duration = 30,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/investments/projections',
        data: {'planId': planId, 'amount': amount, 'duration': duration},
      );

      if (response.data != null) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  // Cache management methods
  Future<PortfolioModel?> getCachedPortfolio() async {
    try {
      final cachedData = await StorageService.getCachedData(_portfolioCacheKey);
      if (cachedData != null) {
        return PortfolioModel.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<InvestmentModel>?> getCachedInvestments() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _investmentsCacheKey,
      );
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => InvestmentModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedProfits() async {
    try {
      final cachedData = await StorageService.getCachedData(_profitsCacheKey);
      if (cachedData != null) {
        return (cachedData as List).cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearPortfolioCache() async {
    await StorageService.removeCachedData(_portfolioCacheKey);
    await StorageService.removeCachedData(_investmentsCacheKey);
    await StorageService.removeCachedData(_profitsCacheKey);
  }

  Future<Map<String, dynamic>> getPortfolioSummary() async {
    try {
      final portfolio = await getCachedPortfolio();
      if (portfolio == null) return {};

      return {
        'totalValue': portfolio.overview.totalValue,
        'totalInvested': portfolio.overview.totalInvested,
        'totalProfits': portfolio.overview.totalProfits,
        'currentBalance': portfolio.overview.currentBalance,
        'activeInvestments': portfolio.overview.activeInvestments,
        'totalInvestments': portfolio.overview.totalInvestments,
        'profitMargin': portfolio.overview.totalInvested > 0
            ? (portfolio.overview.totalProfits /
                      portfolio.overview.totalInvested) *
                  100
            : 0.0,
      };
    } catch (e) {
      return {};
    }
  }
}
