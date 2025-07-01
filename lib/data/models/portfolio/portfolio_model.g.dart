// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioModel _$PortfolioModelFromJson(Map<String, dynamic> json) =>
    PortfolioModel(
      overview: PortfolioOverview.fromJson(
        json['overview'] as Map<String, dynamic>,
      ),
      activeInvestment: json['activeInvestment'] == null
          ? null
          : ActiveInvestment.fromJson(
              json['activeInvestment'] as Map<String, dynamic>,
            ),
      earningsBreakdown: EarningsBreakdown.fromJson(
        json['earningsBreakdown'] as Map<String, dynamic>,
      ),
      analytics: PortfolioAnalytics.fromJson(
        json['analytics'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PortfolioModelToJson(PortfolioModel instance) =>
    <String, dynamic>{
      'overview': instance.overview,
      'activeInvestment': instance.activeInvestment,
      'earningsBreakdown': instance.earningsBreakdown,
      'analytics': instance.analytics,
    };

PortfolioOverview _$PortfolioOverviewFromJson(Map<String, dynamic> json) =>
    PortfolioOverview(
      totalValue: (json['totalValue'] as num).toDouble(),
      totalInvested: (json['totalInvested'] as num).toDouble(),
      totalProfits: (json['totalProfits'] as num).toDouble(),
      totalLosses: (json['totalLosses'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      pendingProfits: (json['pendingProfits'] as num).toDouble(),
      realizedProfits: (json['realizedProfits'] as num).toDouble(),
      unrealizedProfits: (json['unrealizedProfits'] as num).toDouble(),
      totalInvestments: (json['totalInvestments'] as num).toInt(),
      activeInvestments: (json['activeInvestments'] as num).toInt(),
      completedInvestments: (json['completedInvestments'] as num).toInt(),
    );

Map<String, dynamic> _$PortfolioOverviewToJson(PortfolioOverview instance) =>
    <String, dynamic>{
      'totalValue': instance.totalValue,
      'totalInvested': instance.totalInvested,
      'totalProfits': instance.totalProfits,
      'totalLosses': instance.totalLosses,
      'currentBalance': instance.currentBalance,
      'pendingProfits': instance.pendingProfits,
      'realizedProfits': instance.realizedProfits,
      'unrealizedProfits': instance.unrealizedProfits,
      'totalInvestments': instance.totalInvestments,
      'activeInvestments': instance.activeInvestments,
      'completedInvestments': instance.completedInvestments,
    };

ActiveInvestment _$ActiveInvestmentFromJson(Map<String, dynamic> json) =>
    ActiveInvestment(
      id: json['id'] as String,
      plan: PlanInfo.fromJson(json['plan'] as Map<String, dynamic>),
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      daysActive: (json['daysActive'] as num).toInt(),
      investmentAmount: (json['investmentAmount'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      profitsEarned: (json['profitsEarned'] as num).toDouble(),
      nextProfitDate: DateTime.parse(json['nextProfitDate'] as String),
      nextProfitAmount: (json['nextProfitAmount'] as num).toDouble(),
      performance: PerformanceMetrics.fromJson(
        json['performance'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ActiveInvestmentToJson(ActiveInvestment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan': instance.plan,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'daysActive': instance.daysActive,
      'investmentAmount': instance.investmentAmount,
      'currentValue': instance.currentValue,
      'profitsEarned': instance.profitsEarned,
      'nextProfitDate': instance.nextProfitDate.toIso8601String(),
      'nextProfitAmount': instance.nextProfitAmount,
      'performance': instance.performance,
    };

PerformanceMetrics _$PerformanceMetricsFromJson(Map<String, dynamic> json) =>
    PerformanceMetrics(
      roi: (json['roi'] as num).toDouble(),
      dailyAverage: (json['dailyAverage'] as num).toDouble(),
      weeklyAverage: (json['weeklyAverage'] as num).toDouble(),
      monthlyAverage: (json['monthlyAverage'] as num).toDouble(),
      bestDay: BestDay.fromJson(json['bestDay'] as Map<String, dynamic>),
      consistency: (json['consistency'] as num).toDouble(),
      volatility: json['volatility'] as String,
    );

Map<String, dynamic> _$PerformanceMetricsToJson(PerformanceMetrics instance) =>
    <String, dynamic>{
      'roi': instance.roi,
      'dailyAverage': instance.dailyAverage,
      'weeklyAverage': instance.weeklyAverage,
      'monthlyAverage': instance.monthlyAverage,
      'bestDay': instance.bestDay,
      'consistency': instance.consistency,
      'volatility': instance.volatility,
    };

BestDay _$BestDayFromJson(Map<String, dynamic> json) => BestDay(
  date: DateTime.parse(json['date'] as String),
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$BestDayToJson(BestDay instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'amount': instance.amount,
};

EarningsBreakdown _$EarningsBreakdownFromJson(Map<String, dynamic> json) =>
    EarningsBreakdown(
      investmentProfits: EarningsCategoryBreakdown.fromJson(
        json['investmentProfits'] as Map<String, dynamic>,
      ),
      bonuses: EarningsCategoryBreakdown.fromJson(
        json['bonuses'] as Map<String, dynamic>,
      ),
      referrals: EarningsCategoryBreakdown.fromJson(
        json['referrals'] as Map<String, dynamic>,
      ),
      others: EarningsCategoryBreakdown.fromJson(
        json['others'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$EarningsBreakdownToJson(EarningsBreakdown instance) =>
    <String, dynamic>{
      'investmentProfits': instance.investmentProfits,
      'bonuses': instance.bonuses,
      'referrals': instance.referrals,
      'others': instance.others,
    };

EarningsCategoryBreakdown _$EarningsCategoryBreakdownFromJson(
  Map<String, dynamic> json,
) => EarningsCategoryBreakdown(
  amount: (json['amount'] as num).toDouble(),
  percentage: (json['percentage'] as num).toDouble(),
  transactions: (json['transactions'] as num).toInt(),
  avgPerTransaction: (json['avgPerTransaction'] as num).toDouble(),
  trend: json['trend'] as String,
);

Map<String, dynamic> _$EarningsCategoryBreakdownToJson(
  EarningsCategoryBreakdown instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'percentage': instance.percentage,
  'transactions': instance.transactions,
  'avgPerTransaction': instance.avgPerTransaction,
  'trend': instance.trend,
};

PortfolioAnalytics _$PortfolioAnalyticsFromJson(Map<String, dynamic> json) =>
    PortfolioAnalytics(
      portfolioScore: PortfolioScore.fromJson(
        json['portfolioScore'] as Map<String, dynamic>,
      ),
      riskMetrics: RiskMetrics.fromJson(
        json['riskMetrics'] as Map<String, dynamic>,
      ),
      growthMetrics: GrowthMetrics.fromJson(
        json['growthMetrics'] as Map<String, dynamic>,
      ),
      performanceHistory: PerformanceHistory.fromJson(
        json['performanceHistory'] as Map<String, dynamic>,
      ),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PortfolioAnalyticsToJson(PortfolioAnalytics instance) =>
    <String, dynamic>{
      'portfolioScore': instance.portfolioScore,
      'riskMetrics': instance.riskMetrics,
      'growthMetrics': instance.growthMetrics,
      'performanceHistory': instance.performanceHistory,
      'recommendations': instance.recommendations,
    };

PortfolioScore _$PortfolioScoreFromJson(Map<String, dynamic> json) =>
    PortfolioScore(
      overall: (json['overall'] as num).toDouble(),
      risk: (json['risk'] as num).toDouble(),
      growth: (json['growth'] as num).toDouble(),
      stability: (json['stability'] as num).toDouble(),
      efficiency: (json['efficiency'] as num).toDouble(),
    );

Map<String, dynamic> _$PortfolioScoreToJson(PortfolioScore instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'risk': instance.risk,
      'growth': instance.growth,
      'stability': instance.stability,
      'efficiency': instance.efficiency,
    };

RiskMetrics _$RiskMetricsFromJson(Map<String, dynamic> json) => RiskMetrics(
  level: json['level'] as String,
  score: (json['score'] as num).toDouble(),
  maxDrawdown: (json['maxDrawdown'] as num).toDouble(),
  volatility: (json['volatility'] as num).toDouble(),
  sharpeRatio: (json['sharpeRatio'] as num).toDouble(),
  factors: (json['factors'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$RiskMetricsToJson(RiskMetrics instance) =>
    <String, dynamic>{
      'level': instance.level,
      'score': instance.score,
      'maxDrawdown': instance.maxDrawdown,
      'volatility': instance.volatility,
      'sharpeRatio': instance.sharpeRatio,
      'factors': instance.factors,
    };

GrowthMetrics _$GrowthMetricsFromJson(Map<String, dynamic> json) =>
    GrowthMetrics(
      monthlyGrowthRate: (json['monthlyGrowthRate'] as num).toDouble(),
      annualizedReturn: (json['annualizedReturn'] as num).toDouble(),
      cagr: (json['cagr'] as num).toDouble(),
      targetAchievement: (json['targetAchievement'] as num).toDouble(),
      projection: GrowthProjection.fromJson(
        json['projection'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$GrowthMetricsToJson(GrowthMetrics instance) =>
    <String, dynamic>{
      'monthlyGrowthRate': instance.monthlyGrowthRate,
      'annualizedReturn': instance.annualizedReturn,
      'cagr': instance.cagr,
      'targetAchievement': instance.targetAchievement,
      'projection': instance.projection,
    };

GrowthProjection _$GrowthProjectionFromJson(Map<String, dynamic> json) =>
    GrowthProjection(
      nextMonth: (json['nextMonth'] as num).toDouble(),
      nextQuarter: (json['nextQuarter'] as num).toDouble(),
      nextYear: (json['nextYear'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$GrowthProjectionToJson(GrowthProjection instance) =>
    <String, dynamic>{
      'nextMonth': instance.nextMonth,
      'nextQuarter': instance.nextQuarter,
      'nextYear': instance.nextYear,
      'confidence': instance.confidence,
    };

PerformanceHistory _$PerformanceHistoryFromJson(Map<String, dynamic> json) =>
    PerformanceHistory(
      daily: (json['daily'] as List<dynamic>)
          .map((e) => PerformanceDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      weekly: (json['weekly'] as List<dynamic>)
          .map((e) => PerformanceDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthly: (json['monthly'] as List<dynamic>)
          .map((e) => PerformanceDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PerformanceHistoryToJson(PerformanceHistory instance) =>
    <String, dynamic>{
      'daily': instance.daily,
      'weekly': instance.weekly,
      'monthly': instance.monthly,
    };

PerformanceDataPoint _$PerformanceDataPointFromJson(
  Map<String, dynamic> json,
) => PerformanceDataPoint(
  date: DateTime.parse(json['date'] as String),
  value: (json['value'] as num).toDouble(),
  change: (json['change'] as num).toDouble(),
  changePercentage: (json['changePercentage'] as num).toDouble(),
);

Map<String, dynamic> _$PerformanceDataPointToJson(
  PerformanceDataPoint instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'value': instance.value,
  'change': instance.change,
  'changePercentage': instance.changePercentage,
};
