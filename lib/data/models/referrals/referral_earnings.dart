import 'package:json_annotation/json_annotation.dart';

part 'referral_earnings.g.dart';

@JsonSerializable()
class ReferralEarnings {
  final List<EarningTransaction> earnings;
  final EarningSummary summary;
  final EarningAnalytics analytics;

  ReferralEarnings({
    required this.earnings,
    required this.summary,
    required this.analytics,
  });

  factory ReferralEarnings.fromJson(Map<String, dynamic> json) =>
      _$ReferralEarningsFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralEarningsToJson(this);
}

@JsonSerializable()
class EarningTransaction {
  final String id;
  final String type;
  final double amount;
  final String refereeId;
  final String refereeName;
  final String status;
  final DateTime createdAt;

  EarningTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.refereeId,
    required this.refereeName,
    required this.status,
    required this.createdAt,
  });

  factory EarningTransaction.fromJson(Map<String, dynamic> json) =>
      _$EarningTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$EarningTransactionToJson(this);
}

@JsonSerializable()
class EarningSummary {
  final double totalEarnings;
  final double thisMonth;
  final double lastMonth;
  final double dailyAverage;
  final double monthlyAverage;
  final String bestDay;
  final DateTime? lastEarningDate;

  EarningSummary({
    required this.totalEarnings,
    required this.thisMonth,
    required this.lastMonth,
    required this.dailyAverage,
    required this.monthlyAverage,
    required this.bestDay,
    this.lastEarningDate,
  });

  factory EarningSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$EarningSummaryToJson(this);
}

@JsonSerializable()
class EarningAnalytics {
  final EarningPerformance performance;
  final EarningProjections projections;
  final EarningComparisons comparisons;

  EarningAnalytics({
    required this.performance,
    required this.projections,
    required this.comparisons,
  });

  factory EarningAnalytics.fromJson(Map<String, dynamic> json) =>
      _$EarningAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$EarningAnalyticsToJson(this);
}

@JsonSerializable()
class EarningPerformance {
  final String bestDay;
  final String bestTime;
  final double averageGrowthRate;
  final double consistency;

  EarningPerformance({
    required this.bestDay,
    required this.bestTime,
    required this.averageGrowthRate,
    required this.consistency,
  });

  factory EarningPerformance.fromJson(Map<String, dynamic> json) =>
      _$EarningPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$EarningPerformanceToJson(this);
}

@JsonSerializable()
class EarningProjections {
  final double nextMonth;
  final double nextQuarter;
  final double yearEnd;
  final double confidence;

  EarningProjections({
    required this.nextMonth,
    required this.nextQuarter,
    required this.yearEnd,
    required this.confidence,
  });

  factory EarningProjections.fromJson(Map<String, dynamic> json) =>
      _$EarningProjectionsFromJson(json);

  Map<String, dynamic> toJson() => _$EarningProjectionsToJson(this);
}

@JsonSerializable()
class EarningComparisons {
  final double vsLastMonth;
  final double vsLastQuarter;
  final double vsLastYear;

  EarningComparisons({
    required this.vsLastMonth,
    required this.vsLastQuarter,
    required this.vsLastYear,
  });

  factory EarningComparisons.fromJson(Map<String, dynamic> json) =>
      _$EarningComparisonsFromJson(json);

  Map<String, dynamic> toJson() => _$EarningComparisonsToJson(this);
}
