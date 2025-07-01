import 'package:json_annotation/json_annotation.dart';

part 'loan_model.g.dart';

@JsonSerializable()
class LoanModel {
  final String id;
  final double amount;
  final String currency;
  final String purpose;
  final int tenure;
  final double interestRate;
  final double emi;
  final String status;
  final double totalAmount;
  final double repaidAmount;
  final double remainingAmount;
  final DateTime? nextPaymentDate;
  final DateTime? disbursedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LoanTerms? terms;
  final List<RepaymentInstallment>? repaymentSchedule;

  LoanModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.purpose,
    required this.tenure,
    required this.interestRate,
    required this.emi,
    required this.status,
    required this.totalAmount,
    required this.repaidAmount,
    required this.remainingAmount,
    this.nextPaymentDate,
    this.disbursedAt,
    required this.createdAt,
    required this.updatedAt,
    this.terms,
    this.repaymentSchedule,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) =>
      _$LoanModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoanModelToJson(this);
}

@JsonSerializable()
class LoanTerms {
  final String processingFee;
  final String lateFee;
  final String prepaymentCharges;
  final List<String> conditions;

  LoanTerms({
    required this.processingFee,
    required this.lateFee,
    required this.prepaymentCharges,
    required this.conditions,
  });

  factory LoanTerms.fromJson(Map<String, dynamic> json) =>
      _$LoanTermsFromJson(json);

  Map<String, dynamic> toJson() => _$LoanTermsToJson(this);
}

@JsonSerializable()
class RepaymentInstallment {
  final int installmentNumber;
  final DateTime dueDate;
  final double emiAmount;
  final double principalAmount;
  final double interestAmount;
  final double remainingBalance;
  final String status;
  final DateTime? paidDate;
  final double? paidAmount;

  RepaymentInstallment({
    required this.installmentNumber,
    required this.dueDate,
    required this.emiAmount,
    required this.principalAmount,
    required this.interestAmount,
    required this.remainingBalance,
    required this.status,
    this.paidDate,
    this.paidAmount,
  });

  factory RepaymentInstallment.fromJson(Map<String, dynamic> json) =>
      _$RepaymentInstallmentFromJson(json);

  Map<String, dynamic> toJson() => _$RepaymentInstallmentToJson(this);
}
