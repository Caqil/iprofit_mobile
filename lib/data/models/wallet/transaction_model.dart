import 'package:iprofit_mobile/data/models/wallet/withdrawal_request.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final String id;
  final String transactionId;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String? gateway;
  final double? fees;
  final double? netAmount;
  final String? description;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? withdrawalMethod;
  final AccountDetails? accountDetails;
  final PaymentInfo? paymentInfo;
  final FeeBreakdown? feeBreakdown;
  final ProcessingInfo? processingInfo;
  final List<String>? nextSteps;
  final SupportInfo? supportInfo;
  final List<String>? warnings;

  TransactionModel({
    required this.id,
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.gateway,
    this.fees,
    this.netAmount,
    this.description,
    required this.createdAt,
    this.processedAt,
    this.withdrawalMethod,
    this.accountDetails,
    this.paymentInfo,
    this.feeBreakdown,
    this.processingInfo,
    this.nextSteps,
    this.supportInfo,
    this.warnings,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}

@JsonSerializable()
class PaymentInfo {
  final String paymentType;
  final String instructions;
  final String estimatedConfirmation;
  final String? mobileProvider;

  PaymentInfo({
    required this.paymentType,
    required this.instructions,
    required this.estimatedConfirmation,
    this.mobileProvider,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) =>
      _$PaymentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInfoToJson(this);
}

@JsonSerializable()
class FeeBreakdown {
  final double depositAmount;
  final double baseFee;
  final double percentageFee;
  final double urgentFee;
  final double totalFees;
  final double netCredit;
  final double? withdrawalAmount;
  final double? netWithdrawal;

  FeeBreakdown({
    required this.depositAmount,
    required this.baseFee,
    required this.percentageFee,
    required this.urgentFee,
    required this.totalFees,
    required this.netCredit,
    this.withdrawalAmount,
    this.netWithdrawal,
  });

  factory FeeBreakdown.fromJson(Map<String, dynamic> json) =>
      _$FeeBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$FeeBreakdownToJson(this);
}

@JsonSerializable()
class ProcessingInfo {
  final String estimatedTime;
  final bool businessDaysOnly;
  final String priority;
  final String riskLevel;

  ProcessingInfo({
    required this.estimatedTime,
    required this.businessDaysOnly,
    required this.priority,
    required this.riskLevel,
  });

  factory ProcessingInfo.fromJson(Map<String, dynamic> json) =>
      _$ProcessingInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessingInfoToJson(this);
}

@JsonSerializable()
class SupportInfo {
  final String trackingId;
  final String supportEmail;
  final String helpUrl;
  final bool? canCancel;
  final DateTime? cancelDeadline;

  SupportInfo({
    required this.trackingId,
    required this.supportEmail,
    required this.helpUrl,
    this.canCancel,
    this.cancelDeadline,
  });

  factory SupportInfo.fromJson(Map<String, dynamic> json) =>
      _$SupportInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SupportInfoToJson(this);
}
