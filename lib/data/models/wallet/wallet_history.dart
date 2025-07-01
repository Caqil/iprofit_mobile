import 'package:json_annotation/json_annotation.dart';
import '../common/pagination.dart';
import 'transaction_model.dart';

part 'wallet_history.g.dart';

@JsonSerializable()
class WalletHistory {
  final List<TransactionModel> transactions;
  final Pagination pagination;
  final WalletSummary summary;
  final WalletFilters filters;

  WalletHistory({
    required this.transactions,
    required this.pagination,
    required this.summary,
    required this.filters,
  });

  factory WalletHistory.fromJson(Map<String, dynamic> json) =>
      _$WalletHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$WalletHistoryToJson(this);
}

@JsonSerializable()
class WalletSummary {
  final int totalTransactions;
  final double totalAmount;
  final double totalFees;
  final double totalNetAmount;
  final TransactionBreakdown breakdown;

  WalletSummary({
    required this.totalTransactions,
    required this.totalAmount,
    required this.totalFees,
    required this.totalNetAmount,
    required this.breakdown,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) =>
      _$WalletSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$WalletSummaryToJson(this);
}

@JsonSerializable()
class TransactionBreakdown {
  final TransactionTypeBreakdown deposits;
  final TransactionTypeBreakdown withdrawals;
  final TransactionTypeBreakdown bonuses;
  final TransactionTypeBreakdown profits;

  TransactionBreakdown({
    required this.deposits,
    required this.withdrawals,
    required this.bonuses,
    required this.profits,
  });

  factory TransactionBreakdown.fromJson(Map<String, dynamic> json) =>
      _$TransactionBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionBreakdownToJson(this);
}

@JsonSerializable()
class TransactionTypeBreakdown {
  final int count;
  final double amount;

  TransactionTypeBreakdown({required this.count, required this.amount});

  factory TransactionTypeBreakdown.fromJson(Map<String, dynamic> json) =>
      _$TransactionTypeBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionTypeBreakdownToJson(this);
}

@JsonSerializable()
class WalletFilters {
  final List<String> appliedFilters;
  final AvailableFilters availableFilters;

  WalletFilters({required this.appliedFilters, required this.availableFilters});

  factory WalletFilters.fromJson(Map<String, dynamic> json) =>
      _$WalletFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$WalletFiltersToJson(this);
}

@JsonSerializable()
class AvailableFilters {
  final List<String> types;
  final List<String> statuses;
  final List<String> gateways;
  final DateRange? dateRange;

  AvailableFilters({
    required this.types,
    required this.statuses,
    required this.gateways,
    this.dateRange,
  });

  factory AvailableFilters.fromJson(Map<String, dynamic> json) =>
      _$AvailableFiltersFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableFiltersToJson(this);
}

@JsonSerializable()
class DateRange {
  final DateTime min;
  final DateTime max;

  DateRange({required this.min, required this.max});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);
}
