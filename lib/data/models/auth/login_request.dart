import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final String userType;
  final String deviceId;
  final bool rememberMe;
  final String? twoFactorToken;

  LoginRequest({
    required this.email,
    required this.password,
    this.userType = 'user',
    required this.deviceId,
    this.rememberMe = true,
    this.twoFactorToken,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
