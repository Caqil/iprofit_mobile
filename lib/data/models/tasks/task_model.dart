import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final double rewardAmount;
  final String currency;
  final String timeEstimate;
  final List<String> requirements;
  final String instructions;
  final int maxSubmissions;
  final int currentSubmissions;
  final DateTime? expiresAt;
  final bool isRepeatable;
  final int? cooldownPeriod;
  final TaskMetadata? metadata;
  final UserTaskStatus userStatus;
  final TaskInfo taskInfo;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.rewardAmount,
    required this.currency,
    required this.timeEstimate,
    required this.requirements,
    required this.instructions,
    required this.maxSubmissions,
    required this.currentSubmissions,
    this.expiresAt,
    required this.isRepeatable,
    this.cooldownPeriod,
    this.metadata,
    required this.userStatus,
    required this.taskInfo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}

@JsonSerializable()
class TaskMetadata {
  final String? externalUrl;
  final String? imageUrl;
  final List<String>? tags;

  TaskMetadata({this.externalUrl, this.imageUrl, this.tags});

  factory TaskMetadata.fromJson(Map<String, dynamic> json) =>
      _$TaskMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$TaskMetadataToJson(this);
}

@JsonSerializable()
class UserTaskStatus {
  final bool canSubmit;
  final bool hasSubmitted;
  final String? submissionStatus;
  final DateTime? lastSubmissionDate;
  final DateTime? nextAvailableDate;
  final List<String> reasonsForRestriction;

  UserTaskStatus({
    required this.canSubmit,
    required this.hasSubmitted,
    this.submissionStatus,
    this.lastSubmissionDate,
    this.nextAvailableDate,
    required this.reasonsForRestriction,
  });

  factory UserTaskStatus.fromJson(Map<String, dynamic> json) =>
      _$UserTaskStatusFromJson(json);

  Map<String, dynamic> toJson() => _$UserTaskStatusToJson(this);
}

@JsonSerializable()
class TaskInfo {
  final double completionRate;
  final double averageRating;
  final bool isPopular;
  final int? remainingSlots;
  final String urgency;

  TaskInfo({
    required this.completionRate,
    required this.averageRating,
    required this.isPopular,
    this.remainingSlots,
    required this.urgency,
  });

  factory TaskInfo.fromJson(Map<String, dynamic> json) =>
      _$TaskInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TaskInfoToJson(this);
}
