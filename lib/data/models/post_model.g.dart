// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostStep _$PostStepFromJson(Map<String, dynamic> json) => PostStep(
      id: json['id'] as String,
      type: PostStep._stepTypeFromJson(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      content: json['content'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      documentUrl: json['documentUrl'] as String?,
      linkUrl: json['linkUrl'] as String?,
      codeSnippet: json['codeSnippet'] as String?,
      codeLanguage: json['codeLanguage'] as String?,
      codeOutput: json['codeOutput'] as String?,
      codeError: json['codeError'] as String?,
      codeStatus: json['codeStatus'] as String?,
      codeTimestamp: json['codeTimestamp'] as String?,
      codeUserId: json['codeUserId'] as String?,
      codeUsername: json['codeUsername'] as String?,
      codeUserProfileImage: json['codeUserProfileImage'] as String?,
    );

Map<String, dynamic> _$PostStepToJson(PostStep instance) => <String, dynamic>{
      'id': instance.id,
      'type': PostStep._stepTypeToJson(instance.type),
      'title': instance.title,
      'description': instance.description,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'audioUrl': instance.audioUrl,
      'documentUrl': instance.documentUrl,
      'linkUrl': instance.linkUrl,
      'codeSnippet': instance.codeSnippet,
      'codeLanguage': instance.codeLanguage,
      'codeOutput': instance.codeOutput,
      'codeError': instance.codeError,
      'codeStatus': instance.codeStatus,
      'codeTimestamp': instance.codeTimestamp,
      'codeUserId': instance.codeUserId,
      'codeUsername': instance.codeUsername,
      'codeUserProfileImage': instance.codeUserProfileImage,
    };

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userProfileImage: json['userProfileImage'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => PostStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      likes: (json['likes'] as List<dynamic>).map((e) => e as String).toList(),
      comments:
          (json['comments'] as List<dynamic>).map((e) => e as String).toList(),
      status: $enumDecodeNullable(_$PostStatusEnumMap, json['status']) ??
          PostStatus.draft,
      ratings: (json['ratings'] as List<dynamic>)
          .map((e) => RatingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userTraits: (json['userTraits'] as List<dynamic>)
          .map((e) => TraitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      targetingCriteria: json['targetingCriteria'] == null
          ? null
          : TargetingCriteria.fromJson(
              json['targetingCriteria'] as Map<String, dynamic>),
      aiMetadata: json['aiMetadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'userProfileImage': instance.userProfileImage,
      'title': instance.title,
      'description': instance.description,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'likes': instance.likes,
      'comments': instance.comments,
      'status': _$PostStatusEnumMap[instance.status]!,
      'ratings': instance.ratings.map((e) => e.toJson()).toList(),
      'userTraits': instance.userTraits.map((e) => e.toJson()).toList(),
      'targetingCriteria': instance.targetingCriteria?.toJson(),
      'aiMetadata': instance.aiMetadata,
    };

const _$PostStatusEnumMap = {
  PostStatus.draft: 'draft',
  PostStatus.published: 'published',
  PostStatus.archived: 'archived',
  PostStatus.deleted: 'deleted',
  PostStatus.flagged: 'flagged',
  PostStatus.active: 'active',
};
