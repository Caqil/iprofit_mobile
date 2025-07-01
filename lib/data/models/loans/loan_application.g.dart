// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoanApplication _$LoanApplicationFromJson(Map<String, dynamic> json) =>
    LoanApplication(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      purpose: json['purpose'] as String,
      tenure: (json['tenure'] as num).toInt(),
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      employmentStatus: json['employmentStatus'] as String,
      employmentDetails: EmploymentDetails.fromJson(
        json['employmentDetails'] as Map<String, dynamic>,
      ),
      personalDetails: PersonalDetails.fromJson(
        json['personalDetails'] as Map<String, dynamic>,
      ),
      financialDetails: FinancialDetails.fromJson(
        json['financialDetails'] as Map<String, dynamic>,
      ),
      documents: (json['documents'] as List<dynamic>)
          .map((e) => DocumentUpload.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LoanApplicationToJson(LoanApplication instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'purpose': instance.purpose,
      'tenure': instance.tenure,
      'monthlyIncome': instance.monthlyIncome,
      'employmentStatus': instance.employmentStatus,
      'employmentDetails': instance.employmentDetails,
      'personalDetails': instance.personalDetails,
      'financialDetails': instance.financialDetails,
      'documents': instance.documents,
    };

EmploymentDetails _$EmploymentDetailsFromJson(Map<String, dynamic> json) =>
    EmploymentDetails(
      companyName: json['companyName'] as String,
      position: json['position'] as String,
      experience: json['experience'] as String,
      workAddress: json['workAddress'] as String,
    );

Map<String, dynamic> _$EmploymentDetailsToJson(EmploymentDetails instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'position': instance.position,
      'experience': instance.experience,
      'workAddress': instance.workAddress,
    };

PersonalDetails _$PersonalDetailsFromJson(Map<String, dynamic> json) =>
    PersonalDetails(
      fullName: json['fullName'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      maritalStatus: json['maritalStatus'] as String,
      education: json['education'] as String,
      dependents: (json['dependents'] as num).toInt(),
    );

Map<String, dynamic> _$PersonalDetailsToJson(PersonalDetails instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'dateOfBirth': instance.dateOfBirth,
      'maritalStatus': instance.maritalStatus,
      'education': instance.education,
      'dependents': instance.dependents,
    };

FinancialDetails _$FinancialDetailsFromJson(Map<String, dynamic> json) =>
    FinancialDetails(
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      monthlyExpenses: (json['monthlyExpenses'] as num).toDouble(),
      otherLoans: json['otherLoans'] as List<dynamic>,
      creditScore: (json['creditScore'] as num).toInt(),
    );

Map<String, dynamic> _$FinancialDetailsToJson(FinancialDetails instance) =>
    <String, dynamic>{
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'monthlyExpenses': instance.monthlyExpenses,
      'otherLoans': instance.otherLoans,
      'creditScore': instance.creditScore,
    };

DocumentUpload _$DocumentUploadFromJson(Map<String, dynamic> json) =>
    DocumentUpload(
      type: json['type'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
    );

Map<String, dynamic> _$DocumentUploadToJson(DocumentUpload instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'filename': instance.filename,
    };
