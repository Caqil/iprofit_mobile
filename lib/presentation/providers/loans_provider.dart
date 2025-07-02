// lib/presentation/providers/loans_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/loans_repository.dart';
import '../../data/models/loans/loan_model.dart';
import '../../data/models/loans/loan_application.dart';
import '../../data/models/loans/emi_calculation.dart';
import '../../data/models/common/pagination.dart';

part 'loans_provider.g.dart';

// ============================================================================
// LOANS STATE MODEL
// ============================================================================

/// Loans provider state model
class LoansState {
  final List<LoanModel> loans;
  final Pagination? pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool isApplying;
  final bool isCalculating;
  final EMICalculation? lastCalculation;
  final Map<String, dynamic>? eligibility;
  final String currentFilter;
  final String currentSort;
  final String? lastUpdated;

  const LoansState({
    this.loans = const [],
    this.pagination,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.isApplying = false,
    this.isCalculating = false,
    this.lastCalculation,
    this.eligibility,
    this.currentFilter = 'all',
    this.currentSort = 'createdAt',
    this.lastUpdated,
  });

  LoansState copyWith({
    List<LoanModel>? loans,
    Pagination? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? isApplying,
    bool? isCalculating,
    EMICalculation? lastCalculation,
    Map<String, dynamic>? eligibility,
    String? currentFilter,
    String? currentSort,
    String? lastUpdated,
  }) {
    return LoansState(
      loans: loans ?? this.loans,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      isApplying: isApplying ?? this.isApplying,
      isCalculating: isCalculating ?? this.isCalculating,
      lastCalculation: lastCalculation ?? this.lastCalculation,
      eligibility: eligibility ?? this.eligibility,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasLoans => loans.isNotEmpty;
  bool get hasMorePages => pagination?.hasNextPage ?? false;
  int get totalLoans => pagination?.totalItems ?? loans.length;

  // Loan statistics
  List<LoanModel> get activeLoans =>
      loans.where((loan) => loan.status == 'active').toList();
  List<LoanModel> get pendingLoans =>
      loans.where((loan) => loan.status == 'pending').toList();
  List<LoanModel> get completedLoans =>
      loans.where((loan) => loan.status == 'completed').toList();

  double get totalLoanAmount =>
      activeLoans.fold(0.0, (sum, loan) => sum + loan.amount);
  double get totalOutstanding =>
      activeLoans.fold(0.0, (sum, loan) => sum + loan.remainingAmount);
  double get totalEmiAmount =>
      activeLoans.fold(0.0, (sum, loan) => sum + loan.emi);

  bool get hasEligibility => eligibility != null;
  bool get isEligibleForLoan => eligibility?['eligible'] == true;
  double get maxLoanAmount => eligibility?['maxAmount']?.toDouble() ?? 0.0;
}

// ============================================================================
// LOANS PROVIDER
// ============================================================================

@riverpod
class Loans extends _$Loans {
  @override
  LoansState build() {
    // Initialize loans data on provider creation
    _initializeLoans();
    return const LoansState();
  }

  // ===== INITIALIZATION =====

  /// Initialize loans data
  Future<void> _initializeLoans() async {
    await loadLoans();
    await checkEligibility();
  }

  // ===== LOANS MANAGEMENT =====

  /// Load loans with optional filtering
  Future<void> loadLoans({
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
          isLoading: true,
          error: null,
          currentFilter: status,
          currentSort: sortBy,
        );
      } else {
        state = state.copyWith(isLoadingMore: true, error: null);
      }

      final loansRepository = ref.read(loansRepositoryProvider);
      final response = await loansRepository.getUserLoans(
        page: page,
        status: status,
        sortBy: sortBy,
        sortOrder: sortOrder,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<LoanModel> updatedLoans;

        if (page == 1) {
          updatedLoans = response.data;
        } else {
          updatedLoans = [...state.loans, ...response.data];
        }

        state = state.copyWith(
          loans: updatedLoans,
          pagination: response.pagination,
          isLoading: false,
          isLoadingMore: false,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.data.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more loans (pagination)
  Future<void> loadMoreLoans() async {
    if (state.isLoadingMore || !state.hasMorePages) return;

    final nextPage = (state.pagination?.currentPage ?? 0) + 1;
    await loadLoans(
      page: nextPage,
      status: state.currentFilter,
      sortBy: state.currentSort,
    );
  }

  /// Refresh loans list
  Future<void> refreshLoans() async {
    await loadLoans(
      status: state.currentFilter,
      sortBy: state.currentSort,
      forceRefresh: true,
    );
  }

  /// Filter loans by status
  Future<void> filterLoans(String status) async {
    if (state.currentFilter == status) return;

    await loadLoans(status: status);
  }

  /// Sort loans
  Future<void> sortLoans(String sortBy, {String sortOrder = 'desc'}) async {
    await loadLoans(
      status: state.currentFilter,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  // ===== LOAN APPLICATION =====

  /// Apply for a loan
  Future<bool> applyForLoan(LoanApplication request) async {
    try {
      state = state.copyWith(isApplying: true, error: null);

      final loansRepository = ref.read(loansRepositoryProvider);
      final response = await loansRepository.applyForLoan(request);

      if (response.success) {
        state = state.copyWith(isApplying: false);

        // Refresh loans list to include new application
        await refreshLoans();

        return true;
      } else {
        state = state.copyWith(
          isApplying: false,
          error: response.message ?? 'Failed to apply for loan',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isApplying: false, error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== EMI CALCULATION =====

  /// Calculate EMI
  Future<EMICalculation?> calculateEMI({
    required double loanAmount,
    required double interestRate,
    required int tenure,
  }) async {
    try {
      state = state.copyWith(isCalculating: true, error: null);

      final loansRepository = ref.read(loansRepositoryProvider);
      final response = await loansRepository.calculateEMI(
        loanAmount: loanAmount,
        interestRate: interestRate,
        tenure: tenure,
      );

      if (response.success && response.data != null) {
        final calculation = response.data!;
        state = state.copyWith(
          isCalculating: false,
          lastCalculation: calculation,
        );
        return calculation;
      } else {
        state = state.copyWith(
          isCalculating: false,
          error: response.message ?? 'Failed to calculate EMI',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(isCalculating: false, error: _getErrorMessage(e));
      return null;
    }
  }

  /// Clear last calculation
  void clearCalculation() {
    state = state.copyWith(lastCalculation: null);
  }

  // ===== LOAN ELIGIBILITY =====

  /// Check loan eligibility
  Future<void> checkEligibility({
    double? monthlyIncome,
    String? employmentStatus,
    double? requestedAmount,
    int? creditScore,
    List<Map<String, dynamic>>? existingLoans,
  }) async {
    try {
      final loansRepository = ref.read(loansRepositoryProvider);

      // If parameters are provided, make a full eligibility check
      if (monthlyIncome != null &&
          employmentStatus != null &&
          requestedAmount != null) {
        final response = await loansRepository.checkEligibility(
          monthlyIncome: monthlyIncome,
          employmentStatus: employmentStatus,
          requestedAmount: requestedAmount,
          creditScore: creditScore,
          existingLoans: existingLoans,
        );

        if (response.success && response.data != null) {
          state = state.copyWith(eligibility: response.data!);
        }
      } else {
        // For initialization, try to get cached/basic eligibility info
        // You might want to implement a basic eligibility endpoint or use user data
        final response = await loansRepository.checkEligibility(
          monthlyIncome: 50000.0, // Default values for basic check
          employmentStatus: 'employed',
          requestedAmount: 100000.0,
        );

        if (response.success && response.data != null) {
          state = state.copyWith(eligibility: response.data!);
        }
      }
    } catch (e) {
      // Silent fail for eligibility check
    }
  }

  // ===== LOAN DETAILS =====

  /// Get loan details
  Future<LoanModel?> getLoanDetails(String loanId) async {
    try {
      final loansRepository = ref.read(loansRepositoryProvider);
      final response = await loansRepository.getLoanDetails(loanId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load loan details',
        );
      }
    } catch (e) {
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get loan repayment schedule
  Future<List<RepaymentInstallment>> getRepaymentSchedule(String loanId) async {
    try {
      final loansRepository = ref.read(loansRepositoryProvider);
      final response = await loansRepository.getRepaymentSchedule(loanId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load repayment schedule',
        );
      }
    } catch (e) {
      throw AppException.fromException(e as Exception);
    }
  }

  // ===== LOAN REPAYMENT =====

  /// Make loan repayment
  Future<bool> makeRepayment({
    required String loanId,
    required double amount,
    String? paymentMethod,
    String? transactionNote,
  }) async {
    try {
      final loansRepository = ref.read(loansRepositoryProvider);
      final response = await loansRepository.makeRepayment(
        loanId: loanId,
        amount: amount,
        paymentMethod: paymentMethod,
        transactionNote: transactionNote,
      );

      if (response.success) {
        // Refresh loans to update repayment status
        await refreshLoans();
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to process repayment',
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

  /// Get loan by ID
  LoanModel? getLoanById(String loanId) {
    try {
      return state.loans.firstWhere((loan) => loan.id == loanId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has active loans
  bool hasActiveLoans() {
    return state.activeLoans.isNotEmpty;
  }

  /// Get next EMI due date
  DateTime? getNextEmiDueDate() {
    if (state.activeLoans.isEmpty) return null;

    final dueDates = state.activeLoans
        .where((loan) => loan.nextPaymentDate != null)
        .map((loan) => loan.nextPaymentDate!)
        .toList();

    if (dueDates.isEmpty) return null;

    dueDates.sort();
    return dueDates.first;
  }

  /// Force refresh all loans data
  Future<void> refresh() async {
    await Future.wait([refreshLoans(), checkEligibility()]);
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for active loans
@riverpod
List<LoanModel> activeLoans(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.activeLoans));
}

/// Provider for pending loans
@riverpod
List<LoanModel> pendingLoans(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.pendingLoans));
}

/// Provider for total loan amount
@riverpod
double totalLoanAmount(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.totalLoanAmount));
}

/// Provider for total outstanding amount
@riverpod
double totalOutstandingAmount(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.totalOutstanding));
}

/// Provider for total EMI amount
@riverpod
double totalEmiAmount(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.totalEmiAmount));
}

/// Provider for loan eligibility
@riverpod
bool isEligibleForLoan(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.isEligibleForLoan));
}

/// Provider for maximum loan amount
@riverpod
double maxLoanAmount(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.maxLoanAmount));
}

/// Provider for loans loading state
@riverpod
bool isLoansLoading(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.isLoading));
}

/// Provider for loans error
@riverpod
String? loansError(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.error));
}

/// Provider for last EMI calculation
@riverpod
EMICalculation? lastEmiCalculation(Ref ref) {
  return ref.watch(loansProvider.select((state) => state.lastCalculation));
}

/// Provider for next EMI due date
@riverpod
DateTime? nextEmiDueDate(Ref ref) {
  final loansNotifier = ref.watch(loansProvider.notifier);
  return loansNotifier.getNextEmiDueDate();
}
