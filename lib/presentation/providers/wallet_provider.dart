// lib/presentation/providers/wallet_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/errors/app_exception.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/models/wallet/transaction_model.dart';
import '../../data/models/common/pagination.dart';

part 'wallet_provider.g.dart';

// ============================================================================
// WALLET STATE MODEL
// ============================================================================

/// Wallet provider state model
class WalletState {
  final Map<String, dynamic>? balance;
  final List<TransactionModel> transactions;
  final Pagination? transactionsPagination;
  final List<Map<String, dynamic>> paymentMethods;
  final Map<String, dynamic>? limits;
  final List<Map<String, dynamic>> gateways;
  final Map<String, dynamic>? summary;
  final bool isLoading;
  final bool isLoadingTransactions;
  final bool isProcessingTransaction;
  final String? error;
  final String currentTransactionFilter;
  final String currentTransactionType;
  final String currentGateway;
  final DateTime? transactionDateFrom;
  final DateTime? transactionDateTo;
  final String? lastUpdated;

  const WalletState({
    this.balance,
    this.transactions = const [],
    this.transactionsPagination,
    this.paymentMethods = const [],
    this.limits,
    this.gateways = const [],
    this.summary,
    this.isLoading = false,
    this.isLoadingTransactions = false,
    this.isProcessingTransaction = false,
    this.error,
    this.currentTransactionFilter = 'all',
    this.currentTransactionType = 'all',
    this.currentGateway = 'all',
    this.transactionDateFrom,
    this.transactionDateTo,
    this.lastUpdated,
  });

  WalletState copyWith({
    Map<String, dynamic>? balance,
    List<TransactionModel>? transactions,
    Pagination? transactionsPagination,
    List<Map<String, dynamic>>? paymentMethods,
    Map<String, dynamic>? limits,
    List<Map<String, dynamic>>? gateways,
    Map<String, dynamic>? summary,
    bool? isLoading,
    bool? isLoadingTransactions,
    bool? isProcessingTransaction,
    String? error,
    String? currentTransactionFilter,
    String? currentTransactionType,
    String? currentGateway,
    DateTime? transactionDateFrom,
    DateTime? transactionDateTo,
    String? lastUpdated,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      transactionsPagination:
          transactionsPagination ?? this.transactionsPagination,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      limits: limits ?? this.limits,
      gateways: gateways ?? this.gateways,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isLoadingTransactions:
          isLoadingTransactions ?? this.isLoadingTransactions,
      isProcessingTransaction:
          isProcessingTransaction ?? this.isProcessingTransaction,
      error: error,
      currentTransactionFilter:
          currentTransactionFilter ?? this.currentTransactionFilter,
      currentTransactionType:
          currentTransactionType ?? this.currentTransactionType,
      currentGateway: currentGateway ?? this.currentGateway,
      transactionDateFrom: transactionDateFrom ?? this.transactionDateFrom,
      transactionDateTo: transactionDateTo ?? this.transactionDateTo,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Convenience getters
  bool get hasError => error != null;
  bool get hasBalance => balance != null;
  bool get hasTransactions => transactions.isNotEmpty;
  bool get hasMoreTransactions => transactionsPagination?.hasNextPage ?? false;
  bool get hasPaymentMethods => paymentMethods.isNotEmpty;
  bool get hasLimits => limits != null;
  bool get hasGateways => gateways.isNotEmpty;
  bool get hasSummary => summary != null;

  // Balance information
  double get totalBalance => balance?['total']?.toDouble() ?? 0.0;
  double get availableBalance => balance?['available']?.toDouble() ?? 0.0;
  double get lockedBalance => balance?['locked']?.toDouble() ?? 0.0;
  double get pendingBalance => balance?['pending']?.toDouble() ?? 0.0;
  String get balanceCurrency => balance?['currency'] ?? 'USD';

  // Transaction categories
  List<TransactionModel> get deposits =>
      transactions.where((t) => t.type == 'deposit').toList();
  List<TransactionModel> get withdrawals =>
      transactions.where((t) => t.type == 'withdrawal').toList();
  List<TransactionModel> get transfers =>
      transactions.where((t) => t.type == 'transfer').toList();
  List<TransactionModel> get completedTransactions =>
      transactions.where((t) => t.status == 'completed').toList();
  List<TransactionModel> get pendingTransactions =>
      transactions.where((t) => t.status == 'pending').toList();
  List<TransactionModel> get failedTransactions =>
      transactions.where((t) => t.status == 'failed').toList();

  // Limits and restrictions
  double get dailyDepositLimit => limits?['daily_deposit']?.toDouble() ?? 0.0;
  double get dailyWithdrawalLimit =>
      limits?['daily_withdrawal']?.toDouble() ?? 0.0;
  double get monthlyDepositLimit =>
      limits?['monthly_deposit']?.toDouble() ?? 0.0;
  double get monthlyWithdrawalLimit =>
      limits?['monthly_withdrawal']?.toDouble() ?? 0.0;
  double get minimumDeposit => limits?['min_deposit']?.toDouble() ?? 0.0;
  double get minimumWithdrawal => limits?['min_withdrawal']?.toDouble() ?? 0.0;
  double get maximumDeposit => limits?['max_deposit']?.toDouble() ?? 0.0;
  double get maximumWithdrawal => limits?['max_withdrawal']?.toDouble() ?? 0.0;

  // Usage tracking
  double get todayDepositUsed =>
      limits?['today_deposit_used']?.toDouble() ?? 0.0;
  double get todayWithdrawalUsed =>
      limits?['today_withdrawal_used']?.toDouble() ?? 0.0;
  double get monthDepositUsed =>
      limits?['month_deposit_used']?.toDouble() ?? 0.0;
  double get monthWithdrawalUsed =>
      limits?['month_withdrawal_used']?.toDouble() ?? 0.0;

  // Available limits
  double get remainingDailyDeposit => dailyDepositLimit - todayDepositUsed;
  double get remainingDailyWithdrawal =>
      dailyWithdrawalLimit - todayWithdrawalUsed;
  double get remainingMonthlyDeposit => monthlyDepositLimit - monthDepositUsed;
  double get remainingMonthlyWithdrawal =>
      monthlyWithdrawalLimit - monthWithdrawalUsed;

  // Summary statistics
  double get totalDeposited => summary?['total_deposited']?.toDouble() ?? 0.0;
  double get totalWithdrawn => summary?['total_withdrawn']?.toDouble() ?? 0.0;
  int get totalTransactionsCount =>
      summary?['total_transactions']?.toInt() ?? 0;
  double get averageTransactionAmount =>
      summary?['average_amount']?.toDouble() ?? 0.0;
}

// ============================================================================
// WALLET PROVIDER
// ============================================================================

@riverpod
class Wallet extends _$Wallet {
  Timer? _refreshTimer;

  @override
  WalletState build() {
    // Initialize wallet data on provider creation
    _initializeWallet();

    // Set up auto-refresh for balance updates
    _setupAutoRefresh();

    // Clean up when provider is disposed
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    return const WalletState();
  }

  // ===== INITIALIZATION =====

  /// Initialize wallet data
  Future<void> _initializeWallet() async {
    await Future.wait([
      loadBalance(),
      loadTransactions(),
      loadPaymentMethods(),
      loadLimits(),
      loadGateways(),
    ]);
  }

  /// Setup auto-refresh for wallet balance
  void _setupAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      if (mounted) {
        loadBalance(forceRefresh: true); // Silently update balance
      }
    });
  }

  // ===== BALANCE MANAGEMENT =====

  /// Load wallet balance
  Future<void> loadBalance({bool forceRefresh = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.getWalletBalance(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          balance: response.data!,
          isLoading: false,
          lastUpdated: DateTime.now().toIso8601String(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load wallet balance',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e));
    }
  }

  /// Refresh wallet balance
  Future<void> refreshBalance() async {
    await loadBalance(forceRefresh: true);
  }

  // ===== TRANSACTION MANAGEMENT =====

  /// Load wallet transactions with filtering and pagination
  Future<void> loadTransactions({
    int page = 1,
    String type = 'all',
    String status = 'all',
    String gateway = 'all',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    DateTime? startDate,
    DateTime? endDate,
    bool forceRefresh = false,
  }) async {
    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          isLoadingTransactions: true,
          error: null,
          currentTransactionType: type,
          currentTransactionFilter: status,
          currentGateway: gateway,
          transactionDateFrom: startDate,
          transactionDateTo: endDate,
        );
      } else {
        state = state.copyWith(isLoadingTransactions: true, error: null);
      }

      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.getWalletHistory(
        page: page,
        type: type,
        status: status,
        gateway: gateway,
        sortBy: sortBy,
        sortOrder: sortOrder,
        startDate: startDate,
        endDate: endDate,
        forceRefresh: forceRefresh,
      );

      if (response.success) {
        List<TransactionModel> updatedTransactions;

        if (page == 1) {
          updatedTransactions = response.data;
        } else {
          updatedTransactions = [...state.transactions, ...response.data];
        }

        state = state.copyWith(
          transactions: updatedTransactions,
          transactionsPagination: response.pagination,
          isLoadingTransactions: false,
        );
      } else {
        state = state.copyWith(
          isLoadingTransactions: false,
          error: response.message ?? 'Failed to load transactions',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingTransactions: false,
        error: _getErrorMessage(e),
      );
    }
  }

  /// Load more transactions (pagination)
  Future<void> loadMoreTransactions() async {
    if (state.isLoadingTransactions || !state.hasMoreTransactions) return;

    final nextPage = (state.transactionsPagination?.currentPage ?? 0) + 1;
    await loadTransactions(
      page: nextPage,
      type: state.currentTransactionType,
      status: state.currentTransactionFilter,
      gateway: state.currentGateway,
      startDate: state.transactionDateFrom,
      endDate: state.transactionDateTo,
    );
  }

  /// Filter transactions by type
  Future<void> filterTransactionsByType(String type) async {
    if (state.currentTransactionType == type) return;

    await loadTransactions(
      type: type,
      status: state.currentTransactionFilter,
      gateway: state.currentGateway,
      startDate: state.transactionDateFrom,
      endDate: state.transactionDateTo,
    );
  }

  /// Filter transactions by status
  Future<void> filterTransactionsByStatus(String status) async {
    if (state.currentTransactionFilter == status) return;

    await loadTransactions(
      type: state.currentTransactionType,
      status: status,
      gateway: state.currentGateway,
      startDate: state.transactionDateFrom,
      endDate: state.transactionDateTo,
    );
  }

  /// Filter transactions by gateway
  Future<void> filterTransactionsByGateway(String gateway) async {
    if (state.currentGateway == gateway) return;

    await loadTransactions(
      type: state.currentTransactionType,
      status: state.currentTransactionFilter,
      gateway: gateway,
      startDate: state.transactionDateFrom,
      endDate: state.transactionDateTo,
    );
  }

  /// Filter transactions by date range
  Future<void> filterTransactionsByDateRange(
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    await loadTransactions(
      type: state.currentTransactionType,
      status: state.currentTransactionFilter,
      gateway: state.currentGateway,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Refresh transactions list
  Future<void> refreshTransactions() async {
    await loadTransactions(
      type: state.currentTransactionType,
      status: state.currentTransactionFilter,
      gateway: state.currentGateway,
      startDate: state.transactionDateFrom,
      endDate: state.transactionDateTo,
      forceRefresh: true,
    );
  }

  // ===== DEPOSIT OPERATIONS =====

  /// Make a deposit
  Future<bool> makeDeposit({
    required double amount,
    required String gateway,
    required String paymentMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      state = state.copyWith(isProcessingTransaction: true, error: null);

      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.deposit(
        amount: amount,
        gateway: gateway,
        paymentMethod: paymentMethod,
        additionalData: additionalData,
      );

      if (response.success) {
        state = state.copyWith(isProcessingTransaction: false);

        // Refresh balance and transactions
        await Future.wait([
          refreshBalance(),
          refreshTransactions(),
          loadLimits(forceRefresh: true), // Update usage limits
        ]);

        return true;
      } else {
        state = state.copyWith(
          isProcessingTransaction: false,
          error: response.message ?? 'Failed to process deposit',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isProcessingTransaction: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  // ===== WITHDRAWAL OPERATIONS =====

  /// Make a withdrawal
  Future<bool> makeWithdrawal({
    required double amount,
    required String gateway,
    required String paymentMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      state = state.copyWith(isProcessingTransaction: true, error: null);

      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.withdraw(
        amount: amount,
        gateway: gateway,
        paymentMethod: paymentMethod,
        additionalData: additionalData,
      );

      if (response.success) {
        state = state.copyWith(isProcessingTransaction: false);

        // Refresh balance and transactions
        await Future.wait([
          refreshBalance(),
          refreshTransactions(),
          loadLimits(forceRefresh: true), // Update usage limits
        ]);

        return true;
      } else {
        state = state.copyWith(
          isProcessingTransaction: false,
          error: response.message ?? 'Failed to process withdrawal',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isProcessingTransaction: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  // ===== TRANSFER OPERATIONS =====

  /// Transfer funds to another user
  Future<bool> transferFunds({
    required double amount,
    required String recipientId,
    String? note,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      state = state.copyWith(isProcessingTransaction: true, error: null);

      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.transfer(
        amount: amount,
        recipientId: recipientId,
        note: note,
        additionalData: additionalData,
      );

      if (response.success) {
        state = state.copyWith(isProcessingTransaction: false);

        // Refresh balance and transactions
        await Future.wait([refreshBalance(), refreshTransactions()]);

        return true;
      } else {
        state = state.copyWith(
          isProcessingTransaction: false,
          error: response.message ?? 'Failed to transfer funds',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isProcessingTransaction: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  // ===== PAYMENT METHODS =====

  /// Load payment methods
  Future<void> loadPaymentMethods({bool forceRefresh = false}) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.getPaymentMethods(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(paymentMethods: response.data!);
      }
    } catch (e) {
      // Silent fail for payment methods
    }
  }

  /// Add payment method
  Future<bool> addPaymentMethod({
    required String type,
    required Map<String, dynamic> details,
  }) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.addPaymentMethod(
        type: type,
        details: details,
      );

      if (response.success) {
        await loadPaymentMethods(forceRefresh: true);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to add payment method',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
      return false;
    }
  }

  /// Remove payment method
  Future<bool> removePaymentMethod(String paymentMethodId) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.removePaymentMethod(
        paymentMethodId,
      );

      if (response.success) {
        await loadPaymentMethods(forceRefresh: true);
        return true;
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to remove payment method',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
      return false;
    }
  }

  // ===== LIMITS AND GATEWAYS =====

  /// Load wallet limits
  Future<void> loadLimits({bool forceRefresh = false}) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.getWalletLimits(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(limits: response.data!);
      }
    } catch (e) {
      // Silent fail for limits
    }
  }

  /// Load payment gateways
  Future<void> loadGateways({bool forceRefresh = false}) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.getPaymentGateways(
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(gateways: response.data!);
      }
    } catch (e) {
      // Silent fail for gateways
    }
  }

  /// Load wallet summary
  Future<void> loadSummary({
    String timeframe = '30d',
    bool forceRefresh = false,
  }) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.getWalletSummary(
        timeframe: timeframe,
        forceRefresh: forceRefresh,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(summary: response.data!);
      }
    } catch (e) {
      // Silent fail for summary
    }
  }

  // ===== TRANSACTION DETAILS =====

  /// Get transaction details
  Future<TransactionModel?> getTransactionDetails(String transactionId) async {
    try {
      final walletRepository = ref.read(walletRepositoryProvider);
      final response = await walletRepository.getTransactionDetails(
        transactionId,
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw AppException.serverError(
          response.message ?? 'Failed to load transaction details',
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

  /// Get transaction by ID
  TransactionModel? getTransactionById(String transactionId) {
    try {
      return state.transactions.firstWhere((t) => t.id == transactionId);
    } catch (e) {
      return null;
    }
  }

  /// Check if amount is within deposit limits
  bool canDeposit(double amount) {
    return amount >= state.minimumDeposit &&
        amount <= state.maximumDeposit &&
        amount <= state.remainingDailyDeposit &&
        amount <= state.remainingMonthlyDeposit;
  }

  /// Check if amount is within withdrawal limits
  bool canWithdraw(double amount) {
    return amount >= state.minimumWithdrawal &&
        amount <= state.maximumWithdrawal &&
        amount <= state.remainingDailyWithdrawal &&
        amount <= state.remainingMonthlyWithdrawal &&
        amount <= state.availableBalance;
  }

  /// Get transaction chart data
  List<Map<String, dynamic>> getTransactionChartData({
    String timeframe = '30d',
    int maxPoints = 30,
  }) {
    final chartData = <String, Map<String, double>>{};

    for (final transaction in state.completedTransactions.take(maxPoints)) {
      final dateKey = transaction.createdAt.toIso8601String().split('T')[0];

      if (chartData[dateKey] == null) {
        chartData[dateKey] = {'deposits': 0.0, 'withdrawals': 0.0};
      }

      if (transaction.type == 'deposit') {
        chartData[dateKey]!['deposits'] =
            (chartData[dateKey]!['deposits'] ?? 0.0) + transaction.amount;
      } else if (transaction.type == 'withdrawal') {
        chartData[dateKey]!['withdrawals'] =
            (chartData[dateKey]!['withdrawals'] ?? 0.0) + transaction.amount;
      }
    }

    return chartData.entries
        .map(
          (e) => {
            'date': e.key,
            'deposits': e.value['deposits'],
            'withdrawals': e.value['withdrawals'],
          },
        )
        .toList();
  }

  /// Clear all transaction filters
  Future<void> clearTransactionFilters() async {
    await loadTransactions();
  }

  /// Force refresh all wallet data
  Future<void> refresh() async {
    await Future.wait([
      refreshBalance(),
      refreshTransactions(),
      loadPaymentMethods(forceRefresh: true),
      loadLimits(forceRefresh: true),
      loadGateways(forceRefresh: true),
      loadSummary(forceRefresh: true),
    ]);
  }
}

// ============================================================================
// ADDITIONAL PROVIDERS
// ============================================================================

/// Provider for wallet total balance
@riverpod
double walletTotalBalance(Ref ref) {
  return ref.watch(walletProvider.select((state) => state.totalBalance));
}

/// Provider for wallet available balance
@riverpod
double walletAvailableBalance(Ref ref) {
  return ref.watch(walletProvider.select((state) => state.availableBalance));
}

/// Provider for pending transactions
@riverpod
List<TransactionModel> pendingTransactions(Ref ref) {
  return ref.watch(walletProvider.select((state) => state.pendingTransactions));
}

/// Provider for recent transactions
@riverpod
List<TransactionModel> recentTransactions(Ref ref) {
  return ref.watch(
    walletProvider.select((state) => state.transactions.take(10).toList()),
  );
}

/// Provider for wallet loading state
@riverpod
bool isWalletLoading(Ref ref) {
  return ref.watch(walletProvider.select((state) => state.isLoading));
}

/// Provider for wallet error
@riverpod
String? walletError(Ref ref) {
  return ref.watch(walletProvider.select((state) => state.error));
}

/// Provider for daily deposit limit remaining
@riverpod
double remainingDailyDepositLimit(Ref ref) {
  return ref.watch(
    walletProvider.select((state) => state.remainingDailyDeposit),
  );
}

/// Provider for daily withdrawal limit remaining
@riverpod
double remainingDailyWithdrawalLimit(Ref ref) {
  return ref.watch(
    walletProvider.select((state) => state.remainingDailyWithdrawal),
  );
}

/// Provider for checking if transaction is processing
@riverpod
bool isProcessingTransaction(Ref ref) {
  return ref.watch(
    walletProvider.select((state) => state.isProcessingTransaction),
  );
}

/// Provider for payment methods
@riverpod
List<Map<String, dynamic>> paymentMethods(Ref ref) {
  return ref.watch(walletProvider.select((state) => state.paymentMethods));
}
