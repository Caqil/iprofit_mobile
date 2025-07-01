import 'package:json_annotation/json_annotation.dart';

part 'task_category.g.dart';

@JsonSerializable()
class TaskCategory {
  final String name;
  final int count;
  final double totalReward;

  TaskCategory({
    required this.name,
    required this.count,
    required this.totalReward,
  });

  factory TaskCategory.fromJson(Map<String, dynamic> json) =>
      _$TaskCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCategoryToJson(this);
}
