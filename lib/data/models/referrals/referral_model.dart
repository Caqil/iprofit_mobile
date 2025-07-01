import 'package:json_annotation/json_annotation.dart';

part 'referral_model.g.dart';

@JsonSerializable()
class ReferralModel {
  final String id;
  final String refereeName;
  final String refereeEmail;
  final double bonusAmount;
  final double profitBonus;
  final double totalBonus;
  final String status;
  final DateTime createdAt;

  ReferralModel({
    required this.id,
    required this.refereeName,
    required this.refereeEmail,
    required this.bonusAmount,
    required this.profitBonus,
    required this.totalBonus,
    required this.status,
    required this.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) =>
      _$ReferralModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralModelToJson(this);
}

@JsonSerializable()
class ReferralOverview {
  final int totalReferrals;
  final int paidReferrals;
  final double totalEarnings;
  final double pendingEarnings;
  final List<ReferralModel> recentReferrals;

  ReferralOverview({
    required this.totalReferrals,
    required this.paidReferrals,
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.recentReferrals,
  });

  factory ReferralOverview.fromJson(Map<String, dynamic> json) =>
      _$ReferralOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralOverviewToJson(this);
}

@JsonSerializable()
class ReferralLink {
  final String referralCode;
  final String referralUrl;
  final String qrCodeUrl;
  final ReferralStats stats;

  ReferralLink({
    required this.referralCode,
    required this.referralUrl,
    required this.qrCodeUrl,
    required this.stats,
  });

  factory ReferralLink.fromJson(Map<String, dynamic> json) =>
      _$ReferralLinkFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralLinkToJson(this);
}

@JsonSerializable()
class ReferralStats {
  final int totalClicks;
  final int totalSignups;
  final int activeReferrals;
  final double conversionRate;

  ReferralStats({
    required this.totalClicks,
    required this.totalSignups,
    required this.activeReferrals,
    required this.conversionRate,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) =>
      _$ReferralStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralStatsToJson(this);
}
