import 'package:json_annotation/json_annotation.dart';

part 'targeting_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TargetingCriteria {
  final List<String>? interests;
  final int? minAge;
  final int? maxAge;
  final List<String>? locations;
  final List<String>? languages;
  final String? experienceLevel;
  final List<String>? skills;
  final List<String>? industries;

  TargetingCriteria({
    this.interests,
    this.minAge,
    this.maxAge,
    this.locations,
    this.languages,
    this.experienceLevel,
    this.skills,
    this.industries,
  });

  factory TargetingCriteria.fromJson(Map<String, dynamic> json) =>
      _$TargetingCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$TargetingCriteriaToJson(this);

  bool matches(TargetingCriteria userCriteria) {
    if (minAge != null &&
        userCriteria.minAge != null &&
        minAge! > userCriteria.minAge!) {
      return false;
    }
    if (maxAge != null &&
        userCriteria.maxAge != null &&
        maxAge! < userCriteria.maxAge!) {
      return false;
    }

    if (experienceLevel != null &&
        userCriteria.experienceLevel != null &&
        experienceLevel != userCriteria.experienceLevel) {
      return false;
    }

    if (interests != null &&
        interests!.isNotEmpty &&
        userCriteria.interests != null) {
      if (!interests!
          .any((interest) => userCriteria.interests!.contains(interest))) {
        return false;
      }
    }

    if (locations != null &&
        locations!.isNotEmpty &&
        userCriteria.locations != null) {
      if (!locations!
          .any((location) => userCriteria.locations!.contains(location))) {
        return false;
      }
    }

    if (languages != null &&
        languages!.isNotEmpty &&
        userCriteria.languages != null) {
      if (!languages!
          .any((language) => userCriteria.languages!.contains(language))) {
        return false;
      }
    }

    if (skills != null && skills!.isNotEmpty && userCriteria.skills != null) {
      if (!skills!.any((skill) => userCriteria.skills!.contains(skill))) {
        return false;
      }
    }

    if (industries != null &&
        industries!.isNotEmpty &&
        userCriteria.industries != null) {
      if (!industries!
          .any((industry) => userCriteria.industries!.contains(industry))) {
        return false;
      }
    }

    return true;
  }

  TargetingCriteria copyWith({
    List<String>? interests,
    int? minAge,
    int? maxAge,
    List<String>? locations,
    List<String>? languages,
    String? experienceLevel,
    List<String>? skills,
    List<String>? industries,
  }) {
    return TargetingCriteria(
      interests: interests ?? this.interests,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      locations: locations ?? this.locations,
      languages: languages ?? this.languages,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      skills: skills ?? this.skills,
      industries: industries ?? this.industries,
    );
  }
}
