import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data,
    this.imageUrl,
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable()
class FCMTokenRequest {
  final String fcmToken;
  final String deviceId;
  final String platform;
  final String? appVersion;
  final String? osVersion;
  final String? deviceModel;
  final String? deviceBrand;

  FCMTokenRequest({
    required this.fcmToken,
    required this.deviceId,
    required this.platform,
    this.appVersion,
    this.osVersion,
    this.deviceModel,
    this.deviceBrand,
  });

  factory FCMTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$FCMTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FCMTokenRequestToJson(this);
}
