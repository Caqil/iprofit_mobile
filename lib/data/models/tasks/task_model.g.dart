// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  difficulty: json['difficulty'] as String,
  rewardAmount: (json['rewardAmount'] as num).toDouble(),
  currency: json['currency'] as String,
  timeEstimate: json['timeEstimate'] as String,
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  instructions: json['instructions'] as String,
  maxSubmissions: (json['maxSubmissions'] as num).toInt(),
  currentSubmissions: (json['currentSubmissions'] as num).toInt(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  isRepeatable: json['isRepeatable'] as bool,
  cooldownPeriod: (json['cooldownPeriod'] as num?)?.toInt(),
  metadata: json['metadata'] == null
      ? null
      : TaskMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
  userStatus: UserTaskStatus.fromJson(
    json['userStatus'] as Map<String, dynamic>,
  ),
  taskInfo: TaskInfo.fromJson(json['taskInfo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'difficulty': instance.difficulty,
  'rewardAmount': instance.rewardAmount,
  'currency': instance.currency,
  'timeEstimate': instance.timeEstimate,
  'requirements': instance.requirements,
  'instructions': instance.instructions,
  'maxSubmissions': instance.maxSubmissions,
  'currentSubmissions': instance.currentSubmissions,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'isRepeatable': instance.isRepeatable,
  'cooldownPeriod': instance.cooldownPeriod,
  'metadata': instance.metadata,
  'userStatus': instance.userStatus,
  'taskInfo': instance.taskInfo,
};

TaskMetadata _$TaskMetadataFromJson(Map<String, dynamic> json) => TaskMetadata(
  externalUrl: json['externalUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$TaskMetadataToJson(TaskMetadata instance) =>
    <String, dynamic>{
      'externalUrl': instance.externalUrl,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
    };

UserTaskStatus _$UserTaskStatusFromJson(Map<String, dynamic> json) =>
    UserTaskStatus(
      canSubmit: json['canSubmit'] as bool,
      hasSubmitted: json['hasSubmitted'] as bool,
      submissionStatus: json['submissionStatus'] as String?,
      lastSubmissionDate: json['lastSubmissionDate'] == null
          ? null
          : DateTime.parse(json['lastSubmissionDate'] as String),
      nextAvailableDate: json['nextAvailableDate'] == null
          ? null
          : DateTime.parse(json['nextAvailableDate'] as String),
      reasonsForRestriction: (json['reasonsForRestriction'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$UserTaskStatusToJson(UserTaskStatus instance) =>
    <String, dynamic>{
      'canSubmit': instance.canSubmit,
      'hasSubmitted': instance.hasSubmitted,
      'submissionStatus': instance.submissionStatus,
      'lastSubmissionDate': instance.lastSubmissionDate?.toIso8601String(),
      'nextAvailableDate': instance.nextAvailableDate?.toIso8601String(),
      'reasonsForRestriction': instance.reasonsForRestriction,
    };

TaskInfo _$TaskInfoFromJson(Map<String, dynamic> json) => TaskInfo(
  completionRate: (json['completionRate'] as num).toDouble(),
  averageRating: (json['averageRating'] as num).toDouble(),
  isPopular: json['isPopular'] as bool,
  remainingSlots: (json['remainingSlots'] as num?)?.toInt(),
  urgency: json['urgency'] as String,
);

Map<String, dynamic> _$TaskInfoToJson(TaskInfo instance) => <String, dynamic>{
  'completionRate': instance.completionRate,
  'averageRating': instance.averageRating,
  'isPopular': instance.isPopular,
  'remainingSlots': instance.remainingSlots,
  'urgency': instance.urgency,
};
