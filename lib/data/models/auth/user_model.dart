import 'package:json_annotation/json_annotation.dart';
import 'register_request.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String email;
  final String phone;
  final double balance;
  final String status;
  final String kycStatus;
  final String referralCode;
  final String? referredBy;
  final String? profilePicture;
  final String? dateOfBirth;
  final Address? address;
  final bool emailVerified;
  final bool phoneVerified;
  final bool twoFactorEnabled;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PlanInfo? plan;
  final UserPreferences? preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.balance,
    required this.status,
    required this.kycStatus,
    required this.referralCode,
    this.referredBy,
    this.profilePicture,
    this.dateOfBirth,
    this.address,
    required this.emailVerified,
    required this.phoneVerified,
    required this.twoFactorEnabled,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class PlanInfo {
  final String id;
  final String name;
  final String type;
  final double dailyProfit;
  final double monthlyProfit;
  final List<String> features;

  PlanInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.dailyProfit,
    required this.monthlyProfit,
    required this.features,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) =>
      _$PlanInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PlanInfoToJson(this);
}

@JsonSerializable()
class UserPreferences {
  final NotificationPreferences? notifications;
  final PrivacyPreferences? privacy;
  final AppPreferences? app;
  final SecurityPreferences? security;

  UserPreferences({this.notifications, this.privacy, this.app, this.security});

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

@JsonSerializable()
class NotificationPreferences {
  final NotificationChannelSettings? email;
  final NotificationChannelSettings? push;
  final NotificationChannelSettings? sms;
  final NotificationChannelSettings? inApp;

  NotificationPreferences({this.email, this.push, this.sms, this.inApp});

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);
}

@JsonSerializable()
class NotificationChannelSettings {
  final bool kyc;
  final bool transactions;
  final bool loans;
  final bool referrals;
  final bool tasks;
  final bool system;
  final bool marketing;
  final bool security;

  NotificationChannelSettings({
    required this.kyc,
    required this.transactions,
    required this.loans,
    required this.referrals,
    required this.tasks,
    required this.system,
    required this.marketing,
    required this.security,
  });

  factory NotificationChannelSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationChannelSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationChannelSettingsToJson(this);
}

@JsonSerializable()
class PrivacyPreferences {
  final String profileVisibility;
  final bool showBalance;
  final bool showTransactions;
  final bool showReferrals;
  final bool allowContact;

  PrivacyPreferences({
    required this.profileVisibility,
    required this.showBalance,
    required this.showTransactions,
    required this.showReferrals,
    required this.allowContact,
  });

  factory PrivacyPreferences.fromJson(Map<String, dynamic> json) =>
      _$PrivacyPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$PrivacyPreferencesToJson(this);
}

@JsonSerializable()
class AppPreferences {
  final String language;
  final String currency;
  final String theme;
  final bool biometricLogin;
  final bool autoLock;
  final int autoLockDuration;
  final bool soundEnabled;
  final bool vibrationEnabled;

  AppPreferences({
    required this.language,
    required this.currency,
    required this.theme,
    required this.biometricLogin,
    required this.autoLock,
    required this.autoLockDuration,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory AppPreferences.fromJson(Map<String, dynamic> json) =>
      _$AppPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$AppPreferencesToJson(this);
}

@JsonSerializable()
class SecurityPreferences {
  final bool twoFactorEnabled;
  final bool loginNotifications;
  final bool suspiciousActivityAlerts;
  final bool deviceRegistrationNotifications;
  final int sessionTimeout;

  SecurityPreferences({
    required this.twoFactorEnabled,
    required this.loginNotifications,
    required this.suspiciousActivityAlerts,
    required this.deviceRegistrationNotifications,
    required this.sessionTimeout,
  });

  factory SecurityPreferences.fromJson(Map<String, dynamic> json) =>
      _$SecurityPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityPreferencesToJson(this);
}
