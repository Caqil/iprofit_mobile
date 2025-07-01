import 'package:json_annotation/json_annotation.dart';

part 'emi_calculation.g.dart';

@JsonSerializable()
class EMICalculation {
  final double loanAmount;
  final double interestRate;
  final int tenure;
  final double emi;
  final double totalAmount;
  final double totalInterest;
  final List<EMIBreakdown> breakdown;

  EMICalculation({
    required this.loanAmount,
    required this.interestRate,
    required this.tenure,
    required this.emi,
    required this.totalAmount,
    required this.totalInterest,
    required this.breakdown,
  });

  factory EMICalculation.fromJson(Map<String, dynamic> json) =>
      _$EMICalculationFromJson(json);

  Map<String, dynamic> toJson() => _$EMICalculationToJson(this);
}

@JsonSerializable()
class EMIBreakdown {
  final int month;
  final double emi;
  final double principal;
  final double interest;
  final double balance;

  EMIBreakdown({
    required this.month,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  factory EMIBreakdown.fromJson(Map<String, dynamic> json) =>
      _$EMIBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$EMIBreakdownToJson(this);
}
