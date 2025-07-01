import 'package:json_annotation/json_annotation.dart';

part 'task_submission.g.dart';

@JsonSerializable()
class TaskSubmission {
  final String taskId;
  final List<ProofItem> proof;
  final String completionNotes;
  final DateTime completedAt;

  TaskSubmission({
    required this.taskId,
    required this.proof,
    required this.completionNotes,
    required this.completedAt,
  });

  factory TaskSubmission.fromJson(Map<String, dynamic> json) =>
      _$TaskSubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$TaskSubmissionToJson(this);
}

@JsonSerializable()
class ProofItem {
  final String type;
  final String url;
  final String description;

  ProofItem({required this.type, required this.url, required this.description});

  factory ProofItem.fromJson(Map<String, dynamic> json) =>
      _$ProofItemFromJson(json);

  Map<String, dynamic> toJson() => _$ProofItemToJson(this);
}

@JsonSerializable()
class TaskSubmissionResponse {
  final String id;
  final String taskId;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final double? rewardAmount;

  TaskSubmissionResponse({
    required this.id,
    required this.taskId,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNote,
    this.rewardAmount,
  });

  factory TaskSubmissionResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskSubmissionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TaskSubmissionResponseToJson(this);
}
