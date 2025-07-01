// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCategory _$TaskCategoryFromJson(Map<String, dynamic> json) => TaskCategory(
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
  totalReward: (json['totalReward'] as num).toDouble(),
);

Map<String, dynamic> _$TaskCategoryToJson(TaskCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'count': instance.count,
      'totalReward': instance.totalReward,
    };
