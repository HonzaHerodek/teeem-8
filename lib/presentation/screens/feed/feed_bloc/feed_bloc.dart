import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/feed_filter_service.dart';
import '../../../../core/services/rating_service.dart';
import '../../../../domain/repositories/auth_repository.dart';
import '../../../../domain/repositories/post_repository.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/user_model.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final FeedFilterService _feedFilterService;
  final RatingService _ratingService;
  static const _postsPerPage = 10;

  FeedBloc({
    required PostRepository postRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required FeedFilterService feedFilterService,
    required RatingService ratingService,
  })  : _postRepository = postRepository,
        _authRepository = authRepository,
        _userRepository = userRepository,
        _feedFilterService = feedFilterService,
        _ratingService = ratingService,
        super(const FeedState()) {
    on<FeedStarted>(_onFeedStarted);
    on<FeedRefreshed>(_onFeedRefreshed);
    on<FeedLoadMore>(_onFeedLoadMore);
    on<FeedPostLiked>(_onFeedPostLiked);
    on<FeedPostUnliked>(_onFeedPostUnliked);
    on<FeedPostDeleted>(_onFeedPostDeleted);
    on<FeedPostHidden>(_onFeedPostHidden);
    on<FeedPostSaved>(_onFeedPostSaved);
    on<FeedPostUnsaved>(_onFeedPostUnsaved);
    on<FeedPostReported>(_onFeedPostReported);
    on<FeedPostRated>(_onFeedPostRated);
    on<FeedTargetingFilterChanged>(_onFeedTargetingFilterChanged);
    on<FeedFilterChanged>(_onFeedFilterChanged);
  }

  Future<void> _onFeedStarted(
    FeedStarted event,
    Emitter<FeedState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FeedStatus.loading));

      final userId = await _authRepository.getCurrentUserId();
      if (userId == null) {
        throw AppException('User not authenticated');
      }

      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('User not found');
      }

      final allPosts = await _postRepository.getPosts(limit: _postsPerPage);
      final filteredPosts = _filterPosts(allPosts, currentUser);

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: filteredPosts,
        hasReachedMax: allPosts.length < _postsPerPage,
        currentUserId: userId,
        lastPostId: allPosts.isNotEmpty ? allPosts.last.id : null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedFilterChanged(
    FeedFilterChanged event,
    Emitter<FeedState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: FeedStatus.loading,
        currentFilter: event.filterType,
      ));

      _feedFilterService.setFilter(event.filterType);

      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('User not found');
      }

      final allPosts = await _postRepository.getPosts(limit: _postsPerPage);
      final filteredPosts = _filterPosts(allPosts, currentUser);

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: filteredPosts,
        hasReachedMax: allPosts.length < _postsPerPage,
        lastPostId: allPosts.isNotEmpty ? allPosts.last.id : null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedRefreshed(
    FeedRefreshed event,
    Emitter<FeedState> emit,
  ) async {
    try {
      emit(state.copyWith(isRefreshing: true));

      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('User not found');
      }

      final allPosts = await _postRepository.getPosts(limit: _postsPerPage);
      final filteredPosts = _filterPosts(allPosts, currentUser);

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: filteredPosts,
        hasReachedMax: allPosts.length < _postsPerPage,
        lastPostId: allPosts.isNotEmpty ? allPosts.last.id : null,
        isRefreshing: false,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
        isRefreshing: false,
      ));
    }
  }

  Future<void> _onFeedLoadMore(
    FeedLoadMore event,
    Emitter<FeedState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      emit(state.copyWith(status: FeedStatus.loadingMore));

      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('User not found');
      }

      final allPosts = await _postRepository.getPosts(
        limit: _postsPerPage,
        startAfter: state.lastPostId,
      );
      final filteredPosts = _filterPosts(allPosts, currentUser);

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: [...state.posts, ...filteredPosts],
        hasReachedMax: allPosts.length < _postsPerPage,
        lastPostId: allPosts.isNotEmpty ? allPosts.last.id : state.lastPostId,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedTargetingFilterChanged(
    FeedTargetingFilterChanged event,
    Emitter<FeedState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: FeedStatus.loading,
        targetingFilter: event.targetingCriteria,
      ));

      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser == null) {
        throw AppException('User not found');
      }

      final allPosts = await _postRepository.getPosts(limit: _postsPerPage);
      final filteredPosts = _filterPosts(allPosts, currentUser);

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: filteredPosts,
        hasReachedMax: allPosts.length < _postsPerPage,
        lastPostId: allPosts.isNotEmpty ? allPosts.last.id : null,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostLiked(
    FeedPostLiked event,
    Emitter<FeedState> emit,
  ) async {
    if (state.currentUserId == null) return;

    try {
      await _postRepository.likePost(event.postId, state.currentUserId!);
      final updatedPosts = await _refreshPosts();
      emit(state.copyWith(posts: updatedPosts));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostUnliked(
    FeedPostUnliked event,
    Emitter<FeedState> emit,
  ) async {
    if (state.currentUserId == null) return;

    try {
      await _postRepository.unlikePost(event.postId, state.currentUserId!);
      final updatedPosts = await _refreshPosts();
      emit(state.copyWith(posts: updatedPosts));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostDeleted(
    FeedPostDeleted event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await _postRepository.deletePost(event.postId);
      final updatedPosts =
          state.posts.where((p) => p.id != event.postId).toList();
      emit(state.copyWith(posts: updatedPosts));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostHidden(
    FeedPostHidden event,
    Emitter<FeedState> emit,
  ) async {
    if (state.currentUserId == null) return;

    try {
      await _postRepository.hidePost(event.postId, state.currentUserId!);
      final updatedPosts =
          state.posts.where((p) => p.id != event.postId).toList();
      emit(state.copyWith(posts: updatedPosts));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostSaved(
    FeedPostSaved event,
    Emitter<FeedState> emit,
  ) async {
    if (state.currentUserId == null) return;

    try {
      await _postRepository.savePost(event.postId, state.currentUserId!);
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostUnsaved(
    FeedPostUnsaved event,
    Emitter<FeedState> emit,
  ) async {
    if (state.currentUserId == null) return;

    try {
      await _postRepository.unsavePost(event.postId, state.currentUserId!);
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostReported(
    FeedPostReported event,
    Emitter<FeedState> emit,
  ) async {
    if (state.currentUserId == null) return;

    try {
      await _postRepository.reportPost(
        event.postId,
        state.currentUserId!,
        event.reason,
      );
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<void> _onFeedPostRated(
    FeedPostRated event,
    Emitter<FeedState> emit,
  ) async {
    if (state.currentUserId == null) return;

    try {
      await _ratingService.ratePost(
        event.postId,
        state.currentUserId!,
        event.rating,
      );
      final updatedPosts = await _refreshPosts();
      emit(state.copyWith(posts: updatedPosts));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        error: e,
      ));
    }
  }

  Future<List<PostModel>> _refreshPosts() async {
    final currentUser = await _userRepository.getCurrentUser();
    if (currentUser == null) {
      throw AppException('User not found');
    }

    final allPosts = await _postRepository.getPosts(
      limit: state.posts.length,
    );
    return _filterPosts(allPosts, currentUser);
  }

  List<PostModel> _filterPosts(List<PostModel> posts, UserModel currentUser) {
    if (state.targetingFilter != null) {
      // Apply custom targeting filter
      posts = posts.where((post) {
        if (post.targetingCriteria == null) return true;
        return post.targetingCriteria!.matches(state.targetingFilter!);
      }).toList();
    }

    // Apply standard feed filters and type filters
    return _feedFilterService.filterPosts(posts, currentUser);
  }
}
