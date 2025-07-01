import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String deviceId;
  final String? planId;
  final String? referralCode;
  final String? dateOfBirth;
  final Address? address;
  final bool acceptTerms;
  final bool acceptPrivacy;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.deviceId,
    this.planId,
    this.referralCode,
    this.dateOfBirth,
    this.address,
    this.acceptTerms = true,
    this.acceptPrivacy = true,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;

  Address({this.street, this.city, this.state, this.country, this.zipCode});

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
