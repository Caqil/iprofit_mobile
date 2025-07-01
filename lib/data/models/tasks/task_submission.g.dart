// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskSubmission _$TaskSubmissionFromJson(Map<String, dynamic> json) =>
    TaskSubmission(
      taskId: json['taskId'] as String,
      proof: (json['proof'] as List<dynamic>)
          .map((e) => ProofItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      completionNotes: json['completionNotes'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$TaskSubmissionToJson(TaskSubmission instance) =>
    <String, dynamic>{
      'taskId': instance.taskId,
      'proof': instance.proof,
      'completionNotes': instance.completionNotes,
      'completedAt': instance.completedAt.toIso8601String(),
    };

ProofItem _$ProofItemFromJson(Map<String, dynamic> json) => ProofItem(
  type: json['type'] as String,
  url: json['url'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$ProofItemToJson(ProofItem instance) => <String, dynamic>{
  'type': instance.type,
  'url': instance.url,
  'description': instance.description,
};

TaskSubmissionResponse _$TaskSubmissionResponseFromJson(
  Map<String, dynamic> json,
) => TaskSubmissionResponse(
  id: json['id'] as String,
  taskId: json['taskId'] as String,
  status: json['status'] as String,
  submittedAt: DateTime.parse(json['submittedAt'] as String),
  reviewedAt: json['reviewedAt'] == null
      ? null
      : DateTime.parse(json['reviewedAt'] as String),
  reviewNote: json['reviewNote'] as String?,
  rewardAmount: (json['rewardAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TaskSubmissionResponseToJson(
  TaskSubmissionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'status': instance.status,
  'submittedAt': instance.submittedAt.toIso8601String(),
  'reviewedAt': instance.reviewedAt?.toIso8601String(),
  'reviewNote': instance.reviewNote,
  'rewardAmount': instance.rewardAmount,
};
