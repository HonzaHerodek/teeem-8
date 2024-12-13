import 'package:bloc/bloc.dart';
import 'package:myapp/data/models/post_model.dart';
import 'package:myapp/domain/repositories/auth_repository.dart';
import 'package:myapp/presentation/widgets/filtering/services/filter_service.dart';
import 'package:myapp/domain/repositories/post_repository.dart';
import 'package:myapp/domain/repositories/user_repository.dart';
import 'package:myapp/core/services/rating_service.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final PostRepository _postRepository;
  final UserRepository _userRepository;
  final FilterService _filterService;
  final RatingService _ratingService;
  final AuthRepository _authRepository;

  FeedBloc({
    required PostRepository postRepository,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required FilterService filterService,
    required RatingService ratingService,
  })  : _postRepository = postRepository,
        _userRepository = userRepository,
        _filterService = filterService,
        _ratingService = ratingService,
        _authRepository = authRepository,
        super(const FeedInitial()) {
    on<FeedStarted>(_onStarted);
    on<FeedRefreshed>(_onRefreshed);
    on<FeedLoadMore>(_onLoadMore);
    on<FeedPostLiked>(_onPostLiked);
    on<FeedPostRated>(_onPostRated);
    on<FeedFilterChanged>(_onFilterChanged);
    on<FeedSearchChanged>(_onSearchChanged);
  }

  Future<void> _onStarted(FeedStarted event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      final posts = await _postRepository.getPosts();
      final filteredPosts = _filterService.filterPosts(posts, currentUser);
      emit(FeedSuccess(posts: filteredPosts, currentUserId: currentUser.id));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> _onRefreshed(
      FeedRefreshed event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    try {
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      final posts = await _postRepository.getPosts();
      final filteredPosts = _filterService.filterPosts(posts, currentUser);
      emit(FeedSuccess(posts: filteredPosts, currentUserId: currentUser.id));
    } catch (e) {
      emit(FeedFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadMore(FeedLoadMore event, Emitter<FeedState> emit) async {
    if (state is FeedSuccess) {
      final currentState = state as FeedSuccess;
      emit(FeedLoadingMore(posts: currentState.posts));
      try {
        final currentUser = await _authRepository.getCurrentUser();
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }
        final posts = await _postRepository.getPosts();
        final filteredPosts = _filterService.filterPosts(posts, currentUser);
        emit(FeedSuccess(
            posts: [...currentState.posts, ...filteredPosts],
            currentUserId: currentUser.id));
      } catch (e) {
        emit(FeedFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onPostLiked(
      FeedPostLiked event, Emitter<FeedState> emit) async {
    if (state is FeedSuccess) {
      final currentState = state as FeedSuccess;
      try {
        // First like the post
        await _postRepository.likePost(event.postId, currentState.currentUserId);
        // Then fetch the updated post
        final updatedPost = await _postRepository.getPostById(event.postId);
        // Update the posts list with the new post
        final updatedPosts = currentState.posts.map((post) {
          return post.id == event.postId ? updatedPost : post;
        }).toList();
        emit(FeedSuccess(
            posts: updatedPosts, currentUserId: currentState.currentUserId));
      } catch (e) {
        emit(FeedFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onPostRated(
      FeedPostRated event, Emitter<FeedState> emit) async {
    if (state is FeedSuccess) {
      final currentState = state as FeedSuccess;
      try {
        // First rate the post
        await _ratingService.ratePost(
            event.postId, currentState.currentUserId, event.rating);
        // Then fetch the updated post
        final updatedPost = await _postRepository.getPostById(event.postId);
        // Update the posts list with the new post
        final updatedPosts = currentState.posts.map((post) {
          return post.id == event.postId ? updatedPost : post;
        }).toList();
        emit(FeedSuccess(
            posts: updatedPosts, currentUserId: currentState.currentUserId));
      } catch (e) {
        emit(FeedFailure(error: e.toString()));
      }
    }
  }

  void _onFilterChanged(
      FeedFilterChanged event, Emitter<FeedState> emit) async {
    if (state is FeedSuccess) {
      final currentState = state as FeedSuccess;
      _filterService.setFilter(event.filterType);
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        emit(FeedFailure(error: 'User not authenticated'));
        return;
      }
      final filteredPosts =
          _filterService.filterPosts(currentState.posts, currentUser);
      emit(FeedSuccess(
          posts: filteredPosts, currentUserId: currentState.currentUserId));
    }
  }

  void _onSearchChanged(
      FeedSearchChanged event, Emitter<FeedState> emit) async {
    if (state is FeedSuccess) {
      final currentState = state as FeedSuccess;
      final filteredPosts = currentState.posts
          .where((post) =>
              post.title.toLowerCase().contains(event.query.toLowerCase()) ||
              post.description
                  .toLowerCase()
                  .contains(event.query.toLowerCase()))
          .toList();
      emit(FeedSuccess(
          posts: filteredPosts, currentUserId: currentState.currentUserId));
    }
  }
}
