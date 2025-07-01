import 'package:json_annotation/json_annotation.dart';

part 'deposit_request.g.dart';

@JsonSerializable()
class DepositRequest {
  final double amount;
  final String currency;
  final String gateway;
  final String depositMethod;
  final String deviceId;
  final GatewayData? gatewayData;
  final bool acceptTerms;
  final bool confirmAmount;

  DepositRequest({
    required this.amount,
    required this.currency,
    required this.gateway,
    required this.depositMethod,
    required this.deviceId,
    this.gatewayData,
    this.acceptTerms = true,
    this.confirmAmount = true,
  });

  factory DepositRequest.fromJson(Map<String, dynamic> json) =>
      _$DepositRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DepositRequestToJson(this);
}

@JsonSerializable()
class GatewayData {
  final String? cryptoCurrency;
  final bool? urgentProcessing;
  final String? walletAddress;
  final String? mobileProvider;
  final String? mobileNumber;
  final String? bankName;
  final String? accountNumber;
  final String? routingNumber;
  final String? referenceNumber;
  final String? notes;

  GatewayData({
    this.cryptoCurrency,
    this.urgentProcessing,
    this.walletAddress,
    this.mobileProvider,
    this.mobileNumber,
    this.bankName,
    this.accountNumber,
    this.routingNumber,
    this.referenceNumber,
    this.notes,
  });

  factory GatewayData.fromJson(Map<String, dynamic> json) =>
      _$GatewayDataFromJson(json);

  Map<String, dynamic> toJson() => _$GatewayDataToJson(this);
}
