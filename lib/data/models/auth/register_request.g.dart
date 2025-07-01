// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
      deviceId: json['deviceId'] as String,
      planId: json['planId'] as String?,
      referralCode: json['referralCode'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      acceptTerms: json['acceptTerms'] as bool? ?? true,
      acceptPrivacy: json['acceptPrivacy'] as bool? ?? true,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
      'deviceId': instance.deviceId,
      'planId': instance.planId,
      'referralCode': instance.referralCode,
      'dateOfBirth': instance.dateOfBirth,
      'address': instance.address,
      'acceptTerms': instance.acceptTerms,
      'acceptPrivacy': instance.acceptPrivacy,
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  street: json['street'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
  zipCode: json['zipCode'] as String?,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'street': instance.street,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
  'zipCode': instance.zipCode,
};
