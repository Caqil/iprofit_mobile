// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanModel _$PlanModelFromJson(Map<String, dynamic> json) => PlanModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  color: json['color'] as String,
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String,
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool,
  isDefault: json['isDefault'] as bool,
  status: json['status'] as String,
  priority: (json['priority'] as num).toInt(),
  userCount: (json['userCount'] as num).toInt(),
  limits: PlanLimits.fromJson(json['limits'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PlanModelToJson(PlanModel instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'color': instance.color,
  'price': instance.price,
  'currency': instance.currency,
  'features': instance.features,
  'isActive': instance.isActive,
  'isDefault': instance.isDefault,
  'status': instance.status,
  'priority': instance.priority,
  'userCount': instance.userCount,
  'limits': instance.limits,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

PlanLimits _$PlanLimitsFromJson(Map<String, dynamic> json) => PlanLimits(
  depositLimit: (json['depositLimit'] as num).toDouble(),
  withdrawalLimit: (json['withdrawalLimit'] as num).toDouble(),
  profitLimit: (json['profitLimit'] as num).toDouble(),
  minimumDeposit: (json['minimumDeposit'] as num).toDouble(),
  minimumWithdrawal: (json['minimumWithdrawal'] as num).toDouble(),
  dailyWithdrawalLimit: (json['dailyWithdrawalLimit'] as num).toDouble(),
  monthlyWithdrawalLimit: (json['monthlyWithdrawalLimit'] as num).toDouble(),
);

Map<String, dynamic> _$PlanLimitsToJson(PlanLimits instance) =>
    <String, dynamic>{
      'depositLimit': instance.depositLimit,
      'withdrawalLimit': instance.withdrawalLimit,
      'profitLimit': instance.profitLimit,
      'minimumDeposit': instance.minimumDeposit,
      'minimumWithdrawal': instance.minimumWithdrawal,
      'dailyWithdrawalLimit': instance.dailyWithdrawalLimit,
      'monthlyWithdrawalLimit': instance.monthlyWithdrawalLimit,
    };
