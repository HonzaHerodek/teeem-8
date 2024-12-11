import 'package:equatable/equatable.dart';
import '../../../../data/models/targeting_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileRefreshed extends ProfileEvent {
  const ProfileRefreshed();
}

class ProfilePostsRequested extends ProfileEvent {
  const ProfilePostsRequested();
}

class ProfileSettingsUpdated extends ProfileEvent {
  final Map<String, dynamic> settings;

  const ProfileSettingsUpdated(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ProfileBioUpdated extends ProfileEvent {
  final String bio;

  const ProfileBioUpdated(this.bio);

  @override
  List<Object?> get props => [bio];
}

class ProfileTargetingUpdated extends ProfileEvent {
  final TargetingCriteria targetingCriteria;

  const ProfileTargetingUpdated(this.targetingCriteria);

  @override
  List<Object?> get props => [targetingCriteria];
}

class ProfileRatingReceived extends ProfileEvent {
  final double rating;
  final String raterId;

  const ProfileRatingReceived(this.rating, this.raterId);

  @override
  List<Object?> get props => [rating, raterId];
}
