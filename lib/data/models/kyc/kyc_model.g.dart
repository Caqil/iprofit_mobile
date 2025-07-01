// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KYCModel _$KYCModelFromJson(Map<String, dynamic> json) => KYCModel(
  id: json['id'] as String,
  status: json['status'] as String,
  personalInfo: KYCPersonalInfo.fromJson(
    json['personalInfo'] as Map<String, dynamic>,
  ),
  documents: (json['documents'] as List<dynamic>)
      .map((e) => KYCDocument.fromJson(e as Map<String, dynamic>))
      .toList(),
  address: Address.fromJson(json['address'] as Map<String, dynamic>),
  submittedAt: json['submittedAt'] == null
      ? null
      : DateTime.parse(json['submittedAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  rejectionReason: json['rejectionReason'] as String?,
  completionPercentage: (json['completionPercentage'] as num).toDouble(),
  missingDocuments: (json['missingDocuments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  nextSteps: (json['nextSteps'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$KYCModelToJson(KYCModel instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'personalInfo': instance.personalInfo,
  'documents': instance.documents,
  'address': instance.address,
  'submittedAt': instance.submittedAt?.toIso8601String(),
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'rejectionReason': instance.rejectionReason,
  'completionPercentage': instance.completionPercentage,
  'missingDocuments': instance.missingDocuments,
  'nextSteps': instance.nextSteps,
};

KYCPersonalInfo _$KYCPersonalInfoFromJson(Map<String, dynamic> json) =>
    KYCPersonalInfo(
      fullName: json['fullName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      nationality: json['nationality'] as String,
      occupation: json['occupation'] as String,
      monthlyIncome: json['monthlyIncome'] as String,
    );

Map<String, dynamic> _$KYCPersonalInfoToJson(KYCPersonalInfo instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'dateOfBirth': instance.dateOfBirth,
      'nationality': instance.nationality,
      'occupation': instance.occupation,
      'monthlyIncome': instance.monthlyIncome,
    };

KYCSubmission _$KYCSubmissionFromJson(Map<String, dynamic> json) =>
    KYCSubmission(
      personalInfo: KYCPersonalInfo.fromJson(
        json['personalInfo'] as Map<String, dynamic>,
      ),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => KYCDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$KYCSubmissionToJson(KYCSubmission instance) =>
    <String, dynamic>{
      'personalInfo': instance.personalInfo,
      'documents': instance.documents,
      'address': instance.address,
    };
