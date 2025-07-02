// lib/presentation/providers/referrals_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/referrals_repository.dart';
import '../../data/models/referrals/referral_model.dart';
import '../../data/models/referrals/referral_earnings.dart';
import '../../data/models/common/pagination.dart';

part 'referrals_provider.g.dart';

// ============================================================================
// REFERRALS STATE MODEL
// ============================================================================

/// Referrals provider state model
class ReferralsState {
  final ReferralOverview? overview;
  final ReferralLink? referralLink;
  final List<ReferralModel> referrals;
  final Pagination? referralsPagination;
  final List<EarningTransaction> earnings;
  final Pagination? earningsPagination;
  final Map<String, dynamic>? statistics;
  final bool isLoading;
  final bool isLoadingReferrals;
  final bool isLoadingEarnings;
  final bool isGeneratingLink;
  final String? error;
  final String currentEarningsFilter;
  final String currentReferralsFilter;
  final String? lastUpdated;

  const ReferralsState({
    this.overview,
    this.referralLink,
    this.referrals = const [],
    this.referralsPagination,
    this.earnings = const [],
    this.earningsPagination,
    this.statistics,
    this.isLoading = false,
    this.isLoadingReferrals = false,
    this.isLoadingEarnings = false,
    this.isGeneratingLink = false,
    this.error,
    this.currentEarningsFilter = 'all',
    this.currentReferralsFilter = 'all',
    this.lastUpdated,
  });

  ReferralsState copyWith({
    ReferralOverview? overview,
    ReferralLink? referralLink,
    List<ReferralModel>? referrals,
    Pagination? referralsPagination,
    List<EarningTransaction>? earnings,
    Pagination? earningsPagination,
    Map<String, dynamic>? statistics,
    bool? isLoading,
    bool? isLoadingReferrals,
    bool? isLoadingEarnings,
    bool? isGeneratingLink,
    String? error,
    String? currentEarningsFilter,
    String? currentReferralsFilter,
    String? lastUpdated,
  }) {
    return ReferralsState(
      overview: overview ?? this.overview,
      referralLink: referralLink ?? this.referralLink,
      referrals: referrals ?? this.referrals,
      referralsPagination: referralsPagination ?? this.referralsPagination,
      earnings: earnings ?? this.earnings,
      earningsPagination: earningsPagination ?? this.earningsPagination,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      isLoadingReferrals: isLoadingReferrals ?? this.isLoadingReferrals,
      isLoadingEarnings: isLoadingEarnings ?? this.isLoadingEarnings,
      isGeneratingLink: isGeneratingLink ?? this.isGeneratingLink,
      error: error,
      currentEarningsFilter:
          currentEarningsFilter ?? this.currentEarningsFilter,
      currentReferralsFilter:
          currentReferralsFilter ?? this.currentReferralsFilter,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasOverview => overview != null;
  bool get hasReferralLink => referralLink != null;
  bool get hasReferrals => referrals.isNotEmpty;
  bool get hasEarnings => earnings.isNotEmpty;
  bool get hasMoreReferrals => referralsPagination?.hasNextPage ?? false;
  bool get hasMoreEarnings => earningsPagination?.hasNextPage ?? false;
  bool get hasStatistics => statistics != null;

  // Overview statistics
  int get totalReferrals => overview?.totalReferrals ?? 0;
  int get activeReferrals => overview?.paidReferrals ?? 0;
  double get totalEarnings => overview?.totalEarnings ?? 0.0;
  double get pendingEarnings => overview?.pendingEarnings ?? 0.0;
  double get withdrawnEarnings =>
      statistics?['withdrawnEarnings']?.toDouble() ?? 0.0;
  double get todayEarnings => statistics?['todayEarnings']?.toDouble() ?? 0.0;
  double get monthlyEarnings =>
      statistics?['monthlyEarnings']?.toDouble() ?? 0.0;

  // Referral link information
  String get referralCode => referralLink?.referralCode ?? '';
  String get referralUrl => referralLink?.referralUrl ?? '';
  int get referralClicks => referralLink?.stats.totalClicks ?? 0;
  double get conversionRate => referralLink?.stats.conversionRate ?? 0.0;

  // Referral categories
  List<ReferralModel> get pendingReferrals =>
      referrals.where((r) => r.status == 'pending').toList();
  List<ReferralModel> get verifiedReferrals =>
      referrals.where((r) => r.status == 'verified').toList();
  List<ReferralModel> get rejectedReferrals =>
      referrals.where((r) => r.status == 'rejected').toList();

  // Earnings categories
  List<EarningTransaction> get pendingEarningsTransactions =>
      earnings.where((e) => e.status == 'pending').toList();
  List<EarningTransaction> get completedEarningsTransactions =>
      earnings.where((e) => e.status == 'completed').toList();
  List<EarningTransaction> get commissionEarnings =>
      earnings.where((e) => e.type == 'commission').toList();
  List<EarningTransaction> get bonusEarnings =>
      earnings.where((e) => e.type == 'bonus').toList();
}

// ============================================================================
// REFERRALS PROVIDER
// ============================================================================

@riverpod
class Referrals extends _$Referrals {
  @override
  ReferralsState build() {
    // Initialize referrals data on provider creation
    _initializeReferrals();
    return const ReferralsState();
  }

  // ===== INITIALIZATION =====

  /// Initialize referrals data
  Future<void> _initializeReferrals() async {
    await Future.wait([
      loadOverview(),
      loadReferralLink(),
      loadReferrals(),
      loadEarnings(),
    ]);
  }

  // ===== OVERVIEW MANAGEMENT =====

  /// Load referral overview
  Future<void> loadOverview({bool forceRefresh = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.getReferralOverview(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          overview: response.data!,
          isLoading: false,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load referral overview',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
    }
  }

  /// Refresh overview data
  Future<void> refreshOverview() async {
    await loadOverview(forceRefresh: true);
  }

  // ===== REFERRAL LINK MANAGEMENT =====

  /// Load referral link
  Future<void> loadReferralLink({bool forceRefresh = false}) async {
    try {
      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.getReferralLink(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(referralLink: response.data!);
      }
    } catch (e) {
      // Silent fail for referral link
    }
  }

  /// Generate new referral link
  Future<bool> generateReferralLink() async {
    try {
      state = state.copyWith(isGeneratingLink: true, error: null);

      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.generateNewReferralLink();

      if (response.success && response.data != null) {
        state = state.copyWith(
          referralLink: response.data!,
          isGeneratingLink: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isGeneratingLink: false,
          error: response.message ?? 'Failed to generate referral link',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isGeneratingLink: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  // ===== REFERRALS MANAGEMENT =====

  /// Load referrals with pagination and filtering
  Future<void> loadReferrals({
    int page = 1,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoadingReferrals: true,
          error: null,
          currentReferralsFilter: status,
        );
      } else {
        state = state.copyWith(isLoadingReferrals: true, error: null);
      }

      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.getReferrals(
        page: page,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<ReferralModel> updatedReferrals;

        if (page == 1) {
          updatedReferrals = response.data;
        } else {
          updatedReferrals = [...state.referrals, ...response.data];
        }

        state = state.copyWith(
          referrals: updatedReferrals,
          referralsPagination: response.pagination,
          isLoadingReferrals: false,
        );
      } else {
        state = state.copyWith(
          isLoadingReferrals: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingReferrals: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more referrals (pagination)
  Future<void> loadMoreReferrals() async {
    if (state.isLoadingReferrals || !state.hasMoreReferrals) return;

    final nextPage = (state.referralsPagination?.currentPage ?? 0) + 1;
    await loadReferrals(page: nextPage, status: state.currentReferralsFilter);
  }

  /// Filter referrals by status
  Future<void> filterReferrals(String status) async {
    if (state.currentReferralsFilter == status) return;

    await loadReferrals(status: status);
  }

  /// Refresh referrals list
  Future<void> refreshReferrals() async {
    await loadReferrals(
      status: state.currentReferralsFilter,
      forceRefresh: true,
    );
  }

  // ===== EARNINGS MANAGEMENT =====

  /// Load earnings with pagination and filtering
  Future<void> loadEarnings({
    int page = 1,
    String type = 'all',
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoadingEarnings: true,
          error: null,
          currentEarningsFilter: type,
        );
      } else {
        state = state.copyWith(isLoadingEarnings: true, error: null);
      }

      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.getReferralEarnings(
        page: page,
        type: type,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<EarningTransaction> updatedEarnings;

        if (page == 1) {
          updatedEarnings = response.data;
        } else {
          updatedEarnings = [...state.earnings, ...response.data];
        }

        state = state.copyWith(
          earnings: updatedEarnings,
          earningsPagination: response.pagination,
          isLoadingEarnings: false,
        );
      } else {
        state = state.copyWith(
          isLoadingEarnings: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingEarnings: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more earnings (pagination)
  Future<void> loadMoreEarnings() async {
    if (state.isLoadingEarnings || !state.hasMoreEarnings) return;

    final nextPage = (state.earningsPagination?.currentPage ?? 0) + 1;
    await loadEarnings(page: nextPage, type: state.currentEarningsFilter);
  }

  /// Filter earnings by type
  Future<void> filterEarnings(String type) async {
    if (state.currentEarningsFilter == type) return;

    await loadEarnings(type: type);
  }

  /// Refresh earnings list
  Future<void> refreshEarnings() async {
    await loadEarnings(type: state.currentEarningsFilter, forceRefresh: true);
  }

  // ===== STATISTICS =====

  /// Load referral statistics
  Future<void> loadStatistics({
    String timeframe = '30d',
    bool forceRefresh = false,
  }) async {
    try {
      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.getReferralStatistics(
        timeframe: timeframe,
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(statistics: response.data!);
      }
    } catch (e) {
      // Silent fail for statistics
    }
  }

  // ===== REFERRAL ACTIONS =====

  /// Withdraw referral earnings
  Future<bool> withdrawEarnings({
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.withdrawEarnings(
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      if (response.success) {
        // Refresh overview and earnings
        await Future.wait([refreshOverview(), refreshEarnings()]);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to withdraw earnings',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
      return false;
    }
  }

  /// Get referral details
  Future<ReferralModel?> getReferralDetails(String referralId) async {
    try {
      final referralsRepository = ref.read(referralsRepositoryProvider);
      final response = await referralsRepository.getReferralDetails(referralId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load referral details',
        );
      }
    } catch (e) {
      throw AppException.fromException(e as Exception);
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

  /// Get referral by ID
  ReferralModel? getReferralById(String referralId) {
    try {
      return state.referrals.firstWhere((r) => r.id == referralId);
    } catch (e) {
      return null;
    }
  }

  /// Get earning transaction by ID
  EarningTransaction? getEarningById(String earningId) {
    try {
      return state.earnings.firstWhere((e) => e.id == earningId);
    } catch (e) {
      return null;
    }
  }

  /// Get earnings chart data
  List<Map<String, dynamic>> getEarningsChartData({
    String timeframe = '30d',
    int maxPoints = 30,
  }) {
    // Filter earnings by timeframe and prepare chart data
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month -
          (timeframe == '1y'
              ? 12
              : timeframe == '3m'
              ? 3
              : 1),
      now.day,
    );

    final filteredEarnings = state.earnings
        .where((e) => e.createdAt.isAfter(startDate))
        .take(maxPoints)
        .toList();

    // Group by date and sum amounts
    final chartData = <String, double>{};
    for (final earning in filteredEarnings) {
      final dateKey = earning.createdAt.toIso8601String().split('T')[0];
      chartData[dateKey] = (chartData[dateKey] ?? 0.0) + earning.amount;
    }

    return chartData.entries
        .map((e) => {'date': e.key, 'amount': e.value})
        .toList();
  }

  /// Get conversion funnel data
  Map<String, int> getConversionFunnelData() {
    return {
      'Clicks': state.referralClicks,
      'Registrations': state.totalReferrals,
      'Verified': state.activeReferrals,
      'Earnings': state.earnings.length,
    };
  }

  /// Force refresh all referrals data
  Future<void> refresh() async {
    await Future.wait([
      refreshOverview(),
      loadReferralLink(forceRefresh: true),
      refreshReferrals(),
      refreshEarnings(),
      loadStatistics(forceRefresh: true),
    ]);
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for total referrals count
@riverpod
int totalReferralsCount(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.totalReferrals));
}

/// Provider for total earnings
@riverpod
double totalReferralEarnings(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.totalEarnings));
}

/// Provider for pending earnings
@riverpod
double pendingReferralEarnings(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.pendingEarnings));
}

/// Provider for referral code
@riverpod
String referralCode(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.referralCode));
}

/// Provider for referral URL
@riverpod
String referralUrl(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.referralUrl));
}

/// Provider for active referrals
@riverpod
List<ReferralModel> activeReferrals(Ref ref) {
  return ref.watch(
    referralsProvider.select((state) => state.verifiedReferrals),
  );
}

/// Provider for referrals loading state
@riverpod
bool isReferralsLoading(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.isLoading));
}

/// Provider for referrals error
@riverpod
String? referralsError(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.error));
}

/// Provider for monthly earnings
@riverpod
double monthlyReferralEarnings(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.monthlyEarnings));
}

/// Provider for conversion rate
@riverpod
double referralConversionRate(Ref ref) {
  return ref.watch(referralsProvider.select((state) => state.conversionRate));
}
