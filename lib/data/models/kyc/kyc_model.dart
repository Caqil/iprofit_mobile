import 'package:iprofit_mobile/data/models/auth/register_request.dart';
import 'package:json_annotation/json_annotation.dart';
import 'kyc_document.dart';

part 'kyc_model.g.dart';

@JsonSerializable()
class KYCModel {
  final String id;
  final String status;
  final KYCPersonalInfo personalInfo;
  final List<KYCDocument> documents;
  final Address address;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final double completionPercentage;
  final List<String> missingDocuments;
  final List<String> nextSteps;

  KYCModel({
    required this.id,
    required this.status,
    required this.personalInfo,
    required this.documents,
    required this.address,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    required this.completionPercentage,
    required this.missingDocuments,
    required this.nextSteps,
  });

  factory KYCModel.fromJson(Map<String, dynamic> json) =>
      _$KYCModelFromJson(json);

  Map<String, dynamic> toJson() => _$KYCModelToJson(this);
}

@JsonSerializable()
class KYCPersonalInfo {
  final String fullName;
  final String dateOfBirth;
  final String nationality;
  final String occupation;
  final String monthlyIncome;

  KYCPersonalInfo({
    required this.fullName,
    required this.dateOfBirth,
    required this.nationality,
    required this.occupation,
    required this.monthlyIncome,
  });

  factory KYCPersonalInfo.fromJson(Map<String, dynamic> json) =>
      _$KYCPersonalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$KYCPersonalInfoToJson(this);
}

@JsonSerializable()
class KYCSubmission {
  final KYCPersonalInfo personalInfo;
  final List<KYCDocument> documents;
  final Address address;

  KYCSubmission({
    required this.personalInfo,
    required this.documents,
    required this.address,
  });

  factory KYCSubmission.fromJson(Map<String, dynamic> json) =>
      _$KYCSubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$KYCSubmissionToJson(this);
}
