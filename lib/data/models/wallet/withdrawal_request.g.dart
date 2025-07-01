// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WithdrawalRequest _$WithdrawalRequestFromJson(Map<String, dynamic> json) =>
    WithdrawalRequest(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      withdrawalMethod: json['withdrawalMethod'] as String,
      accountDetails: AccountDetails.fromJson(
        json['accountDetails'] as Map<String, dynamic>,
      ),
      urgentWithdrawal: json['urgentWithdrawal'] as bool? ?? false,
      deviceId: json['deviceId'] as String,
      twoFactorToken: json['twoFactorToken'] as String?,
    );

Map<String, dynamic> _$WithdrawalRequestToJson(WithdrawalRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'withdrawalMethod': instance.withdrawalMethod,
      'accountDetails': instance.accountDetails,
      'urgentWithdrawal': instance.urgentWithdrawal,
      'deviceId': instance.deviceId,
      'twoFactorToken': instance.twoFactorToken,
    };

AccountDetails _$AccountDetailsFromJson(Map<String, dynamic> json) =>
    AccountDetails(
      accountNumber: json['accountNumber'] as String?,
      routingNumber: json['routingNumber'] as String?,
      bankName: json['bankName'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      bankAddress: json['bankAddress'] as String?,
      walletAddress: json['walletAddress'] as String?,
      cryptoCurrency: json['cryptoCurrency'] as String?,
      network: json['network'] as String?,
      memo: json['memo'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      provider: json['provider'] as String?,
      accountType: json['accountType'] as String?,
    );

Map<String, dynamic> _$AccountDetailsToJson(AccountDetails instance) =>
    <String, dynamic>{
      'accountNumber': instance.accountNumber,
      'routingNumber': instance.routingNumber,
      'bankName': instance.bankName,
      'accountHolderName': instance.accountHolderName,
      'bankAddress': instance.bankAddress,
      'walletAddress': instance.walletAddress,
      'cryptoCurrency': instance.cryptoCurrency,
      'network': instance.network,
      'memo': instance.memo,
      'mobileNumber': instance.mobileNumber,
      'provider': instance.provider,
      'accountType': instance.accountType,
    };
