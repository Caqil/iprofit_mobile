import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../models/wallet/transaction_model.dart';
import '../models/wallet/wallet_history.dart';
import '../models/wallet/deposit_request.dart';
import '../models/wallet/withdrawal_request.dart';
import '../models/common/api_response.dart';
import '../models/common/pagination.dart';
import '../services/storage_service.dart';
import '../services/device_service.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(apiClientProvider));
});

class WalletRepository {
  final ApiClient _apiClient;
  static const String _cacheKeyBalance = 'wallet_balance';
  static const String _cacheKeyHistory = 'wallet_history';
  static const String _cacheKeyPaymentMethods = 'payment_methods';
  static const String _cacheKeyLimits = 'wallet_limits';
  static const String _cacheKeyGateways = 'payment_gateways';
  static const String _cacheKeyWalletSummary = 'wallet_summary';
  static const Duration _cacheExpiry = Duration(
    minutes: 5,
  ); // Shorter for financial data
  static const Duration _balanceCacheExpiry = Duration(
    minutes: 2,
  ); // Even shorter for balance

  WalletRepository(this._apiClient);

  /// Get wallet balance
  Future<ApiResponse<Map<String, dynamic>>> getWalletBalance({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedBalance();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Wallet balance loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.walletBalance,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheBalance(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch wallet balance');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get wallet transaction history with pagination
  Future<PaginatedResponse<TransactionModel>> getWalletHistory({
    int page = 1,
    int limit = 20,
    String type = 'all',
    String status = 'all',
    String gateway = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    DateTime? startDate,
    DateTime? endDate,
    bool includeMetadata = true,
    bool forceRefresh = false,
  }) async {
    try {
      final cacheKey = '${_cacheKeyHistory}_${page}_${limit}_${type}_$status';

      // Check cache first (only for first page)
      if (!forceRefresh && page == 1) {
        final cached = await _getCachedHistory(cacheKey);
        if (cached != null) {
          return cached;
        }
      }

      final queryParams = <String, dynamic>{
        ApiConstants.pageParam: page,
        ApiConstants.limitParam: limit,
        ApiConstants.sortByParam: sortBy,
        ApiConstants.sortOrderParam: sortOrder,
        'includeMetadata': includeMetadata,
      };

      if (type != 'all') {
        queryParams['type'] = type;
      }

      if (status != 'all') {
        queryParams[ApiConstants.statusParam] = status;
      }

      if (gateway != 'all') {
        queryParams['gateway'] = gateway;
      }

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          ApiConstants.walletHistory,
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final paginatedResponse = PaginatedResponse<TransactionModel>.fromJson(
          response.data!,
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        );

        // Cache first page
        if (page == 1 && paginatedResponse.success) {
          await _cacheHistory(cacheKey, paginatedResponse);
        }

        return paginatedResponse;
      }

      throw AppException.serverError('Failed to fetch wallet history');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Create a deposit
  Future<ApiResponse<Map<String, dynamic>>> createDeposit({
    required double amount,
    required String currency,
    required String gateway,
    required String depositMethod,
    Map<String, dynamic>? gatewayData,
    bool acceptTerms = true,
    bool confirmAmount = true,
  }) async {
    try {
      final deviceId = await DeviceService.getDeviceId();

      final data = {
        'amount': amount,
        'currency': currency,
        'gateway': gateway,
        'depositMethod': depositMethod,
        'deviceId': deviceId,
        'acceptTerms': acceptTerms,
        'confirmAmount': confirmAmount,
        if (gatewayData != null) 'gatewayData': gatewayData,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.walletDeposit,
        data: data,
      );

      if (response.statusCode == ApiConstants.statusCreated ||
          response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Clear balance and history cache after deposit
        await _clearFinancialCache();

        return apiResponse;
      }

      throw AppException.serverError('Failed to create deposit');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Create a withdrawal
  Future<ApiResponse<Map<String, dynamic>>> createWithdrawal({
    required double amount,
    required String currency,
    required String withdrawalMethod,
    required Map<String, dynamic> accountDetails,
    bool urgentWithdrawal = false,
    String? twoFactorToken,
  }) async {
    try {
      final deviceId = await DeviceService.getDeviceId();

      final data = {
        'amount': amount,
        'currency': currency,
        'withdrawalMethod': withdrawalMethod,
        'accountDetails': accountDetails,
        'urgentWithdrawal': urgentWithdrawal,
        'deviceId': deviceId,
        if (twoFactorToken != null) 'twoFactorToken': twoFactorToken,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.walletWithdraw,
        data: data,
      );

      if (response.statusCode == ApiConstants.statusCreated ||
          response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Clear balance and history cache after withdrawal
        await _clearFinancialCache();

        return apiResponse;
      }

      throw AppException.serverError('Failed to create withdrawal');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Transfer funds to another user
  Future<ApiResponse<Map<String, dynamic>>> transferFunds({
    required String recipientId,
    required double amount,
    required String currency,
    String? note,
    String? twoFactorToken,
  }) async {
    try {
      final data = {
        'recipientId': recipientId,
        'amount': amount,
        'currency': currency,
        if (note != null) 'note': note,
        if (twoFactorToken != null) 'twoFactorToken': twoFactorToken,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.walletTransfer,
        data: data,
      );

      if (response.statusCode == ApiConstants.statusCreated ||
          response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Clear balance and history cache after transfer
        await _clearFinancialCache();

        return apiResponse;
      }

      throw AppException.serverError('Failed to transfer funds');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get wallet limits and configurations
  Future<ApiResponse<Map<String, dynamic>>> getWalletLimits({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedLimits();
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Wallet limits loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.walletLimits,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheLimits(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch wallet limits');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get available payment methods
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentMethods({
    String type = 'all', // 'deposit', 'withdrawal', 'all'
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedPaymentMethods(type);
        if (cached != null) {
          return ApiResponse<List<Map<String, dynamic>>>(
            success: true,
            data: cached,
            message: 'Payment methods loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final queryParams = <String, dynamic>{if (type != 'all') 'type': type};

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.walletPrefix}/payment-methods',
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cachePaymentMethods(type, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch payment methods');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get available payment gateways
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentGateways({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedGateways();
        if (cached != null) {
          return ApiResponse<List<Map<String, dynamic>>>(
            success: true,
            data: cached,
            message: 'Payment gateways loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.walletPrefix}/gateways',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<List<Map<String, dynamic>>>.fromJson(
          response.data!,
          (json) => (json as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheGateways(apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch payment gateways');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get transaction details by ID
  Future<ApiResponse<TransactionModel>> getTransactionDetails(
    String transactionId,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.walletHistory}/$transactionId',
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<TransactionModel>.fromJson(
          response.data!,
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        );
      }

      throw AppException.serverError('Failed to fetch transaction details');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cancel a pending transaction
  Future<ApiResponse<void>> cancelTransaction(String transactionId) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.walletHistory}/$transactionId/cancel',
        data: {},
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear cache after cancellation
        await _clearFinancialCache();

        return ApiResponse<void>.fromJson(response.data!, (json) => null);
      }

      throw AppException.serverError('Failed to cancel transaction');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get wallet statistics
  Future<ApiResponse<Map<String, dynamic>>> getWalletStatistics({
    String period = 'monthly', // 'daily', 'weekly', 'monthly', 'yearly'
  }) async {
    try {
      final queryParams = <String, dynamic>{'period': period};

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.walletPrefix}/statistics',
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch wallet statistics');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getWalletSummary({
    bool forceRefresh = false,
    String period = 'monthly', // 'daily', 'weekly', 'monthly', 'yearly'
  }) async {
    try {
      final cacheKey = '${_cacheKeyWalletSummary}_$period';

      // Check cache first
      if (!forceRefresh) {
        final cached = await _getCachedWalletSummary(cacheKey);
        if (cached != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            data: cached,
            message: 'Wallet summary loaded from cache',
            timestamp: DateTime.now(),
          );
        }
      }

      final queryParams = <String, dynamic>{'period': period};

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.walletPrefix}/summary',
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );

        // Cache the result
        if (apiResponse.success && apiResponse.data != null) {
          await _cacheWalletSummary(cacheKey, apiResponse.data!);
        }

        return apiResponse;
      }

      throw AppException.serverError('Failed to fetch wallet summary');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  Future<void> _cacheWalletSummary(
    String key,
    Map<String, dynamic> summary,
  ) async {
    await StorageService.setCachedData(key, {
      'data': summary,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedWalletSummary(String key) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate deposit fees
  Future<ApiResponse<Map<String, dynamic>>> calculateDepositFees({
    required double amount,
    required String currency,
    required String gateway,
    required String method,
    bool urgentProcessing = false,
  }) async {
    try {
      final data = {
        'amount': amount,
        'currency': currency,
        'gateway': gateway,
        'method': method,
        'urgentProcessing': urgentProcessing,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.walletPrefix}/calculate-deposit-fees',
        data: data,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to calculate deposit fees');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Calculate withdrawal fees
  Future<ApiResponse<Map<String, dynamic>>> calculateWithdrawalFees({
    required double amount,
    required String currency,
    required String method,
    bool urgentProcessing = false,
  }) async {
    try {
      final data = {
        'amount': amount,
        'currency': currency,
        'method': method,
        'urgentProcessing': urgentProcessing,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.walletPrefix}/calculate-withdrawal-fees',
        data: data,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to calculate withdrawal fees');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Verify transaction with OTP or 2FA
  Future<ApiResponse<Map<String, dynamic>>> verifyTransaction({
    required String transactionId,
    required String verificationCode,
    String verificationMethod = 'otp', // 'otp', '2fa'
  }) async {
    try {
      final data = {
        'verificationCode': verificationCode,
        'verificationMethod': verificationMethod,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiConstants.walletHistory}/$transactionId/verify',
        data: data,
      );

      if (response.statusCode == ApiConstants.statusOk) {
        // Clear cache after verification
        await _clearFinancialCache();

        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to verify transaction');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Get wallet exchange rates
  Future<ApiResponse<Map<String, dynamic>>> getExchangeRates({
    String baseCurrency = 'USD',
  }) async {
    try {
      final queryParams = <String, dynamic>{'base': baseCurrency};

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.getEndpointWithQuery(
          '${ApiConstants.walletPrefix}/exchange-rates',
          queryParams,
        ),
      );

      if (response.statusCode == ApiConstants.statusOk) {
        return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json as Map<String, dynamic>,
        );
      }

      throw AppException.serverError('Failed to fetch exchange rates');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.fromException(e as Exception);
    }
  }

  /// Cache management methods
  Future<void> _cacheBalance(Map<String, dynamic> balance) async {
    await StorageService.setCachedData(_cacheKeyBalance, {
      'data': balance,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedBalance() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyBalance,
        maxAge: _balanceCacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheHistory(
    String key,
    PaginatedResponse<TransactionModel> history,
  ) async {
    await StorageService.setCachedData(key, {
      'data': history.toJson((transaction) => transaction.toJson()),
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<PaginatedResponse<TransactionModel>?> _getCachedHistory(
    String key,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        key,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<TransactionModel>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cachePaymentMethods(
    String type,
    List<Map<String, dynamic>> methods,
  ) async {
    await StorageService.setCachedData('${_cacheKeyPaymentMethods}_$type', {
      'data': methods,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>?> _getCachedPaymentMethods(
    String type,
  ) async {
    try {
      final cached = await StorageService.getCachedData(
        '${_cacheKeyPaymentMethods}_$type',
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return (cached['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheLimits(Map<String, dynamic> limits) async {
    await StorageService.setCachedData(_cacheKeyLimits, {
      'data': limits,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> _getCachedLimits() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyLimits,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCachedWalletBalance() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyBalance,
        maxAge: _balanceCacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached wallet history without making API call
  Future<PaginatedResponse<TransactionModel>?> getCachedWalletHistory({
    int page = 1,
    int limit = 20,
    String type = 'all',
    String status = 'all',
  }) async {
    try {
      final cacheKey = '${_cacheKeyHistory}_${page}_${limit}_${type}_$status';

      final cached = await StorageService.getCachedData(
        cacheKey,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return PaginatedResponse<TransactionModel>.fromJson(
          cached['data'] as Map<String, dynamic>,
          (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached wallet summary without making API call
  Future<Map<String, dynamic>?> getCachedWalletSummary({
    String period = 'monthly',
  }) async {
    try {
      final cacheKey = '${_cacheKeyWalletSummary}_$period';

      final cached = await StorageService.getCachedData(
        cacheKey,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached payment methods without making API call
  Future<List<Map<String, dynamic>>?> getCachedPaymentMethods({
    String type = 'all',
  }) async {
    try {
      final cached = await StorageService.getCachedData(
        '${_cacheKeyPaymentMethods}_$type',
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return (cached['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get cached wallet limits without making API call
  Future<Map<String, dynamic>?> getCachedWalletLimits() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyLimits,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return cached['data'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if wallet data is cached and valid
  Future<bool> isWalletDataCached() async {
    try {
      final balance = await getCachedWalletBalance();
      final history = await getCachedWalletHistory();
      return balance != null && history != null;
    } catch (e) {
      return false;
    }
  }

  /// Get current balance amount from cache (quick access)
  Future<double?> getCachedBalanceAmount() async {
    try {
      final balanceData = await getCachedWalletBalance();
      if (balanceData != null && balanceData['balance'] != null) {
        return (balanceData['balance'] as num).toDouble();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheGateways(List<Map<String, dynamic>> gateways) async {
    await StorageService.setCachedData(_cacheKeyGateways, {
      'data': gateways,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>?> _getCachedGateways() async {
    try {
      final cached = await StorageService.getCachedData(
        _cacheKeyGateways,
        maxAge: _cacheExpiry,
      );

      if (cached != null && cached['data'] != null) {
        return (cached['data'] as List)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear financial cache (balance and history)
  Future<void> _clearFinancialCache() async {
    await Future.wait([
      StorageService.removeCachedData(_cacheKeyBalance),
      StorageService.removeCachedData(_cacheKeyHistory),
    ]);
  }

  Future<void> clearWalletCache() async {
    try {
      await StorageService.removeCachedData(_cacheKeyBalance);
      await StorageService.removeCachedData(_cacheKeyLimits);
      await StorageService.removeCachedData(_cacheKeyGateways);

      // Clear pattern-based cache
      final cacheInfo = await StorageService.getCacheInfo();
      final walletKeys = (cacheInfo['keys'] as List).where((key) {
        final keyStr = key.toString();
        return keyStr.startsWith(_cacheKeyHistory) ||
            keyStr.startsWith(_cacheKeyPaymentMethods) ||
            keyStr.startsWith(_cacheKeyWalletSummary);
      }).toList();

      for (final key in walletKeys) {
        await StorageService.removeCachedData(key.toString());
      }
    } catch (e) {
      // Handle cache clearing error silently
    }
  }

  /// Clear all wallet-related cache
  Future<void> clearAllCache() async {
    await Future.wait([
      StorageService.removeCachedData(_cacheKeyBalance),
      StorageService.removeCachedData(_cacheKeyHistory),
      StorageService.removeCachedData(_cacheKeyPaymentMethods),
      StorageService.removeCachedData(_cacheKeyLimits),
      StorageService.removeCachedData(_cacheKeyGateways),
    ]);
  }
}
