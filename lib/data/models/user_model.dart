import 'package:json_annotation/json_annotation.dart';
import 'targeting_model.dart';
import 'rating_model.dart';
import 'trait_model.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? profileImage;
  final String? bio;
  final List<String> followers;
  final List<String> following;
  final Map<String, dynamic>? settings;
  final DateTime createdAt;
  final DateTime? lastActive;
  final TargetingCriteria? targetingCriteria;
  @JsonKey(defaultValue: [])
  final List<RatingModel> ratings;
  @JsonKey(defaultValue: [])
  final List<TraitModel> traits;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.profileImage,
    this.bio,
    this.followers = const [],
    this.following = const [],
    this.settings,
    DateTime? createdAt,
    this.lastActive,
    this.targetingCriteria,
    List<RatingModel>? ratings,
    List<TraitModel>? traits,
  })  : createdAt = createdAt ?? DateTime.now(),
        ratings = ratings ?? const [],
        traits = traits ?? const [];

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  RatingStats get ratingStats => RatingStats.fromRatings(ratings);

  double? getUserRating(String userId) {
    final userRating = ratings.where((r) => r.userId == userId).firstOrNull;
    return userRating?.value;
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImage,
    String? bio,
    List<String>? followers,
    List<String>? following,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? lastActive,
    TargetingCriteria? targetingCriteria,
    List<RatingModel>? ratings,
    List<TraitModel>? traits,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      targetingCriteria: targetingCriteria ?? this.targetingCriteria,
      ratings: ratings ?? this.ratings,
      traits: traits ?? this.traits,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          profileImage == other.profileImage &&
          bio == other.bio;

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      profileImage.hashCode ^
      bio.hashCode;

  @override
  String toString() {
    return 'UserModel{id: $id, username: $username, email: $email}';
  }

  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;
  int get followersCount => followers.length;
  int get followingCount => following.length;
  bool get isNewUser => DateTime.now().difference(createdAt).inDays < 7;
  bool get isActive =>
      lastActive != null &&
      DateTime.now().difference(lastActive!).inMinutes < 5;
}
