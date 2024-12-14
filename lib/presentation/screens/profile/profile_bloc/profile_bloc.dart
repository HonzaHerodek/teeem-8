import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/rating_service.dart';
import '../../../../core/services/logger_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final PostRepository postRepository;
  final RatingService ratingService;
  final logger = LoggerService();

  ProfileBloc({
    required this.userRepository,
    required this.postRepository,
    required this.ratingService,
  }) : super(const ProfileState()) {
    on<ProfileStarted>(_onProfileStarted);
    on<ProfileRefreshed>(_onProfileRefreshed);
    on<ProfilePostsRequested>(_onProfilePostsRequested);
    on<ProfileSettingsUpdated>(_onProfileSettingsUpdated);
    on<ProfileBioUpdated>(_onProfileBioUpdated);
    on<ProfileTargetingUpdated>(_onProfileTargetingUpdated);
    on<ProfileRatingReceived>(_onProfileRatingReceived);
  }

  Future<void> _onProfileStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final currentUser = await userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('User not found');
      }

      final userPosts = await postRepository.getPosts(userId: currentUser.id);
      final ratingStats =
          await ratingService.getUserRatingStats(currentUser.id);

      emit(state.copyWith(
        isLoading: false,
        user: currentUser,
        userPosts: userPosts,
        ratingStats: ratingStats,
        error: null,
      ));
    } catch (e) {
      logger.e('Error in ProfileBloc._onProfileStarted', error: e);
      emit(state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : 'Failed to load profile',
      ));
    }
  }

  Future<void> _onProfileRefreshed(
    ProfileRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Don't show loading indicator for refresh
      emit(state.copyWith(error: null));

      final currentUser = await userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('User not found');
      }

      final userPosts = await postRepository.getPosts(userId: currentUser.id);
      final ratingStats =
          await ratingService.getUserRatingStats(currentUser.id);

      emit(state.copyWith(
        user: currentUser,
        userPosts: userPosts,
        ratingStats: ratingStats,
        error: null,
      ));
    } catch (e) {
      logger.e('Error in ProfileBloc._onProfileRefreshed', error: e);
      emit(state.copyWith(
        error: e is AppException ? e.message : 'Failed to refresh profile',
      ));
    }
  }

  Future<void> _onProfilePostsRequested(
    ProfilePostsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.user == null) {
        throw AppException('User not found');
      }

      final userPosts = await postRepository.getPosts(userId: state.user!.id);
      emit(state.copyWith(userPosts: userPosts, error: null));
    } catch (e) {
      logger.e('Error in ProfileBloc._onProfilePostsRequested', error: e);
      emit(state.copyWith(
        error: e is AppException ? e.message : 'Failed to load posts',
      ));
    }
  }

  Future<void> _onProfileSettingsUpdated(
    ProfileSettingsUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.user == null) {
        throw AppException('User not found');
      }

      final updatedUser = state.user!.copyWith(settings: event.settings);
      await userRepository.updateUser(updatedUser);

      emit(state.copyWith(user: updatedUser, error: null));
    } catch (e) {
      logger.e('Error in ProfileBloc._onProfileSettingsUpdated', error: e);
      emit(state.copyWith(
        error: e is AppException ? e.message : 'Failed to update settings',
      ));
    }
  }

  Future<void> _onProfileBioUpdated(
    ProfileBioUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.user == null) {
        throw AppException('User not found');
      }

      final updatedUser = state.user!.copyWith(bio: event.bio);
      await userRepository.updateUser(updatedUser);

      emit(state.copyWith(user: updatedUser, error: null));
    } catch (e) {
      logger.e('Error in ProfileBloc._onProfileBioUpdated', error: e);
      emit(state.copyWith(
        error: e is AppException ? e.message : 'Failed to update bio',
      ));
    }
  }

  Future<void> _onProfileTargetingUpdated(
    ProfileTargetingUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.user == null) {
        throw AppException('User not found');
      }

      final updatedUser = state.user!.copyWith(
        targetingCriteria: event.targetingCriteria,
      );
      await userRepository.updateUser(updatedUser);

      emit(state.copyWith(user: updatedUser, error: null));
    } catch (e) {
      logger.e('Error in ProfileBloc._onProfileTargetingUpdated', error: e);
      emit(state.copyWith(
        error: e is AppException
            ? e.message
            : 'Failed to update targeting criteria',
      ));
    }
  }

  Future<void> _onProfileRatingReceived(
    ProfileRatingReceived event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state.user == null) {
        throw AppException('User not found');
      }

      await ratingService.rateUser(state.user!.id, event.raterId, event.rating);
      final ratingStats =
          await ratingService.getUserRatingStats(state.user!.id);

      emit(state.copyWith(
        ratingStats: ratingStats,
        error: null,
      ));
    } catch (e) {
      logger.e('Error in ProfileBloc._onProfileRatingReceived', error: e);
      emit(state.copyWith(
        error: e is AppException ? e.message : 'Failed to update rating',
      ));
    }
  }
}
