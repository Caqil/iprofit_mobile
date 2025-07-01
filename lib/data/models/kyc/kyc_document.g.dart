// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KYCDocument _$KYCDocumentFromJson(Map<String, dynamic> json) => KYCDocument(
  type: json['type'] as String,
  number: json['number'] as String?,
  url: json['url'] as String,
  filename: json['filename'] as String?,
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  issueDate: json['issueDate'] == null
      ? null
      : DateTime.parse(json['issueDate'] as String),
  status: json['status'] as String,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$KYCDocumentToJson(KYCDocument instance) =>
    <String, dynamic>{
      'type': instance.type,
      'number': instance.number,
      'url': instance.url,
      'filename': instance.filename,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'issueDate': instance.issueDate?.toIso8601String(),
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
    };
