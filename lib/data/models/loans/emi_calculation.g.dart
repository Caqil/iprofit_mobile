// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi_calculation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EMICalculation _$EMICalculationFromJson(Map<String, dynamic> json) =>
    EMICalculation(
      loanAmount: (json['loanAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      tenure: (json['tenure'] as num).toInt(),
      emi: (json['emi'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalInterest: (json['totalInterest'] as num).toDouble(),
      breakdown: (json['breakdown'] as List<dynamic>)
          .map((e) => EMIBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EMICalculationToJson(EMICalculation instance) =>
    <String, dynamic>{
      'loanAmount': instance.loanAmount,
      'interestRate': instance.interestRate,
      'tenure': instance.tenure,
      'emi': instance.emi,
      'totalAmount': instance.totalAmount,
      'totalInterest': instance.totalInterest,
      'breakdown': instance.breakdown,
    };

EMIBreakdown _$EMIBreakdownFromJson(Map<String, dynamic> json) => EMIBreakdown(
  month: (json['month'] as num).toInt(),
  emi: (json['emi'] as num).toDouble(),
  principal: (json['principal'] as num).toDouble(),
  interest: (json['interest'] as num).toDouble(),
  balance: (json['balance'] as num).toDouble(),
);

Map<String, dynamic> _$EMIBreakdownToJson(EMIBreakdown instance) =>
    <String, dynamic>{
      'month': instance.month,
      'emi': instance.emi,
      'principal': instance.principal,
      'interest': instance.interest,
      'balance': instance.balance,
    };
