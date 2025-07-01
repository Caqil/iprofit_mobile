import 'package:json_annotation/json_annotation.dart';

part 'portfolio_model.g.dart';

@JsonSerializable()
class PortfolioModel {
  final PortfolioOverview overview;
  final ActiveInvestment? activeInvestment;
  final EarningsBreakdown earningsBreakdown;
  final PortfolioAnalytics analytics;

  PortfolioModel({
    required this.overview,
    this.activeInvestment,
    required this.earningsBreakdown,
    required this.analytics,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) =>
      _$PortfolioModelFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioModelToJson(this);
}

@JsonSerializable()
class PortfolioOverview {
  final double totalValue;
  final double totalInvested;
  final double totalProfits;
  final double totalLosses;
  final double currentBalance;
  final double pendingProfits;
  final double realizedProfits;
  final double unrealizedProfits;
  final int totalInvestments;
  final int activeInvestments;
  final int completedInvestments;

  PortfolioOverview({
    required this.totalValue,
    required this.totalInvested,
    required this.totalProfits,
    required this.totalLosses,
    required this.currentBalance,
    required this.pendingProfits,
    required this.realizedProfits,
    required this.unrealizedProfits,
    required this.totalInvestments,
    required this.activeInvestments,
    required this.completedInvestments,
  });

  factory PortfolioOverview.fromJson(Map<String, dynamic> json) =>
      _$PortfolioOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioOverviewToJson(this);
}

@JsonSerializable()
class ActiveInvestment {
  final String id;
  final PlanInfo plan;
  final String status;
  final DateTime startDate;
  final int daysActive;
  final double investmentAmount;
  final double currentValue;
  final double profitsEarned;
  final DateTime nextProfitDate;
  final double nextProfitAmount;
  final PerformanceMetrics performance;

  ActiveInvestment({
    required this.id,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.daysActive,
    required this.investmentAmount,
    required this.currentValue,
    required this.profitsEarned,
    required this.nextProfitDate,
    required this.nextProfitAmount,
    required this.performance,
  });

  factory ActiveInvestment.fromJson(Map<String, dynamic> json) =>
      _$ActiveInvestmentFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveInvestmentToJson(this);
}

@JsonSerializable()
class PerformanceMetrics {
  final double roi;
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final BestDay bestDay;
  final double consistency;
  final String volatility;

  PerformanceMetrics({
    required this.roi,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.bestDay,
    required this.consistency,
    required this.volatility,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceMetricsToJson(this);
}

@JsonSerializable()
class BestDay {
  final DateTime date;
  final double amount;

  BestDay({required this.date, required this.amount});

  factory BestDay.fromJson(Map<String, dynamic> json) =>
      _$BestDayFromJson(json);

  Map<String, dynamic> toJson() => _$BestDayToJson(this);
}

@JsonSerializable()
class EarningsBreakdown {
  final EarningsCategoryBreakdown investmentProfits;
  final EarningsCategoryBreakdown bonuses;
  final EarningsCategoryBreakdown referrals;
  final EarningsCategoryBreakdown others;

  EarningsBreakdown({
    required this.investmentProfits,
    required this.bonuses,
    required this.referrals,
    required this.others,
  });

  factory EarningsBreakdown.fromJson(Map<String, dynamic> json) =>
      _$EarningsBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsBreakdownToJson(this);
}

@JsonSerializable()
class EarningsCategoryBreakdown {
  final double amount;
  final double percentage;
  final int transactions;
  final double avgPerTransaction;
  final String trend;

  EarningsCategoryBreakdown({
    required this.amount,
    required this.percentage,
    required this.transactions,
    required this.avgPerTransaction,
    required this.trend,
  });

  factory EarningsCategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$EarningsCategoryBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsCategoryBreakdownToJson(this);
}

@JsonSerializable()
class PortfolioAnalytics {
  final PortfolioScore portfolioScore;
  final RiskMetrics riskMetrics;
  final GrowthMetrics growthMetrics;
  final PerformanceHistory performanceHistory;
  final List<String> recommendations;

  PortfolioAnalytics({
    required this.portfolioScore,
    required this.riskMetrics,
    required this.growthMetrics,
    required this.performanceHistory,
    required this.recommendations,
  });

  factory PortfolioAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PortfolioAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioAnalyticsToJson(this);
}

@JsonSerializable()
class PortfolioScore {
  final double overall;
  final double risk;
  final double growth;
  final double stability;
  final double efficiency;

  PortfolioScore({
    required this.overall,
    required this.risk,
    required this.growth,
    required this.stability,
    required this.efficiency,
  });

  factory PortfolioScore.fromJson(Map<String, dynamic> json) =>
      _$PortfolioScoreFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioScoreToJson(this);
}

@JsonSerializable()
class RiskMetrics {
  final String level;
  final double score;
  final double maxDrawdown;
  final double volatility;
  final double sharpeRatio;
  final List<String> factors;

  RiskMetrics({
    required this.level,
    required this.score,
    required this.maxDrawdown,
    required this.volatility,
    required this.sharpeRatio,
    required this.factors,
  });

  factory RiskMetrics.fromJson(Map<String, dynamic> json) =>
      _$RiskMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$RiskMetricsToJson(this);
}

@JsonSerializable()
class GrowthMetrics {
  final double monthlyGrowthRate;
  final double annualizedReturn;
  final double cagr;
  final double targetAchievement;
  final GrowthProjection projection;

  GrowthMetrics({
    required this.monthlyGrowthRate,
    required this.annualizedReturn,
    required this.cagr,
    required this.targetAchievement,
    required this.projection,
  });

  factory GrowthMetrics.fromJson(Map<String, dynamic> json) =>
      _$GrowthMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthMetricsToJson(this);
}

@JsonSerializable()
class GrowthProjection {
  final double nextMonth;
  final double nextQuarter;
  final double nextYear;
  final double confidence;

  GrowthProjection({
    required this.nextMonth,
    required this.nextQuarter,
    required this.nextYear,
    required this.confidence,
  });

  factory GrowthProjection.fromJson(Map<String, dynamic> json) =>
      _$GrowthProjectionFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthProjectionToJson(this);
}

@JsonSerializable()
class PerformanceHistory {
  final List<PerformanceDataPoint> daily;
  final List<PerformanceDataPoint> weekly;
  final List<PerformanceDataPoint> monthly;

  PerformanceHistory({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory PerformanceHistory.fromJson(Map<String, dynamic> json) =>
      _$PerformanceHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceHistoryToJson(this);
}

@JsonSerializable()
class PerformanceDataPoint {
  final DateTime date;
  final double value;
  final double change;
  final double changePercentage;

  PerformanceDataPoint({
    required this.date,
    required this.value,
    required this.change,
    required this.changePercentage,
  });

  factory PerformanceDataPoint.fromJson(Map<String, dynamic> json) =>
      _$PerformanceDataPointFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceDataPointToJson(this);
}
