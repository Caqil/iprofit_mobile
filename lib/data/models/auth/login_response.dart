import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final UserModel user;
  final TokenData tokens;

  LoginResponse({
    required this.user,
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class TokenData {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  TokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) =>
      _$TokenDataFromJson(json);

  Map<String, dynamic> toJson() => _$TokenDataToJson(this);
}