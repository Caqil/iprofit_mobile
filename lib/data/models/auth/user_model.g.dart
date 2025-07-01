// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['_id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  balance: (json['balance'] as num).toDouble(),
  status: json['status'] as String,
  kycStatus: json['kycStatus'] as String,
  referralCode: json['referralCode'] as String,
  referredBy: json['referredBy'] as String?,
  profilePicture: json['profilePicture'] as String?,
  dateOfBirth: json['dateOfBirth'] as String?,
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  emailVerified: json['emailVerified'] as bool,
  phoneVerified: json['phoneVerified'] as bool,
  twoFactorEnabled: json['twoFactorEnabled'] as bool,
  lastLogin: json['lastLogin'] == null
      ? null
      : DateTime.parse(json['lastLogin'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  plan: json['plan'] == null
      ? null
      : PlanInfo.fromJson(json['plan'] as Map<String, dynamic>),
  preferences: json['preferences'] == null
      ? null
      : UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'balance': instance.balance,
  'status': instance.status,
  'kycStatus': instance.kycStatus,
  'referralCode': instance.referralCode,
  'referredBy': instance.referredBy,
  'profilePicture': instance.profilePicture,
  'dateOfBirth': instance.dateOfBirth,
  'address': instance.address,
  'emailVerified': instance.emailVerified,
  'phoneVerified': instance.phoneVerified,
  'twoFactorEnabled': instance.twoFactorEnabled,
  'lastLogin': instance.lastLogin?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'plan': instance.plan,
  'preferences': instance.preferences,
};

PlanInfo _$PlanInfoFromJson(Map<String, dynamic> json) => PlanInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  dailyProfit: (json['dailyProfit'] as num).toDouble(),
  monthlyProfit: (json['monthlyProfit'] as num).toDouble(),
  features: (json['features'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PlanInfoToJson(PlanInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'dailyProfit': instance.dailyProfit,
  'monthlyProfit': instance.monthlyProfit,
  'features': instance.features,
};

UserPreferences _$UserPreferencesFromJson(
  Map<String, dynamic> json,
) => UserPreferences(
  notifications: json['notifications'] == null
      ? null
      : NotificationPreferences.fromJson(
          json['notifications'] as Map<String, dynamic>,
        ),
  privacy: json['privacy'] == null
      ? null
      : PrivacyPreferences.fromJson(json['privacy'] as Map<String, dynamic>),
  app: json['app'] == null
      ? null
      : AppPreferences.fromJson(json['app'] as Map<String, dynamic>),
  security: json['security'] == null
      ? null
      : SecurityPreferences.fromJson(json['security'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'privacy': instance.privacy,
      'app': instance.app,
      'security': instance.security,
    };

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => NotificationPreferences(
  email: json['email'] == null
      ? null
      : NotificationChannelSettings.fromJson(
          json['email'] as Map<String, dynamic>,
        ),
  push: json['push'] == null
      ? null
      : NotificationChannelSettings.fromJson(
          json['push'] as Map<String, dynamic>,
        ),
  sms: json['sms'] == null
      ? null
      : NotificationChannelSettings.fromJson(
          json['sms'] as Map<String, dynamic>,
        ),
  inApp: json['inApp'] == null
      ? null
      : NotificationChannelSettings.fromJson(
          json['inApp'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  NotificationPreferences instance,
) => <String, dynamic>{
  'email': instance.email,
  'push': instance.push,
  'sms': instance.sms,
  'inApp': instance.inApp,
};

NotificationChannelSettings _$NotificationChannelSettingsFromJson(
  Map<String, dynamic> json,
) => NotificationChannelSettings(
  kyc: json['kyc'] as bool,
  transactions: json['transactions'] as bool,
  loans: json['loans'] as bool,
  referrals: json['referrals'] as bool,
  tasks: json['tasks'] as bool,
  system: json['system'] as bool,
  marketing: json['marketing'] as bool,
  security: json['security'] as bool,
);

Map<String, dynamic> _$NotificationChannelSettingsToJson(
  NotificationChannelSettings instance,
) => <String, dynamic>{
  'kyc': instance.kyc,
  'transactions': instance.transactions,
  'loans': instance.loans,
  'referrals': instance.referrals,
  'tasks': instance.tasks,
  'system': instance.system,
  'marketing': instance.marketing,
  'security': instance.security,
};

PrivacyPreferences _$PrivacyPreferencesFromJson(Map<String, dynamic> json) =>
    PrivacyPreferences(
      profileVisibility: json['profileVisibility'] as String,
      showBalance: json['showBalance'] as bool,
      showTransactions: json['showTransactions'] as bool,
      showReferrals: json['showReferrals'] as bool,
      allowContact: json['allowContact'] as bool,
    );

Map<String, dynamic> _$PrivacyPreferencesToJson(PrivacyPreferences instance) =>
    <String, dynamic>{
      'profileVisibility': instance.profileVisibility,
      'showBalance': instance.showBalance,
      'showTransactions': instance.showTransactions,
      'showReferrals': instance.showReferrals,
      'allowContact': instance.allowContact,
    };

AppPreferences _$AppPreferencesFromJson(Map<String, dynamic> json) =>
    AppPreferences(
      language: json['language'] as String,
      currency: json['currency'] as String,
      theme: json['theme'] as String,
      biometricLogin: json['biometricLogin'] as bool,
      autoLock: json['autoLock'] as bool,
      autoLockDuration: (json['autoLockDuration'] as num).toInt(),
      soundEnabled: json['soundEnabled'] as bool,
      vibrationEnabled: json['vibrationEnabled'] as bool,
    );

Map<String, dynamic> _$AppPreferencesToJson(AppPreferences instance) =>
    <String, dynamic>{
      'language': instance.language,
      'currency': instance.currency,
      'theme': instance.theme,
      'biometricLogin': instance.biometricLogin,
      'autoLock': instance.autoLock,
      'autoLockDuration': instance.autoLockDuration,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
    };

SecurityPreferences _$SecurityPreferencesFromJson(Map<String, dynamic> json) =>
    SecurityPreferences(
      twoFactorEnabled: json['twoFactorEnabled'] as bool,
      loginNotifications: json['loginNotifications'] as bool,
      suspiciousActivityAlerts: json['suspiciousActivityAlerts'] as bool,
      deviceRegistrationNotifications:
          json['deviceRegistrationNotifications'] as bool,
      sessionTimeout: (json['sessionTimeout'] as num).toInt(),
    );

Map<String, dynamic> _$SecurityPreferencesToJson(
  SecurityPreferences instance,
) => <String, dynamic>{
  'twoFactorEnabled': instance.twoFactorEnabled,
  'loginNotifications': instance.loginNotifications,
  'suspiciousActivityAlerts': instance.suspiciousActivityAlerts,
  'deviceRegistrationNotifications': instance.deviceRegistrationNotifications,
  'sessionTimeout': instance.sessionTimeout,
};
