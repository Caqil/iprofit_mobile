import 'package:json_annotation/json_annotation.dart';

part 'loan_application.g.dart';

@JsonSerializable()
class LoanApplication {
  final double amount;
  final String currency;
  final String purpose;
  final int tenure;
  final double monthlyIncome;
  final String employmentStatus;
  final EmploymentDetails employmentDetails;
  final PersonalDetails personalDetails;
  final FinancialDetails financialDetails;
  final List<DocumentUpload> documents;

  LoanApplication({
    required this.amount,
    required this.currency,
    required this.purpose,
    required this.tenure,
    required this.monthlyIncome,
    required this.employmentStatus,
    required this.employmentDetails,
    required this.personalDetails,
    required this.financialDetails,
    required this.documents,
  });

  factory LoanApplication.fromJson(Map<String, dynamic> json) =>
      _$LoanApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$LoanApplicationToJson(this);
}

@JsonSerializable()
class EmploymentDetails {
  final String companyName;
  final String position;
  final String experience;
  final String workAddress;

  EmploymentDetails({
    required this.companyName,
    required this.position,
    required this.experience,
    required this.workAddress,
  });

  factory EmploymentDetails.fromJson(Map<String, dynamic> json) =>
      _$EmploymentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$EmploymentDetailsToJson(this);
}

@JsonSerializable()
class PersonalDetails {
  final String fullName;
  final String dateOfBirth;
  final String maritalStatus;
  final String education;
  final int dependents;

  PersonalDetails({
    required this.fullName,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.education,
    required this.dependents,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) =>
      _$PersonalDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalDetailsToJson(this);
}

@JsonSerializable()
class FinancialDetails {
  final String bankName;
  final String accountNumber;
  final double monthlyExpenses;
  final List<dynamic> otherLoans;
  final int creditScore;

  FinancialDetails({
    required this.bankName,
    required this.accountNumber,
    required this.monthlyExpenses,
    required this.otherLoans,
    required this.creditScore,
  });

  factory FinancialDetails.fromJson(Map<String, dynamic> json) =>
      _$FinancialDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialDetailsToJson(this);
}

@JsonSerializable()
class DocumentUpload {
  final String type;
  final String url;
  final String filename;

  DocumentUpload({
    required this.type,
    required this.url,
    required this.filename,
  });

  factory DocumentUpload.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentUploadToJson(this);
}
