import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/wallet/deposit_request.dart';
import '../models/wallet/withdrawal_request.dart';
import '../models/wallet/transaction_model.dart';
import '../models/wallet/wallet_history.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(apiServiceProvider));
});

class WalletRepository {
  final ApiService _apiService;
  static const String _walletHistoryCacheKey = 'wallet_history_data';
  static const String _transactionsCacheKey = 'transactions_data';
  static const String _walletBalanceCacheKey = 'wallet_balance_data';
  static const String _paymentMethodsCacheKey = 'payment_methods_data';

  WalletRepository(this._apiService);

  Future<ApiResponse<TransactionModel>> createDeposit(
    DepositRequest request,
  ) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.walletDeposit,
        data: request.toJson(),
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<TransactionModel>.fromJson(
          response.data!,
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        );

        // Refresh wallet history after deposit
        if (apiResponse.success) {
          await getWalletHistory(forceRefresh: true);
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

  Future<ApiResponse<TransactionModel>> createWithdrawal(
    WithdrawalRequest request,
  ) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConstants.walletWithdraw,
        data: request.toJson(),
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<TransactionModel>.fromJson(
          response.data!,
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        );

        // Refresh wallet history after withdrawal
        if (apiResponse.success) {
          await getWalletHistory(forceRefresh: true);
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

  Future<ApiResponse<WalletHistory>> getWalletHistory({
    int page = 1,
    int limit = 20,
    String type = 'all',
    String status = 'all',
    String gateway = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool includeMetadata = true,
    bool forceRefresh = false,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'type': type,
        'status': status,
        'gateway': gateway,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        'includeMetadata': includeMetadata.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.walletHistory,
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<WalletHistory>.fromJson(
          response.data!,
          (json) => WalletHistory.fromJson(json as Map<String, dynamic>),
        );

        // Cache wallet history data locally (first page only)
        if (apiResponse.success && apiResponse.data != null && page == 1) {
          await StorageService.setCachedData(
            _walletHistoryCacheKey,
            apiResponse.data!.toJson(),
          );

          // Cache individual transactions
          await StorageService.setCachedData(
            _transactionsCacheKey,
            apiResponse.data!.transactions.map((t) => t.toJson()).toList(),
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails and it's the first page
      if (page == 1) {
        final cachedData = await StorageService.getCachedData(
          _walletHistoryCacheKey,
        );
        if (cachedData != null) {
          return ApiResponse<WalletHistory>(
            success: true,
            data: WalletHistory.fromJson(cachedData),
            timestamp: DateTime.now(),
            message: 'Loaded from cache',
          );
        }
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<TransactionModel>> getTransactionDetails(
    String transactionId,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/wallet/transactions/$transactionId',
      );

      if (response.data != null) {
        return ApiResponse<TransactionModel>.fromJson(
          response.data!,
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> cancelTransaction(String transactionId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/wallet/transactions/$transactionId/cancel',
      );

      if (response.data != null) {
        // Refresh wallet history after cancellation
        await getWalletHistory(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getWalletBalance() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/wallet/balance',
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache wallet balance data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _walletBalanceCacheKey,
            apiResponse.data!,
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(
        _walletBalanceCacheKey,
      );
      if (cachedData != null) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          data: cachedData as Map<String, dynamic>,
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentMethods({
    String type = 'all',
    bool activeOnly = true,
  }) async {
    try {
      final queryParams = {'type': type, 'active': activeOnly.toString()};

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/wallet/payment-methods',
        queryParameters: queryParams,
      );

      if (response.data != null) {
        final apiResponse = ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) =>
              (json as List).map((e) => e as Map<String, dynamic>).toList(),
        );

        // Cache payment methods data locally
        if (apiResponse.success && apiResponse.data != null) {
          await StorageService.setCachedData(
            _paymentMethodsCacheKey,
            apiResponse.data!,
          );
        }

        return apiResponse;
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      // Try to return cached data if network fails
      final cachedData = await StorageService.getCachedData(
        _paymentMethodsCacheKey,
      );
      if (cachedData != null) {
        final paymentMethods = (cachedData as List)
            .cast<Map<String, dynamic>>();
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          data: paymentMethods,
          timestamp: DateTime.now(),
          message: 'Loaded from cache',
        );
      }
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getDepositLimits({
    String gateway = 'all',
    String currency = 'USD',
  }) async {
    try {
      final queryParams = {'gateway': gateway, 'currency': currency};

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/wallet/deposit-limits',
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

  Future<ApiResponse<Map<String, dynamic>>> getWithdrawalLimits({
    String method = 'all',
    String currency = 'USD',
  }) async {
    try {
      final queryParams = {'method': method, 'currency': currency};

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/wallet/withdrawal-limits',
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

  Future<ApiResponse<Map<String, dynamic>>> getFeeStructure({
    String type = 'all',
    String currency = 'USD',
  }) async {
    try {
      final queryParams = {'type': type, 'currency': currency};

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/wallet/fee-structure',
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

  Future<ApiResponse<Map<String, dynamic>>> calculateFees({
    required String type,
    required double amount,
    required String currency,
    String? gateway,
    String? method,
    bool urgentProcessing = false,
  }) async {
    try {
      final data = {
        'type': type,
        'amount': amount,
        'currency': currency,
        'urgentProcessing': urgentProcessing,
      };

      if (gateway != null) data['gateway'] = gateway;
      if (method != null) data['method'] = method;

      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/wallet/calculate-fees',
        data: data,
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

  Future<ApiResponse<Map<String, dynamic>>> getExchangeRates({
    String baseCurrency = 'USD',
    List<String>? targetCurrencies,
  }) async {
    try {
      final queryParams = {
        'baseCurrency': baseCurrency,
        if (targetCurrencies != null)
          'targetCurrencies': targetCurrencies.join(','),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/wallet/exchange-rates',
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

  Future<ApiResponse<List<Map<String, dynamic>>>>
  getTransactionCategories() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/wallet/transaction-categories',
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

  Future<ApiResponse<Map<String, dynamic>>> getWalletStatistics({
    String period = 'monthly',
    bool includeBreakdown = true,
  }) async {
    try {
      final queryParams = {
        'period': period,
        'includeBreakdown': includeBreakdown.toString(),
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/wallet/statistics',
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

  Future<ApiResponse<void>> addPaymentMethod({
    required String type,
    required Map<String, dynamic> details,
    bool setAsDefault = false,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/wallet/payment-methods',
        data: {'type': type, 'details': details, 'setAsDefault': setAsDefault},
      );

      if (response.data != null) {
        // Refresh payment methods after adding new one
        await getPaymentMethods(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> removePaymentMethod(String paymentMethodId) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '/api/users/wallet/payment-methods/$paymentMethodId',
      );

      if (response.data != null) {
        // Refresh payment methods after removal
        await getPaymentMethods(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<void>> setDefaultPaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/wallet/payment-methods/$paymentMethodId/set-default',
      );

      if (response.data != null) {
        // Refresh payment methods after setting default
        await getPaymentMethods(forceRefresh: true);

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw const AppException.unknown('Empty response');
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException.unknown(e.toString());
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getTransactionReceipts(
    String transactionId,
  ) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/users/wallet/transactions/$transactionId/receipts',
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

  Future<ApiResponse<void>> requestTransactionReceipt({
    required String transactionId,
    required String email,
    String? format,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/wallet/transactions/$transactionId/request-receipt',
        data: {'email': email, if (format != null) 'format': format},
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

  Future<ApiResponse<Map<String, dynamic>>> generateWalletStatement({
    required DateTime fromDate,
    required DateTime toDate,
    String? format,
    List<String>? transactionTypes,
  }) async {
    try {
      final data = {
        'fromDate': fromDate.toIso8601String(),
        'toDate': toDate.toIso8601String(),
      };

      if (format != null) data['format'] = format;
      if (transactionTypes != null) data['transactionTypes'] = transactionTypes;

      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/users/wallet/generate-statement',
        data: data,
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
  Future<WalletHistory?> getCachedWalletHistory() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _walletHistoryCacheKey,
      );
      if (cachedData != null) {
        return WalletHistory.fromJson(cachedData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<TransactionModel>?> getCachedTransactions() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _transactionsCacheKey,
      );
      if (cachedData != null) {
        return (cachedData as List)
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCachedWalletBalance() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _walletBalanceCacheKey,
      );
      return cachedData as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCachedPaymentMethods() async {
    try {
      final cachedData = await StorageService.getCachedData(
        _paymentMethodsCacheKey,
      );
      if (cachedData != null) {
        return (cachedData as List).cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearWalletCache() async {
    await StorageService.removeCachedData(_walletHistoryCacheKey);
    await StorageService.removeCachedData(_transactionsCacheKey);
    await StorageService.removeCachedData(_walletBalanceCacheKey);
    await StorageService.removeCachedData(_paymentMethodsCacheKey);
  }

  Future<Map<String, dynamic>> getWalletSummary() async {
    try {
      final balance = await getCachedWalletBalance();
      final transactions = await getCachedTransactions();

      if (balance == null) return {};

      final totalDeposits =
          transactions
              ?.where((t) => t.type == 'deposit' && t.status == 'Approved')
              .fold<double>(0, (sum, t) => sum + t.amount) ??
          0.0;

      final totalWithdrawals =
          transactions
              ?.where((t) => t.type == 'withdrawal' && t.status == 'Approved')
              .fold<double>(0, (sum, t) => sum + t.amount) ??
          0.0;

      final pendingTransactions =
          transactions?.where((t) => t.status == 'Pending').length ?? 0;

      return {
        'currentBalance': balance['balance'] ?? 0.0,
        'availableBalance': balance['availableBalance'] ?? 0.0,
        'frozenBalance': balance['frozenBalance'] ?? 0.0,
        'totalDeposits': totalDeposits,
        'totalWithdrawals': totalWithdrawals,
        'pendingTransactions': pendingTransactions,
        'totalTransactions': transactions?.length ?? 0,
        'netFlow': totalDeposits - totalWithdrawals,
        ...balance,
      };
    } catch (e) {
      return {};
    }
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    try {
      final transactions = await getCachedTransactions();
      if (transactions == null) return [];

      return transactions.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TransactionModel>> getPendingTransactions() async {
    try {
      final transactions = await getCachedTransactions();
      if (transactions == null) return [];

      return transactions.where((t) => t.status == 'Pending').toList();
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalEarnings() async {
    try {
      final transactions = await getCachedTransactions();
      if (transactions == null) return 0.0;

      return transactions
          .where(
            (t) =>
                [
                  'bonus',
                  'profit',
                  'referral_bonus',
                  'task_reward',
                ].contains(t.type) &&
                t.status == 'Approved',
          )
          .fold<double>(0, (sum, t) => sum + t.amount);
    } catch (e) {
      return 0.0;
    }
  }
}
