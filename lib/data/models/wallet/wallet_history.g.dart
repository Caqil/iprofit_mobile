// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletHistory _$WalletHistoryFromJson(Map<String, dynamic> json) =>
    WalletHistory(
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      summary: WalletSummary.fromJson(json['summary'] as Map<String, dynamic>),
      filters: WalletFilters.fromJson(json['filters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WalletHistoryToJson(WalletHistory instance) =>
    <String, dynamic>{
      'transactions': instance.transactions,
      'pagination': instance.pagination,
      'summary': instance.summary,
      'filters': instance.filters,
    };

WalletSummary _$WalletSummaryFromJson(Map<String, dynamic> json) =>
    WalletSummary(
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalFees: (json['totalFees'] as num).toDouble(),
      totalNetAmount: (json['totalNetAmount'] as num).toDouble(),
      breakdown: TransactionBreakdown.fromJson(
        json['breakdown'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$WalletSummaryToJson(WalletSummary instance) =>
    <String, dynamic>{
      'totalTransactions': instance.totalTransactions,
      'totalAmount': instance.totalAmount,
      'totalFees': instance.totalFees,
      'totalNetAmount': instance.totalNetAmount,
      'breakdown': instance.breakdown,
    };

TransactionBreakdown _$TransactionBreakdownFromJson(
  Map<String, dynamic> json,
) => TransactionBreakdown(
  deposits: TransactionTypeBreakdown.fromJson(
    json['deposits'] as Map<String, dynamic>,
  ),
  withdrawals: TransactionTypeBreakdown.fromJson(
    json['withdrawals'] as Map<String, dynamic>,
  ),
  bonuses: TransactionTypeBreakdown.fromJson(
    json['bonuses'] as Map<String, dynamic>,
  ),
  profits: TransactionTypeBreakdown.fromJson(
    json['profits'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$TransactionBreakdownToJson(
  TransactionBreakdown instance,
) => <String, dynamic>{
  'deposits': instance.deposits,
  'withdrawals': instance.withdrawals,
  'bonuses': instance.bonuses,
  'profits': instance.profits,
};

TransactionTypeBreakdown _$TransactionTypeBreakdownFromJson(
  Map<String, dynamic> json,
) => TransactionTypeBreakdown(
  count: (json['count'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$TransactionTypeBreakdownToJson(
  TransactionTypeBreakdown instance,
) => <String, dynamic>{'count': instance.count, 'amount': instance.amount};

WalletFilters _$WalletFiltersFromJson(Map<String, dynamic> json) =>
    WalletFilters(
      appliedFilters: (json['appliedFilters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      availableFilters: AvailableFilters.fromJson(
        json['availableFilters'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$WalletFiltersToJson(WalletFilters instance) =>
    <String, dynamic>{
      'appliedFilters': instance.appliedFilters,
      'availableFilters': instance.availableFilters,
    };

AvailableFilters _$AvailableFiltersFromJson(Map<String, dynamic> json) =>
    AvailableFilters(
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      statuses: (json['statuses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      gateways: (json['gateways'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dateRange: json['dateRange'] == null
          ? null
          : DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AvailableFiltersToJson(AvailableFilters instance) =>
    <String, dynamic>{
      'types': instance.types,
      'statuses': instance.statuses,
      'gateways': instance.gateways,
      'dateRange': instance.dateRange,
    };

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => DateRange(
  min: DateTime.parse(json['min'] as String),
  max: DateTime.parse(json['max'] as String),
);

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
  'min': instance.min.toIso8601String(),
  'max': instance.max.toIso8601String(),
};
