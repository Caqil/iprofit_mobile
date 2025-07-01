// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvestmentModel _$InvestmentModelFromJson(Map<String, dynamic> json) =>
    InvestmentModel(
      id: json['id'] as String,
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      currentValue: (json['currentValue'] as num).toDouble(),
      profitsEarned: (json['profitsEarned'] as num).toDouble(),
      expectedProfit: (json['expectedProfit'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      interestRate: (json['interestRate'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InvestmentModelToJson(InvestmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'planId': instance.planId,
      'planName': instance.planName,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'currentValue': instance.currentValue,
      'profitsEarned': instance.profitsEarned,
      'expectedProfit': instance.expectedProfit,
      'duration': instance.duration,
      'interestRate': instance.interestRate,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
