// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'targeting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TargetingCriteria _$TargetingCriteriaFromJson(Map<String, dynamic> json) =>
    TargetingCriteria(
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      experienceLevel: json['experienceLevel'] as String?,
      skills:
          (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
      industries: (json['industries'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TargetingCriteriaToJson(TargetingCriteria instance) =>
    <String, dynamic>{
      'interests': instance.interests,
      'minAge': instance.minAge,
      'maxAge': instance.maxAge,
      'locations': instance.locations,
      'languages': instance.languages,
      'experienceLevel': instance.experienceLevel,
      'skills': instance.skills,
      'industries': instance.industries,
    };
