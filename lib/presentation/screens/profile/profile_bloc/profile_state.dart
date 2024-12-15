import 'package:equatable/equatable.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/rating_model.dart';

class ProfileState extends Equatable {
  final bool isInitial;
  final bool isLoading;
  final UserModel? user;
  final List<PostModel> userPosts;
  final RatingStats? ratingStats;
  final String? error;

  const ProfileState({
    this.isInitial = true,
    this.isLoading = false,
    this.user,
    this.userPosts = const [],
    this.ratingStats,
    this.error,
  });

  bool get hasError => error != null;

  ProfileState copyWith({
    bool? isInitial,
    bool? isLoading,
    UserModel? user,
    List<PostModel>? userPosts,
    RatingStats? ratingStats,
    String? error,
  }) {
    return ProfileState(
      // If user is provided or isInitial is explicitly set to false, set isInitial to false
      isInitial: isInitial ?? (user != null ? false : this.isInitial),
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      userPosts: userPosts ?? this.userPosts,
      ratingStats: ratingStats ?? this.ratingStats,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isInitial,
        isLoading,
        user,
        userPosts,
        ratingStats,
        error,
      ];
}
