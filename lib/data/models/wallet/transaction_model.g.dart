// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(
  Map<String, dynamic> json,
) => TransactionModel(
  id: json['id'] as String,
  transactionId: json['transactionId'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  gateway: json['gateway'] as String?,
  fees: (json['fees'] as num?)?.toDouble(),
  netAmount: (json['netAmount'] as num?)?.toDouble(),
  description: json['description'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  processedAt: json['processedAt'] == null
      ? null
      : DateTime.parse(json['processedAt'] as String),
  withdrawalMethod: json['withdrawalMethod'] as String?,
  accountDetails: json['accountDetails'] == null
      ? null
      : AccountDetails.fromJson(json['accountDetails'] as Map<String, dynamic>),
  paymentInfo: json['paymentInfo'] == null
      ? null
      : PaymentInfo.fromJson(json['paymentInfo'] as Map<String, dynamic>),
  feeBreakdown: json['feeBreakdown'] == null
      ? null
      : FeeBreakdown.fromJson(json['feeBreakdown'] as Map<String, dynamic>),
  processingInfo: json['processingInfo'] == null
      ? null
      : ProcessingInfo.fromJson(json['processingInfo'] as Map<String, dynamic>),
  nextSteps: (json['nextSteps'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  supportInfo: json['supportInfo'] == null
      ? null
      : SupportInfo.fromJson(json['supportInfo'] as Map<String, dynamic>),
  warnings: (json['warnings'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'type': instance.type,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'gateway': instance.gateway,
      'fees': instance.fees,
      'netAmount': instance.netAmount,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'processedAt': instance.processedAt?.toIso8601String(),
      'withdrawalMethod': instance.withdrawalMethod,
      'accountDetails': instance.accountDetails,
      'paymentInfo': instance.paymentInfo,
      'feeBreakdown': instance.feeBreakdown,
      'processingInfo': instance.processingInfo,
      'nextSteps': instance.nextSteps,
      'supportInfo': instance.supportInfo,
      'warnings': instance.warnings,
    };

PaymentInfo _$PaymentInfoFromJson(Map<String, dynamic> json) => PaymentInfo(
  paymentType: json['paymentType'] as String,
  instructions: json['instructions'] as String,
  estimatedConfirmation: json['estimatedConfirmation'] as String,
  mobileProvider: json['mobileProvider'] as String?,
);

Map<String, dynamic> _$PaymentInfoToJson(PaymentInfo instance) =>
    <String, dynamic>{
      'paymentType': instance.paymentType,
      'instructions': instance.instructions,
      'estimatedConfirmation': instance.estimatedConfirmation,
      'mobileProvider': instance.mobileProvider,
    };

FeeBreakdown _$FeeBreakdownFromJson(Map<String, dynamic> json) => FeeBreakdown(
  depositAmount: (json['depositAmount'] as num).toDouble(),
  baseFee: (json['baseFee'] as num).toDouble(),
  percentageFee: (json['percentageFee'] as num).toDouble(),
  urgentFee: (json['urgentFee'] as num).toDouble(),
  totalFees: (json['totalFees'] as num).toDouble(),
  netCredit: (json['netCredit'] as num).toDouble(),
  withdrawalAmount: (json['withdrawalAmount'] as num?)?.toDouble(),
  netWithdrawal: (json['netWithdrawal'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FeeBreakdownToJson(FeeBreakdown instance) =>
    <String, dynamic>{
      'depositAmount': instance.depositAmount,
      'baseFee': instance.baseFee,
      'percentageFee': instance.percentageFee,
      'urgentFee': instance.urgentFee,
      'totalFees': instance.totalFees,
      'netCredit': instance.netCredit,
      'withdrawalAmount': instance.withdrawalAmount,
      'netWithdrawal': instance.netWithdrawal,
    };

ProcessingInfo _$ProcessingInfoFromJson(Map<String, dynamic> json) =>
    ProcessingInfo(
      estimatedTime: json['estimatedTime'] as String,
      businessDaysOnly: json['businessDaysOnly'] as bool,
      priority: json['priority'] as String,
      riskLevel: json['riskLevel'] as String,
    );

Map<String, dynamic> _$ProcessingInfoToJson(ProcessingInfo instance) =>
    <String, dynamic>{
      'estimatedTime': instance.estimatedTime,
      'businessDaysOnly': instance.businessDaysOnly,
      'priority': instance.priority,
      'riskLevel': instance.riskLevel,
    };

SupportInfo _$SupportInfoFromJson(Map<String, dynamic> json) => SupportInfo(
  trackingId: json['trackingId'] as String,
  supportEmail: json['supportEmail'] as String,
  helpUrl: json['helpUrl'] as String,
  canCancel: json['canCancel'] as bool?,
  cancelDeadline: json['cancelDeadline'] == null
      ? null
      : DateTime.parse(json['cancelDeadline'] as String),
);

Map<String, dynamic> _$SupportInfoToJson(SupportInfo instance) =>
    <String, dynamic>{
      'trackingId': instance.trackingId,
      'supportEmail': instance.supportEmail,
      'helpUrl': instance.helpUrl,
      'canCancel': instance.canCancel,
      'cancelDeadline': instance.cancelDeadline?.toIso8601String(),
    };
