// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingModel _$RatingModelFromJson(Map<String, dynamic> json) => RatingModel(
      value: (json['value'] as num).toDouble(),
      userId: json['userId'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RatingModelToJson(RatingModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

RatingStats _$RatingStatsFromJson(Map<String, dynamic> json) => RatingStats(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      ratingDistribution:
          (json['ratingDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as int),
      ),
    );

Map<String, dynamic> _$RatingStatsToJson(RatingStats instance) =>
    <String, dynamic>{
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'ratingDistribution':
          instance.ratingDistribution.map((k, e) => MapEntry(k.toString(), e)),
    };
