// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralModel _$ReferralModelFromJson(Map<String, dynamic> json) =>
    ReferralModel(
      id: json['id'] as String,
      refereeName: json['refereeName'] as String,
      refereeEmail: json['refereeEmail'] as String,
      bonusAmount: (json['bonusAmount'] as num).toDouble(),
      profitBonus: (json['profitBonus'] as num).toDouble(),
      totalBonus: (json['totalBonus'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReferralModelToJson(ReferralModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'refereeName': instance.refereeName,
      'refereeEmail': instance.refereeEmail,
      'bonusAmount': instance.bonusAmount,
      'profitBonus': instance.profitBonus,
      'totalBonus': instance.totalBonus,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ReferralOverview _$ReferralOverviewFromJson(Map<String, dynamic> json) =>
    ReferralOverview(
      totalReferrals: (json['totalReferrals'] as num).toInt(),
      paidReferrals: (json['paidReferrals'] as num).toInt(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      pendingEarnings: (json['pendingEarnings'] as num).toDouble(),
      recentReferrals: (json['recentReferrals'] as List<dynamic>)
          .map((e) => ReferralModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReferralOverviewToJson(ReferralOverview instance) =>
    <String, dynamic>{
      'totalReferrals': instance.totalReferrals,
      'paidReferrals': instance.paidReferrals,
      'totalEarnings': instance.totalEarnings,
      'pendingEarnings': instance.pendingEarnings,
      'recentReferrals': instance.recentReferrals,
    };

ReferralLink _$ReferralLinkFromJson(Map<String, dynamic> json) => ReferralLink(
  referralCode: json['referralCode'] as String,
  referralUrl: json['referralUrl'] as String,
  qrCodeUrl: json['qrCodeUrl'] as String,
  stats: ReferralStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReferralLinkToJson(ReferralLink instance) =>
    <String, dynamic>{
      'referralCode': instance.referralCode,
      'referralUrl': instance.referralUrl,
      'qrCodeUrl': instance.qrCodeUrl,
      'stats': instance.stats,
    };

ReferralStats _$ReferralStatsFromJson(Map<String, dynamic> json) =>
    ReferralStats(
      totalClicks: (json['totalClicks'] as num).toInt(),
      totalSignups: (json['totalSignups'] as num).toInt(),
      activeReferrals: (json['activeReferrals'] as num).toInt(),
      conversionRate: (json['conversionRate'] as num).toDouble(),
    );

Map<String, dynamic> _$ReferralStatsToJson(ReferralStats instance) =>
    <String, dynamic>{
      'totalClicks': instance.totalClicks,
      'totalSignups': instance.totalSignups,
      'activeReferrals': instance.activeReferrals,
      'conversionRate': instance.conversionRate,
    };
