import 'package:json_annotation/json_annotation.dart';

part 'withdrawal_request.g.dart';

@JsonSerializable()
class WithdrawalRequest {
  final double amount;
  final String currency;
  final String withdrawalMethod;
  final AccountDetails accountDetails;
  final bool urgentWithdrawal;
  final String deviceId;
  final String? twoFactorToken;

  WithdrawalRequest({
    required this.amount,
    required this.currency,
    required this.withdrawalMethod,
    required this.accountDetails,
    this.urgentWithdrawal = false,
    required this.deviceId,
    this.twoFactorToken,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawalRequestToJson(this);
}

@JsonSerializable()
class AccountDetails {
  final String? accountNumber;
  final String? routingNumber;
  final String? bankName;
  final String? accountHolderName;
  final String? bankAddress;
  final String? walletAddress;
  final String? cryptoCurrency;
  final String? network;
  final String? memo;
  final String? mobileNumber;
  final String? provider;
  final String? accountType;

  AccountDetails({
    this.accountNumber,
    this.routingNumber,
    this.bankName,
    this.accountHolderName,
    this.bankAddress,
    this.walletAddress,
    this.cryptoCurrency,
    this.network,
    this.memo,
    this.mobileNumber,
    this.provider,
    this.accountType,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) =>
      _$AccountDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AccountDetailsToJson(this);
}
