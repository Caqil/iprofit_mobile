import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/referrals/referral_model.dart';
import '../models/referrals/referral_earnings.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final referralsRepositoryProvider = Provider<ReferralsRepository>((ref) {
  return ReferralsRepository(ref.read(apiServiceProvider));
});

class ReferralsRepository {
  final ApiService _apiService;
  static const String _referralsOverviewCacheKey = 'referrals_overview_data';
  static const String _referralLinkCacheKey = 'referral_link_data';
  static const String _referralEarningsCacheKey = 'referral_earnings_data';
  static const String _referralsCacheKey = 'referrals_data';

  ReferralsRepository(this._apiService);

  Future<PaginatedResponse<ReferralModel>> getReferrals({
    int page = 1,
    int limit = 20,
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
        ApiConstants.referrals,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse = PaginatedResponse<ReferralModel>.fromJson(
          response.data!,
          (json) => ReferralModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache referrals data locally (first page only)
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _referralsCacheKey,
            paginatedResponse.data
                .map((referral) => referral.toJson())
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
          _referralsCacheKey,
        );
        if (cachedData != null) {
          final referrals = (cachedData as List)
              .map((json) => ReferralModel.fromJson(json))
              .toList();

          return PaginatedResponse<ReferralModel>(
            success: true,
            data: referrals,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: referrals.length,
              itemsPerPage: referrals.length,
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

  Future<ApiResponse<ReferralOverview>> getReferralOverview() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.referrals}/overview',
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<ReferralOverview>.fromJson(
          response.data!,
          (json) => ReferralOverview.fromJson(json as Map<String, dynamic>),
        );

        // Cache referrals overview data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _referralsOverviewCacheKey,
            apiResponse.data!.toJson(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(
        _referralsOverviewCacheKey,
      );
      if (cachedData != null) {
        return ApiResponse<ReferralOverview>(
          success: true,
          data: ReferralOverview.fromJson(cachedData),
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<ReferralLink>> getReferralLink() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.referralLink,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<ReferralLink>.fromJson(
          response.data!,
          (json) => ReferralLink.fromJson(json as Map<String, dynamic>),
        );

        // Cache referral link data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _referralLinkCacheKey,
            apiResponse.data!.toJson(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(
        _referralLinkCacheKey,
      );
      if (cachedData != null) {
        return ApiResponse<ReferralLink>(
          success: true,
          data: ReferralLink.fromJson(cachedData),
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<PaginatedResponse<EarningTransaction>> getReferralEarnings({
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
        ApiConstants.referralEarnings,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse =
            PaginatedResponse<EarningTransaction>.fromJson(
              response.data!,
              (json) =>
                  EarningTransaction.fromJson(json as Map<String, dynamic>),
            );

        // Cache referral earnings data locally (first page only)
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _referralEarningsCacheKey,
            paginatedResponse.data.map((earning) => earning.toJson()).toList(),
          );
        }

        return paginatedResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(
          _referralEarningsCacheKey,
        );
        if (cachedData != null) {
          final earnings = (cachedData as List)
              .map((json) => EarningTransaction.fromJson(json))
              .toList();

          return PaginatedResponse<EarningTransaction>(
            success: true,
            data: earnings,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: earnings.length,
              itemsPerPage: earnings.length,
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

  Future<ApiResponse<ReferralEarnings>> getReferralEarningsAnalytics({
    String period = 'monthly',
  }) async {
    try {
      final queryParams = {'period': period};

      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.referralEarnings}/analytics',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        return ApiResponse<ReferralEarnings>.fromJson(
          response.data!,
          (json) => ReferralEarnings.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> shareReferralLink({
    required String platform,
    String? customMessage,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConstants.referralLink}/share',
        data: {
          'platform': platform,
          if (customMessage != null) 'customMessage': customMessage,
        },
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> trackReferralClick({
    required String referralCode,
    String? source,
    String? medium,
    String? campaign,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/referrals/track-click',
        data: {
          'referralCode': referralCode,
          if (source != null) 'source': source,
          if (medium != null) 'medium': medium,
          if (campaign != null) 'campaign': campaign,
        },
      );

      if (response.data != null) {
        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getReferralStats({
    String period = 'monthly',
    bool includeBreakdown = true,
  }) async {
    try {
      final queryParams = {
        'period': period,
        'includeBreakdown': includeBreakdown.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.referrals}/stats',
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

  Future<ApiResponse<List<Map<String, dynamic>>>> getReferralLeaderboard({
    String period = 'monthly',
    int limit = 10,
  }) async {
    try {
      final queryParams = {'period': period, 'limit': limit.toString()};

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/referrals/leaderboard',
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

  Future<ApiResponse<void>> withdrawReferralEarnings({
    required double amount,
    String? withdrawalMethod,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConstants.referralEarnings}/withdraw',
        data: {
          'amount': amount,
          if (withdrawalMethod != null) 'withdrawalMethod': withdrawalMethod,
        },
      );

      if (response.data != null) {
        // Refresh referral data after withdrawal
        await getReferralOverview();
        await getReferralEarnings(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> requestPayoutEarnings() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConstants.referralEarnings}/request-payout',
      );

      if (response.data != null) {
        // Refresh referral data after payout request
        await getReferralOverview();
        await getReferralEarnings(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getReferralCommissionRates() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/referrals/commission-rates',
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

  Future<ApiResponse<List<Map<String, dynamic>>>> getReferralHistory({
    int page = 1,
    int limit = 20,
    String type = 'all',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'type': type,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.referrals}/history',
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

  // Cache management methods
  Future<ReferralOverview?> getCachedReferralOverview() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _referralsOverviewCacheKey,
      );
      if (cachedData != null) {
        return ReferralOverview.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ReferralLink?> getCachedReferralLink() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _referralLinkCacheKey,
      );
      if (cachedData != null) {
        return ReferralLink.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<EarningTransaction>?> getCachedReferralEarnings() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _referralEarningsCacheKey,
      );
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => EarningTransaction.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ReferralModel>?> getCachedReferrals() async {
    try {
      final cachedData = await StorageService.getCachedData(_referralsCacheKey);
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => ReferralModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearReferralsCache() async {
    await StorageService.removeCachedData(_referralsOverviewCacheKey);
    await StorageService.removeCachedData(_referralLinkCacheKey);
    await StorageService.removeCachedData(_referralEarningsCacheKey);
    await StorageService.removeCachedData(_referralsCacheKey);
  }

  Future<Map<String, dynamic>> getReferralsSummary() async {
    try {
      final overview = await getCachedReferralOverview();
      if (overview == null) return {};

      return {
        'totalReferrals': overview.totalReferrals,
        'paidReferrals': overview.paidReferrals,
        'totalEarnings': overview.totalEarnings,
        'pendingEarnings': overview.pendingEarnings,
        'conversionRate': overview.totalReferrals > 0
            ? (overview.paidReferrals / overview.totalReferrals) * 100
            : 0.0,
      };
    } catch (e) {
      return {};
    }
  }
}
