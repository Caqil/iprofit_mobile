// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'read': instance.read,
      'createdAt': instance.createdAt.toIso8601String(),
      'data': instance.data,
      'imageUrl': instance.imageUrl,
      'actionUrl': instance.actionUrl,
    };

FCMTokenRequest _$FCMTokenRequestFromJson(Map<String, dynamic> json) =>
    FCMTokenRequest(
      fcmToken: json['fcmToken'] as String,
      deviceId: json['deviceId'] as String,
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String?,
      osVersion: json['osVersion'] as String?,
      deviceModel: json['deviceModel'] as String?,
      deviceBrand: json['deviceBrand'] as String?,
    );

Map<String, dynamic> _$FCMTokenRequestToJson(FCMTokenRequest instance) =>
    <String, dynamic>{
      'fcmToken': instance.fcmToken,
      'deviceId': instance.deviceId,
      'platform': instance.platform,
      'appVersion': instance.appVersion,
      'osVersion': instance.osVersion,
      'deviceModel': instance.deviceModel,
      'deviceBrand': instance.deviceBrand,
    };
