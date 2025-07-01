// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_earnings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralEarnings _$ReferralEarningsFromJson(Map<String, dynamic> json) =>
    ReferralEarnings(
      earnings: (json['earnings'] as List<dynamic>)
          .map((e) => EarningTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: EarningSummary.fromJson(json['summary'] as Map<String, dynamic>),
      analytics: EarningAnalytics.fromJson(
        json['analytics'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ReferralEarningsToJson(ReferralEarnings instance) =>
    <String, dynamic>{
      'earnings': instance.earnings,
      'summary': instance.summary,
      'analytics': instance.analytics,
    };

EarningTransaction _$EarningTransactionFromJson(Map<String, dynamic> json) =>
    EarningTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      refereeId: json['refereeId'] as String,
      refereeName: json['refereeName'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EarningTransactionToJson(EarningTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'refereeId': instance.refereeId,
      'refereeName': instance.refereeName,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

EarningSummary _$EarningSummaryFromJson(Map<String, dynamic> json) =>
    EarningSummary(
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      thisMonth: (json['thisMonth'] as num).toDouble(),
      lastMonth: (json['lastMonth'] as num).toDouble(),
      dailyAverage: (json['dailyAverage'] as num).toDouble(),
      monthlyAverage: (json['monthlyAverage'] as num).toDouble(),
      bestDay: json['bestDay'] as String,
      lastEarningDate: json['lastEarningDate'] == null
          ? null
          : DateTime.parse(json['lastEarningDate'] as String),
    );

Map<String, dynamic> _$EarningSummaryToJson(EarningSummary instance) =>
    <String, dynamic>{
      'totalEarnings': instance.totalEarnings,
      'thisMonth': instance.thisMonth,
      'lastMonth': instance.lastMonth,
      'dailyAverage': instance.dailyAverage,
      'monthlyAverage': instance.monthlyAverage,
      'bestDay': instance.bestDay,
      'lastEarningDate': instance.lastEarningDate?.toIso8601String(),
    };

EarningAnalytics _$EarningAnalyticsFromJson(Map<String, dynamic> json) =>
    EarningAnalytics(
      performance: EarningPerformance.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
      projections: EarningProjections.fromJson(
        json['projections'] as Map<String, dynamic>,
      ),
      comparisons: EarningComparisons.fromJson(
        json['comparisons'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$EarningAnalyticsToJson(EarningAnalytics instance) =>
    <String, dynamic>{
      'performance': instance.performance,
      'projections': instance.projections,
      'comparisons': instance.comparisons,
    };

EarningPerformance _$EarningPerformanceFromJson(Map<String, dynamic> json) =>
    EarningPerformance(
      bestDay: json['bestDay'] as String,
      bestTime: json['bestTime'] as String,
      averageGrowthRate: (json['averageGrowthRate'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
    );

Map<String, dynamic> _$EarningPerformanceToJson(EarningPerformance instance) =>
    <String, dynamic>{
      'bestDay': instance.bestDay,
      'bestTime': instance.bestTime,
      'averageGrowthRate': instance.averageGrowthRate,
      'consistency': instance.consistency,
    };

EarningProjections _$EarningProjectionsFromJson(Map<String, dynamic> json) =>
    EarningProjections(
      nextMonth: (json['nextMonth'] as num).toDouble(),
      nextQuarter: (json['nextQuarter'] as num).toDouble(),
      yearEnd: (json['yearEnd'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$EarningProjectionsToJson(EarningProjections instance) =>
    <String, dynamic>{
      'nextMonth': instance.nextMonth,
      'nextQuarter': instance.nextQuarter,
      'yearEnd': instance.yearEnd,
      'confidence': instance.confidence,
    };

EarningComparisons _$EarningComparisonsFromJson(Map<String, dynamic> json) =>
    EarningComparisons(
      vsLastMonth: (json['vsLastMonth'] as num).toDouble(),
      vsLastQuarter: (json['vsLastQuarter'] as num).toDouble(),
      vsLastYear: (json['vsLastYear'] as num).toDouble(),
    );

Map<String, dynamic> _$EarningComparisonsToJson(EarningComparisons instance) =>
    <String, dynamic>{
      'vsLastMonth': instance.vsLastMonth,
      'vsLastQuarter': instance.vsLastQuarter,
      'vsLastYear': instance.vsLastYear,
    };
