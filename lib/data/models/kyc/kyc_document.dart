import 'package:json_annotation/json_annotation.dart';

part 'kyc_document.g.dart';

@JsonSerializable()
class KYCDocument {
  final String type;
  final String? number;
  final String url;
  final String? filename;
  final DateTime? expiryDate;
  final DateTime? issueDate;
  final String status;
  final String? rejectionReason;

  KYCDocument({
    required this.type,
    this.number,
    required this.url,
    this.filename,
    this.expiryDate,
    this.issueDate,
    required this.status,
    this.rejectionReason,
  });

  factory KYCDocument.fromJson(Map<String, dynamic> json) =>
      _$KYCDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$KYCDocumentToJson(this);
}
