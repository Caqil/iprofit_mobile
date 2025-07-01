// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
  deviceId: json['deviceId'] as String,
  fingerprint: json['fingerprint'] as String,
  platform: json['platform'] as String,
  model: json['model'] as String?,
  brand: json['brand'] as String?,
  manufacturer: json['manufacturer'] as String?,
  osVersion: json['osVersion'] as String?,
  appVersion: json['appVersion'] as String?,
  additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'fingerprint': instance.fingerprint,
      'platform': instance.platform,
      'model': instance.model,
      'brand': instance.brand,
      'manufacturer': instance.manufacturer,
      'osVersion': instance.osVersion,
      'appVersion': instance.appVersion,
      'additionalInfo': instance.additionalInfo,
      'timestamp': instance.timestamp.toIso8601String(),
    };
