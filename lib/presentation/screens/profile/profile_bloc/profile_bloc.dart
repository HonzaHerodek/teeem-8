import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/rating_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../data/models/trait_model.dart';
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
    on<ProfileTraitAdded>(_onProfileTraitAdded);
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

      print('Current user traits: ${currentUser.traits}'); // Debug log

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
      print('Error in ProfileBloc._onProfileStarted: $e'); // Debug log
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
      print('Error in ProfileBloc._onProfileRefreshed: $e'); // Debug log
      emit(state.copyWith(
        isLoading: false,
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
      print('Error in ProfileBloc._onProfilePostsRequested: $e'); // Debug log
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
      print('Error in ProfileBloc._onProfileSettingsUpdated: $e'); // Debug log
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
      print('Error in ProfileBloc._onProfileBioUpdated: $e'); // Debug log
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
      print('Error in ProfileBloc._onProfileTargetingUpdated: $e'); // Debug log
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
      print('Error in ProfileBloc._onProfileRatingReceived: $e'); // Debug log
      emit(state.copyWith(
        error: e is AppException ? e.message : 'Failed to update rating',
      ));
    }
  }

  Future<void> _onProfileTraitAdded(
    ProfileTraitAdded event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) {
      emit(state.copyWith(
        error: 'User not found',
        isLoading: false,
      ));
      return;
    }

    try {
      // Create updated user with new trait
      final updatedTraits = [...state.user!.traits, event.trait];
      final updatedUser = state.user!.copyWith(traits: updatedTraits);

      // Update user in repository
      await userRepository.updateUser(updatedUser);

      // Update state with new user data
      emit(state.copyWith(
        user: updatedUser,
        error: null,
        isLoading: false,
      ));

      print('Trait added successfully: ${updatedUser.traits}'); // Debug log
    } catch (e) {
      print('Error adding trait: $e'); // Debug log
      emit(state.copyWith(
        error: e is AppException ? e.message : 'Failed to add trait',
        isLoading: false,
      ));
    }
  }
}
