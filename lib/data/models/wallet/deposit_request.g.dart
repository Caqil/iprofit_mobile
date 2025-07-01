// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deposit_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepositRequest _$DepositRequestFromJson(Map<String, dynamic> json) =>
    DepositRequest(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      gateway: json['gateway'] as String,
      depositMethod: json['depositMethod'] as String,
      deviceId: json['deviceId'] as String,
      gatewayData: json['gatewayData'] == null
          ? null
          : GatewayData.fromJson(json['gatewayData'] as Map<String, dynamic>),
      acceptTerms: json['acceptTerms'] as bool? ?? true,
      confirmAmount: json['confirmAmount'] as bool? ?? true,
    );

Map<String, dynamic> _$DepositRequestToJson(DepositRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'gateway': instance.gateway,
      'depositMethod': instance.depositMethod,
      'deviceId': instance.deviceId,
      'gatewayData': instance.gatewayData,
      'acceptTerms': instance.acceptTerms,
      'confirmAmount': instance.confirmAmount,
    };

GatewayData _$GatewayDataFromJson(Map<String, dynamic> json) => GatewayData(
  cryptoCurrency: json['cryptoCurrency'] as String?,
  urgentProcessing: json['urgentProcessing'] as bool?,
  walletAddress: json['walletAddress'] as String?,
  mobileProvider: json['mobileProvider'] as String?,
  mobileNumber: json['mobileNumber'] as String?,
  bankName: json['bankName'] as String?,
  accountNumber: json['accountNumber'] as String?,
  routingNumber: json['routingNumber'] as String?,
  referenceNumber: json['referenceNumber'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$GatewayDataToJson(GatewayData instance) =>
    <String, dynamic>{
      'cryptoCurrency': instance.cryptoCurrency,
      'urgentProcessing': instance.urgentProcessing,
      'walletAddress': instance.walletAddress,
      'mobileProvider': instance.mobileProvider,
      'mobileNumber': instance.mobileNumber,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'routingNumber': instance.routingNumber,
      'referenceNumber': instance.referenceNumber,
      'notes': instance.notes,
    };
