import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/loans/loan_model.dart';
import '../models/loans/loan_application.dart';
import '../models/loans/emi_calculation.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/storage_service.dart';

final loansRepositoryProvider = Provider<LoansRepository>((ref) {
  return LoansRepository(ref.read(apiClientProvider));
});

class LoansRepository {
  final ApiClient _apiClient;
  static const String _cacheKeyLoans = 'user_loans';
  static const String _cacheKeyCalculations = 'emi_calculations';
  static const Duration _cacheExpiry = Duration(minutes: 15);

  LoansRepository(this._apiClient);

  /// Get user loans with pagination
  Future<PaginatedResponse<LoanModel>> getUserLoans({
    int page = 1,
    int limit = 20,
    String status = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyLoans}_${page}_${limit}_$status';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedLoans(cacheKey);
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
        ApiConstants.getEndpointWithQuery(ApiConstants.loans, queryParams),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse = PaginatedResponse<LoanModel>.fromJson(
          response.data!,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheLoans(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch loans');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Apply for a new loan
  Future<ApiResponse<LoanModel>> applyForLoan(
    LoanApplication application,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.loanApplication,
        data: application.toJson(),
      );

      if (response.statusCode == ApiConstants.statusCreated) {
        final apiResponse = ApiResponse<LoanModel>.fromJson(
          response.data!,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );

        // Clear loans cache after new application
        await _clearLoansCache();

        return apiResponse;
      }

      throw AppException.serverError('Loan application failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get loan details by ID
  Future<ApiResponse<LoanModel>> getLoanDetails(String loanId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.loanDetails}/$loanId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<LoanModel>.fromJson(
          response.data!,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw AppException.serverError('Failed to fetch loan details');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Calculate EMI
  Future<ApiResponse<EMICalculation>> calculateEMI({
    required double loanAmount,
    required double interestRate,
    required int tenure,
  }) async {
    try {
      final cacheKey =
          '${_cacheKeyCalculations}_${loanAmount}_${interestRate}_$tenure';

      // Check cache first
      final cached = await _getCachedCalculation(cacheKey);
      if (cached != null) {
        return ApiResponse<EMICalculation>(
          success: true,
          data: cached,
          message: 'EMI calculation loaded from cache',
          timestamp: DateTime.now(),
        );
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.emiCalculator,
        data: {
          'loanAmount': loanAmount,
          'interestRate': interestRate,
          'tenure': tenure,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<EMICalculation>.fromJson(
          response.data!,
          (json) => EMICalculation.fromJson(json as Map<String, dynamic>),
        );

        // Cache the calculation
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheCalculation(cacheKey, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('EMI calculation failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get loan repayment schedule
  Future<ApiResponse<List<RepaymentInstallment>>> getRepaymentSchedule(
    String loanId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.loanRepaymentSchedule}/$loanId/repayment-schedule',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<RepaymentInstallment>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map(
                (item) =>
                    RepaymentInstallment.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch repayment schedule');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Make loan repayment
  Future<ApiResponse<Map<String, dynamic>>> makeRepayment({
    required String loanId,
    required double amount,
    String? paymentMethod,
    String? transactionNote,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.loanRepayment}/$loanId/repayment',
        data: {
          'amount': amount,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
          if (transactionNote != null) 'transactionNote': transactionNote,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear loans cache after repayment
        await _clearLoansCache();

        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Loan repayment failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Check loan eligibility
  Future<ApiResponse<Map<String, dynamic>>> checkEligibility({
    required double monthlyIncome,
    required String employmentStatus,
    required double requestedAmount,
    int? creditScore,
    List<Map<String, dynamic>>? existingLoans,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.loanEligibility,
        data: {
          'monthlyIncome': monthlyIncome,
          'employmentStatus': employmentStatus,
          'requestedAmount': requestedAmount,
          if (creditScore != null) 'creditScore': creditScore,
          if (existingLoans != null) 'existingLoans': existingLoans,
        },
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Eligibility check failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get loan statistics
  Future<ApiResponse<Map<String, dynamic>>> getLoanStatistics() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.loans}/statistics',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch loan statistics');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Update loan application
  Future<ApiResponse<LoanModel>> updateLoanApplication({
    required String loanId,
    required LoanApplication updatedApplication,
  }) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '${ApiConstants.loanApplication}/$loanId',
        data: updatedApplication.toJson(),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<LoanModel>.fromJson(
          response.data!,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );

        // Clear loans cache after update
        await _clearLoansCache();

        return apiResponse;
      }

      throw AppException.serverError('Loan application update failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cancel loan application
  Future<ApiResponse<void>> cancelLoanApplication(String loanId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '${ApiConstants.loanApplication}/$loanId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear loans cache after cancellation
        await _clearLoansCache();

        return ApiResponse<void>.fromJson(response.data!, (json) {});
      }

      throw AppException.serverError('Loan cancellation failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get loan offers/products
  Future<ApiResponse<List<Map<String, dynamic>>>> getLoanOffers() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.loans}/offers',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );
      }

      throw AppException.serverError('Failed to fetch loan offers');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cacheLoans(
    String key,
    PaginatedResponse<LoanModel> loans,
  ) async {
    await StorageService.setCachedData(key, {
      'data': loans.toJson((loan) => loan.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<LoanModel>?> _getCachedLoans(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<LoanModel>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheCalculation(String key, EMICalculation calculation) async {
    await StorageService.setCachedData(key, {
      'data': calculation.toJson(),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<EMICalculation?> _getCachedCalculation(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return EMICalculation.fromJson(cached['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearLoansCache() async {
    final keys = await StorageService.getCacheInfo();
    final loanKeys = (keys['keys'] as List)
        .where((key) => key.toString().startsWith(_cacheKeyLoans))
        .toList();

    for (final key in loanKeys) {
      await StorageService.removeCachedData(key.toString());
    }
  }

  /// Clear all loans cache
  Future<void> clearLoansCache() async {
    await _clearLoansCache();
  }

  /// Get loans summary for offline mode
  Future<Map<String, dynamic>?> getLoansSummary() async {
    try {
      final cached = await _getCachedLoans('${_cacheKeyLoans}_1_20_all');
      if (cached?.data != null) {
        final loans = cached!.data;
        return {
          'totalLoans': loans.length,
          'activeLoans': loans.where((loan) => loan.status == 'active').length,
          'totalAmount': loans.fold<double>(
            0,
            (sum, loan) => sum + loan.amount,
          ),
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Utility methods
  bool isLoanActive(LoanModel loan) {
    return loan.status.toLowerCase() == 'active';
  }

  bool isLoanCompleted(LoanModel loan) {
    return loan.status.toLowerCase() == 'completed';
  }

  double calculateRemainingAmount(LoanModel loan) {
    return loan.totalAmount - loan.repaidAmount;
  }

  int calculateRemainingInstallments(LoanModel loan) {
    if (loan.emi <= 0) return 0;
    return (calculateRemainingAmount(loan) / loan.emi).ceil();
  }

  DateTime? getNextPaymentDue(LoanModel loan) {
    return loan.nextPaymentDate;
  }

  bool isPaymentOverdue(LoanModel loan) {
    final nextPayment = loan.nextPaymentDate;
    if (nextPayment == null) return false;
    return DateTime.now().isAfter(nextPayment);
  }
}
