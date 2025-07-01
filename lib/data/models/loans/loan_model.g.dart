// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoanModel _$LoanModelFromJson(Map<String, dynamic> json) => LoanModel(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  purpose: json['purpose'] as String,
  tenure: (json['tenure'] as num).toInt(),
  interestRate: (json['interestRate'] as num).toDouble(),
  emi: (json['emi'] as num).toDouble(),
  status: json['status'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  repaidAmount: (json['repaidAmount'] as num).toDouble(),
  remainingAmount: (json['remainingAmount'] as num).toDouble(),
  nextPaymentDate: json['nextPaymentDate'] == null
      ? null
      : DateTime.parse(json['nextPaymentDate'] as String),
  disbursedAt: json['disbursedAt'] == null
      ? null
      : DateTime.parse(json['disbursedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  terms: json['terms'] == null
      ? null
      : LoanTerms.fromJson(json['terms'] as Map<String, dynamic>),
  repaymentSchedule: (json['repaymentSchedule'] as List<dynamic>?)
      ?.map((e) => RepaymentInstallment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LoanModelToJson(LoanModel instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'currency': instance.currency,
  'purpose': instance.purpose,
  'tenure': instance.tenure,
  'interestRate': instance.interestRate,
  'emi': instance.emi,
  'status': instance.status,
  'totalAmount': instance.totalAmount,
  'repaidAmount': instance.repaidAmount,
  'remainingAmount': instance.remainingAmount,
  'nextPaymentDate': instance.nextPaymentDate?.toIso8601String(),
  'disbursedAt': instance.disbursedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'terms': instance.terms,
  'repaymentSchedule': instance.repaymentSchedule,
};

LoanTerms _$LoanTermsFromJson(Map<String, dynamic> json) => LoanTerms(
  processingFee: json['processingFee'] as String,
  lateFee: json['lateFee'] as String,
  prepaymentCharges: json['prepaymentCharges'] as String,
  conditions: (json['conditions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$LoanTermsToJson(LoanTerms instance) => <String, dynamic>{
  'processingFee': instance.processingFee,
  'lateFee': instance.lateFee,
  'prepaymentCharges': instance.prepaymentCharges,
  'conditions': instance.conditions,
};

RepaymentInstallment _$RepaymentInstallmentFromJson(
  Map<String, dynamic> json,
) => RepaymentInstallment(
  installmentNumber: (json['installmentNumber'] as num).toInt(),
  dueDate: DateTime.parse(json['dueDate'] as String),
  emiAmount: (json['emiAmount'] as num).toDouble(),
  principalAmount: (json['principalAmount'] as num).toDouble(),
  interestAmount: (json['interestAmount'] as num).toDouble(),
  remainingBalance: (json['remainingBalance'] as num).toDouble(),
  status: json['status'] as String,
  paidDate: json['paidDate'] == null
      ? null
      : DateTime.parse(json['paidDate'] as String),
  paidAmount: (json['paidAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RepaymentInstallmentToJson(
  RepaymentInstallment instance,
) => <String, dynamic>{
  'installmentNumber': instance.installmentNumber,
  'dueDate': instance.dueDate.toIso8601String(),
  'emiAmount': instance.emiAmount,
  'principalAmount': instance.principalAmount,
  'interestAmount': instance.interestAmount,
  'remainingBalance': instance.remainingBalance,
  'status': instance.status,
  'paidDate': instance.paidDate?.toIso8601String(),
  'paidAmount': instance.paidAmount,
};
