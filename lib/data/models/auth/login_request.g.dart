// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
  userType: json['userType'] as String? ?? 'user',
  deviceId: json['deviceId'] as String,
  rememberMe: json['rememberMe'] as bool? ?? true,
  twoFactorToken: json['twoFactorToken'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'userType': instance.userType,
      'deviceId': instance.deviceId,
      'rememberMe': instance.rememberMe,
      'twoFactorToken': instance.twoFactorToken,
    };
