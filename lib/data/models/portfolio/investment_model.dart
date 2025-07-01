import 'package:json_annotation/json_annotation.dart';

part 'investment_model.g.dart';

@JsonSerializable()
class InvestmentModel {
  final String id;
  final String planId;
  final String planName;
  final double amount;
  final String currency;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final double currentValue;
  final double profitsEarned;
  final double expectedProfit;
  final int duration;
  final double interestRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentModel({
    required this.id,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.currentValue,
    required this.profitsEarned,
    required this.expectedProfit,
    required this.duration,
    required this.interestRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) =>
      _$InvestmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvestmentModelToJson(this);
}
