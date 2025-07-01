import 'package:json_annotation/json_annotation.dart';

part 'device_info.g.dart';

@JsonSerializable()
class DeviceInfo {
  final String deviceId;
  final String fingerprint;
  final String platform;
  final String? model;
  final String? brand;
  final String? manufacturer;
  final String? osVersion;
  final String? appVersion;
  final Map<String, dynamic>? additionalInfo;
  final DateTime timestamp;

  DeviceInfo({
    required this.deviceId,
    required this.fingerprint,
    required this.platform,
    this.model,
    this.brand,
    this.manufacturer,
    this.osVersion,
    this.appVersion,
    this.additionalInfo,
    required this.timestamp,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}

