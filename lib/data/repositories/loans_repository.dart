import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/loans/loan_model.dart';
import '../models/loans/loan_application.dart';
import '../models/loans/emi_calculation.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final loansRepositoryProvider = Provider<LoansRepository>((ref) {
  return LoansRepository(ref.read(apiServiceProvider));
});

class LoansRepository {
  final ApiService _apiService;
  static const String _loansCacheKey = 'loans_data';
  static const String _loanApplicationsCacheKey = 'loan_applications_data';

  LoansRepository(this._apiService);

  Future<PaginatedResponse<LoanModel>> getUserLoans({
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
        ApiConstants.loans,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final paginatedResponse = PaginatedResponse<LoanModel>.fromJson(
          response.data!,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache loans data locally
        if (paginatedResponse.success && page == 1) {
          await StorageService.setCachedData(
            _loansCacheKey,
            paginatedResponse.data.map((loan) => loan.toJson()).toList(),
          );
        }

        return paginatedResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(_loansCacheKey);
        if (cachedData != null) {
          final loans = (cachedData as List)
              .map((json) => LoanModel.fromJson(json))
              .toList();

          return PaginatedResponse<LoanModel>(
            success: true,
            data: loans,
            pagination: Pagination(
              currentPage: 1,
              totalPages: 1,
              totalItems: loans.length,
              itemsPerPage: loans.length,
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

  Future<ApiResponse<LoanModel>> getLoanDetails(String loanId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.loans}/$loanId',
      );

      if (response.data != null) {
        return ApiResponse<LoanModel>.fromJson(
          response.data!,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<LoanModel>> applyForLoan(
    LoanApplication application,
  ) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.loanApplication,
        data: application.toJson(),
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<LoanModel>.fromJson(
          response.data!,
          (json) => LoanModel.fromJson(json as Map<String, dynamic>),
        );

        // Refresh loans cache after new application
        if (apiResponse.success) {
          await getUserLoans(forceRefresh: true);
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

  Future<ApiResponse<EMICalculation>> calculateEMI({
    required double loanAmount,
    required double interestRate,
    required int tenure,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.emiCalculator,
        data: {
          'loanAmount': loanAmount,
          'interestRate': interestRate,
          'tenure': tenure,
        },
      );

      if (response.data != null) {
        return ApiResponse<EMICalculation>.fromJson(
          response.data!,
          (json) => EMICalculation.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<RepaymentInstallment>>> getRepaymentSchedule(
    String loanId,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.loans}/$loanId/repayment-schedule',
      );

      if (response.data != null) {
        return ApiResponse<List<RepaymentInstallment>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map(
                (e) => RepaymentInstallment.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> makeRepayment({
    required String loanId,
    required double amount,
    String? paymentMethod,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConstants.loans}/$loanId/repayment',
        data: {
          'amount': amount,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        },
      );

      if (response.data != null) {
        // Refresh loan details after repayment
        await getLoanDetails(loanId);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getLoanTypes() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/loans/types',
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

  Future<ApiResponse<Map<String, dynamic>>> getLoanEligibility() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/loans/eligibility',
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

  Future<ApiResponse<void>> requestLoanClosure(String loanId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiConstants.loans}/$loanId/closure-request',
      );

      if (response.data != null) {
        // Refresh loan details after closure request
        await getLoanDetails(loanId);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getLoanStatement({
    required String loanId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.loans}/$loanId/statement',
        queryParameters: {
          'fromDate': fromDate.toIso8601String(),
          'toDate': toDate.toIso8601String(),
        },
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

  Future<ApiResponse<void>> updateLoanApplication({
    required String applicationId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiConstants.loanApplication}/$applicationId',
        data: updates,
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

  Future<List<LoanModel>?> getCachedLoans() async {
    try {
      final cachedData = await StorageService.getCachedData(_loansCacheKey);
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => LoanModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearLoansCache() async {
    await StorageService.removeCachedData(_loansCacheKey);
    await StorageService.removeCachedData(_loanApplicationsCacheKey);
  }

  Future<Map<String, dynamic>> getLoansSummary() async {
    try {
      final loans = await getCachedLoans();
      if (loans == null) return {};

      final activeLoans = loans.where((loan) => loan.status == 'Active').length;
      final completedLoans = loans
          .where((loan) => loan.status == 'Completed')
          .length;
      final totalAmount = loans.fold<double>(
        0,
        (sum, loan) => sum + loan.amount,
      );
      final totalRepaid = loans.fold<double>(
        0,
        (sum, loan) => sum + loan.repaidAmount,
      );
      final totalRemaining = loans.fold<double>(
        0,
        (sum, loan) => sum + loan.remainingAmount,
      );

      return {
        'totalLoans': loans.length,
        'activeLoans': activeLoans,
        'completedLoans': completedLoans,
        'totalAmount': totalAmount,
        'totalRepaid': totalRepaid,
        'totalRemaining': totalRemaining,
      };
    } catch (e) {
      return {};
    }
  }
}
