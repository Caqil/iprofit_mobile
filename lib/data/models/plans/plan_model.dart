// ============================================================================
// lib/data/models/plans/plan_model.dart
// ============================================================================

import 'package:json_annotation/json_annotation.dart';

part 'plan_model.g.dart';

@JsonSerializable()
class PlanModel {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String description;
  final String color;
  final double price;
  final String currency;
  final List<String> features;
  final bool isActive;
  final bool isDefault;
  final String status;
  final int priority;
  final int userCount;
  final PlanLimits limits;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.price,
    required this.currency,
    required this.features,
    required this.isActive,
    required this.isDefault,
    required this.status,
    required this.priority,
    required this.userCount,
    required this.limits,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlanModelToJson(this);

  /// Check if plan is free
  bool get isFree => price == 0;

  /// Check if plan is popular (you can define logic based on userCount or priority)
  bool get isPopular => priority == 1 || userCount > 100;

  /// Get formatted price
  String get formattedPrice {
    if (isFree) return 'Free';
    return '$currency ${price.toStringAsFixed(0)}';
  }

  /// Get plan badge text
  String? get badgeText {
    if (isFree) return 'FREE';
    if (isDefault) return 'DEFAULT';
    if (isPopular) return 'POPULAR';
    return null;
  }

  /// Get daily return estimate (you can customize this logic)
  String get dailyReturnEstimate {
    switch (priority) {
      case 0: return '0.5%'; // Free plan
      case 1: return '1.2%'; // Silver
      case 2: return '2.0%'; // Gold  
      case 3: return '3.5%'; // Platinum
      case 4: return '5.0%'; // Diamond
      default: return '1.0%';
    }
  }

  /// Check if plan is suitable for amount
  bool isSuitableForAmount(double amount) {
    return amount >= limits.minimumDeposit && amount <= limits.depositLimit;
  }
}

@JsonSerializable()
class PlanLimits {
  final double depositLimit;
  final double withdrawalLimit;
  final double profitLimit;
  final double minimumDeposit;
  final double minimumWithdrawal;
  final double dailyWithdrawalLimit;
  final double monthlyWithdrawalLimit;

  PlanLimits({
    required this.depositLimit,
    required this.withdrawalLimit,
    required this.profitLimit,
    required this.minimumDeposit,
    required this.minimumWithdrawal,
    required this.dailyWithdrawalLimit,
    required this.monthlyWithdrawalLimit,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) =>
      _$PlanLimitsFromJson(json);

  Map<String, dynamic> toJson() => _$PlanLimitsToJson(this);

  /// Get formatted minimum deposit
  String get formattedMinDeposit => minimumDeposit.toStringAsFixed(0);

  /// Get formatted deposit limit
  String get formattedDepositLimit => depositLimit.toStringAsFixed(0);
}