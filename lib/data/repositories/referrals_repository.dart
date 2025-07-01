import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/referrals/referral_model.dart';
import '../models/referrals/referral_earnings.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/storage_service.dart';

final referralsRepositoryProvider = Provider<ReferralsRepository>((ref) {
  return ReferralsRepository(ref.read(apiClientProvider));
});

class ReferralsRepository {
  final ApiClient _apiClient;
  static const String _cacheKeyReferrals = 'referrals';
  static const String _cacheKeyOverview = 'referral_overview';
  static const String _cacheKeyLink = 'referral_link';
  static const String _cacheKeyEarnings = 'referral_earnings';
  static const String _cacheKeyStats = 'referral_stats';
  static const Duration _cacheExpiry = Duration(minutes: 15);

  ReferralsRepository(this._apiClient);

  /// Get referral overview
  Future<ApiResponse<ReferralOverview>> getReferralOverview({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedOverview();
        if (cached != null) {
          return ApiResponse<ReferralOverview>(
            success: true,
            data: cached,
            message: 'Referral overview loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.referrals,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<ReferralOverview>.fromJson(
          response.data!,
          (json) => ReferralOverview.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheOverview(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch referral overview');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get referrals with pagination
  Future<PaginatedResponse<ReferralModel>> getReferrals({
    int page = 1,
    int limit = 20,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyReferrals}_${page}_${limit}_$status';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedReferrals(cacheKey);
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
        ApiConstants.getEndpointWithQuery(ApiConstants.referrals, queryParams),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse = PaginatedResponse<ReferralModel>.fromJson(
          response.data!,
          (json) => ReferralModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheReferrals(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch referrals');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get referral link and QR code
  Future<ApiResponse<ReferralLink>> getReferralLink({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedLink();
        if (cached != null) {
          return ApiResponse<ReferralLink>(
            success: true,
            data: cached,
            message: 'Referral link loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.referralLink,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<ReferralLink>.fromJson(
          response.data!,
          (json) => ReferralLink.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheLink(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch referral link');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get referral earnings with pagination
  Future<PaginatedResponse<EarningTransaction>> getReferralEarnings({
    int page = 1,
    int limit = 50,
    String period = 'monthly',
    String? startDate,
    String? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyEarnings}_${page}_${limit}_$period';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedEarnings(cacheKey);
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
          ApiConstants.referralEarnings,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse =
            PaginatedResponse<EarningTransaction>.fromJson(
              response.data!,
              (json) =>
                  EarningTransaction.fromJson(json as Map<String, dynamic>),
            );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheEarnings(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch referral earnings');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get detailed referral earnings analytics
  Future<ApiResponse<ReferralEarnings>> getReferralEarningsAnalytics({
    String period = 'monthly',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyEarnings}_analytics_$period';

      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedEarningsAnalytics(cacheKey);
        if (cached != null) {
          return ApiResponse<ReferralEarnings>(
            success: true,
            data: cached,
            message: 'Referral earnings analytics loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.referralEarnings}/analytics',
          {'period': period},
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<ReferralEarnings>.fromJson(
          response.data!,
          (json) => ReferralEarnings.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheEarningsAnalytics(cacheKey, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch earnings analytics');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get referral statistics
  Future<ApiResponse<ReferralStats>> getReferralStats({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedStats();
        if (cached != null) {
          return ApiResponse<ReferralStats>(
            success: true,
            data: cached,
            message: 'Referral stats loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.referralStats,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<ReferralStats>.fromJson(
          response.data!,
          (json) => ReferralStats.fromJson(json as Map<String, dynamic>),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheStats(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch referral stats');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get referral history
  Future<PaginatedResponse<Map<String, dynamic>>> getReferralHistory({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
      };

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          ApiConstants.referralHistory,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return PaginatedResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch referral history');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Generate new referral link (if supported)
  Future<ApiResponse<ReferralLink>> generateNewReferralLink() async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.referralLink}/generate',
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        final apiResponse = ApiResponse<ReferralLink>.fromJson(
          response.data!,
          (json) => ReferralLink.fromJson(json as Map<String, dynamic>),
        );

        // Update cache with new link
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheLink(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to generate new referral link');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Track referral link click
  Future<ApiResponse<void>> trackReferralClick({
    required String referralCode,
    Map<String, dynamic>? trackingData,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.referralLink}/track-click',
        data: {
          'referralCode': referralCode,
          if (trackingData != null) 'trackingData': trackingData,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Failed to track referral click');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get referral leaderboard
  Future<ApiResponse<List<Map<String, dynamic>>>> getReferralLeaderboard({
    String period = 'monthly',
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.referrals}/leaderboard',
          {'period': period, 'limit': limit},
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch referral leaderboard');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get referral commission rates
  Future<ApiResponse<Map<String, dynamic>>> getCommissionRates() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.referrals}/commission-rates',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch commission rates');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cacheOverview(ReferralOverview overview) async {
    await StorageService.setCachedData(_cacheKeyOverview, {
      'data': overview.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<ReferralOverview?> _getCachedOverview() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyOverview,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return ReferralOverview.fromJson(
          cached['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheReferrals(
    String key,
    PaginatedResponse<ReferralModel> referrals,
  ) async {
    await StorageService.setCachedData(key, {
      'data': referrals.toJson((referral) => referral.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<ReferralModel>?> _getCachedReferrals(
    String key,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<ReferralModel>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => ReferralModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheLink(ReferralLink link) async {
    await StorageService.setCachedData(_cacheKeyLink, {
      'data': link.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<ReferralLink?> _getCachedLink() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyLink,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return ReferralLink.fromJson(cached['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheEarnings(
    String key,
    PaginatedResponse<EarningTransaction> earnings,
  ) async {
    await StorageService.setCachedData(key, {
      'data': earnings.toJson((earning) => earning.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<EarningTransaction>?> _getCachedEarnings(
    String key,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<EarningTransaction>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => EarningTransaction.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheEarningsAnalytics(
    String key,
    ReferralEarnings earnings,
  ) async {
    await StorageService.setCachedData(key, {
      'data': earnings.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<ReferralEarnings?> _getCachedEarningsAnalytics(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return ReferralEarnings.fromJson(
          cached['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheStats(ReferralStats stats) async {
    await StorageService.setCachedData(_cacheKeyStats, {
      'data': stats.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<ReferralStats?> _getCachedStats() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyStats,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return ReferralStats.fromJson(cached['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearReferralsCache() async {
    final keys = await StorageService.getCacheInfo();
    final referralKeys = (keys['keys'] as List)
        .where(
          (key) =>
              key.toString().startsWith(_cacheKeyReferrals) ||
              key.toString().startsWith(_cacheKeyEarnings),
        )
        .toList();

    for (final key in referralKeys) {
      await StorageService.removeCachedData(key.toString());
    }

    // Also clear other referral caches
    await Future.wait([
      StorageService.removeCachedData(_cacheKeyOverview),
      StorageService.removeCachedData(_cacheKeyLink),
      StorageService.removeCachedData(_cacheKeyStats),
    ]);
  }

  /// Clear all referrals cache
  Future<void> clearReferralsCache() async {
    await _clearReferralsCache();
  }

  /// Get referrals summary for offline mode
  Future<Map<String, dynamic>?> getReferralsSummary() async {
    try {
      final overview = await _getCachedOverview();
      if (overview != null) {
        return {
          'totalReferrals': overview.totalReferrals,
          'paidReferrals': overview.paidReferrals,
          'totalEarnings': overview.totalEarnings,
          'pendingEarnings': overview.pendingEarnings,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached referral data (for offline mode)
  Future<ReferralOverview?> getCachedReferralOverview() async {
    return await _getCachedOverview();
  }

  /// Utility methods
  bool isReferralActive(ReferralModel referral) {
    return referral.status.toLowerCase() == 'active';
  }

  bool isReferralPaid(ReferralModel referral) {
    return referral.status.toLowerCase() == 'paid';
  }

  double calculateTotalBonus(ReferralModel referral) {
    return referral.bonusAmount + referral.profitBonus;
  }

  String getReferralStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return '#4CAF50'; // Green
      case 'paid':
        return '#2196F3'; // Blue
      case 'pending':
        return '#FF9800'; // Orange
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }

  String getReferralStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'paid':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Calculate conversion rate
  double calculateConversionRate(ReferralStats stats) {
    if (stats.totalClicks == 0) return 0;
    return (stats.totalSignups / stats.totalClicks) * 100;
  }

  /// Format referral code for display
  String formatReferralCode(String code) {
    if (code.length <= 6) return code;
    return '${code.substring(0, 3)}***${code.substring(code.length - 3)}';
  }

  /// Generate shareable referral message
  String generateShareMessage(ReferralLink link) {
    return '''
🚀 Join me on IProfit and start earning! 

Use my referral code: ${link.referralCode}
Or click this link: ${link.referralUrl}

Start investing and earning passive income today! 💰
''';
  }
}
