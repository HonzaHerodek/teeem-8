import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import './rating_model.dart';
import './targeting_model.dart';
import './trait_model.dart';

part 'post_model.g.dart';

enum StepType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('document')
  document,
  @JsonValue('link')
  link,
  @JsonValue('code')
  code,
  @JsonValue('quiz')
  quiz,
  @JsonValue('ar')
  ar,
  @JsonValue('vr')
  vr
}

enum PostStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('archived')
  archived,
  @JsonValue('deleted')
  deleted,
  @JsonValue('flagged')
  flagged,
  @JsonValue('active')
  active,
}

@immutable
@JsonSerializable(explicitToJson: true)
class PostStep {
  final String id;
  @JsonKey(
    fromJson: _stepTypeFromJson,
    toJson: _stepTypeToJson,
  )
  final StepType type;
  final String title;
  final String? description;
  final Map<String, dynamic>? content;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? documentUrl;
  final String? linkUrl;
  final String? codeSnippet;
  final String? codeLanguage;
  final String? codeOutput;
  final String? codeError;
  final String? codeStatus;
  final String? codeTimestamp;
  final String? codeUserId;
  final String? codeUsername;
  final String? codeUserProfileImage;

  const PostStep({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.documentUrl,
    this.linkUrl,
    this.codeSnippet,
    this.codeLanguage,
    this.codeOutput,
    this.codeError,
    this.codeStatus,
    this.codeTimestamp,
    this.codeUserId,
    this.codeUsername,
    this.codeUserProfileImage,
  });

  static StepType _stepTypeFromJson(String value) =>
      StepType.values.firstWhere((e) => e.toString().split('.').last == value);

  static String _stepTypeToJson(StepType type) =>
      type.toString().split('.').last;

  factory PostStep.fromJson(Map<String, dynamic> json) =>
      _$PostStepFromJson(json);

  Map<String, dynamic> toJson() => _$PostStepToJson(this);

  dynamic getContentValue(String key) {
    if (content == null) return null;
    return content![key];
  }

  String? getContentValueAsString(String key) {
    if (content == null) return null;
    final value = content![key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is List) return value.join('\n');
    return value.toString();
  }
}

@immutable
@JsonSerializable(explicitToJson: true)
class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userProfileImage;
  final String title;
  final String description;
  final List<PostStep> steps;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> likes;
  final List<String> comments;
  @JsonKey(defaultValue: PostStatus.draft)
  final PostStatus status;
  final List<RatingModel> ratings;
  final List<TraitModel> userTraits;
  final TargetingCriteria? targetingCriteria;
  final Map<String, dynamic>? aiMetadata;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfileImage,
    required this.title,
    required this.description,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.comments,
    required this.status,
    required this.ratings,
    required this.userTraits,
    this.targetingCriteria,
    this.aiMetadata,
  });

  RatingStats get ratingStats => RatingStats.fromRatings(ratings);

  RatingModel? getUserRating(String userId) {
    return ratings.cast<RatingModel?>().firstWhere(
          (rating) => rating?.userId == userId,
          orElse: () => null,
        );
  }

  bool isTargetedTo(TargetingCriteria userCriteria) {
    if (targetingCriteria == null) return true;
    return targetingCriteria!.matches(userCriteria);
  }

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userProfileImage,
    String? title,
    String? description,
    List<PostStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? likes,
    List<String>? comments,
    PostStatus? status,
    List<RatingModel>? ratings,
    List<TraitModel>? userTraits,
    TargetingCriteria? targetingCriteria,
    Map<String, dynamic>? aiMetadata,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      title: title ?? this.title,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      ratings: ratings ?? this.ratings,
      userTraits: userTraits ?? this.userTraits,
      targetingCriteria: targetingCriteria ?? this.targetingCriteria,
      aiMetadata: aiMetadata ?? this.aiMetadata,
    );
  }
}
