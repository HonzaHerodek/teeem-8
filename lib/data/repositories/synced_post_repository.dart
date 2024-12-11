import '../../core/errors/app_exception.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

/// A repository that syncs between online and offline data sources
class SyncedPostRepository implements PostRepository {
  final PostRepository _onlineRepository;
  final PostRepository _offlineRepository;
  final ConnectivityService _connectivityService;

  SyncedPostRepository({
    required PostRepository onlineRepository,
    required PostRepository offlineRepository,
    required ConnectivityService connectivityService,
  })  : _onlineRepository = onlineRepository,
        _offlineRepository = offlineRepository,
        _connectivityService = connectivityService;

  /// Get the appropriate repository based on connectivity
  PostRepository get _activeRepository =>
      _connectivityService.isOnline ? _onlineRepository : _offlineRepository;

  @override
  Future<List<PostModel>> getPosts({
    int? limit,
    String? startAfter,
    String? userId,
    List<String>? tags,
  }) async {
    try {
      return await _activeRepository.getPosts(
        limit: limit,
        startAfter: startAfter,
        userId: userId,
        tags: tags,
      );
    } catch (e) {
      throw AppException('Failed to fetch posts: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      return await _activeRepository.getPostById(postId);
    } catch (e) {
      throw AppException('Failed to fetch post: ${e.toString()}');
    }
  }

  @override
  Future<void> createPost(PostModel post) async {
    try {
      await _activeRepository.createPost(post);
      if (_connectivityService.isOnline) {
        await _offlineRepository.createPost(post);
      }
    } catch (e) {
      throw AppException('Failed to create post: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePost(PostModel post) async {
    try {
      await _activeRepository.updatePost(post);
      if (_connectivityService.isOnline) {
        await _offlineRepository.updatePost(post);
      }
    } catch (e) {
      throw AppException('Failed to update post: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _activeRepository.deletePost(postId);
      if (_connectivityService.isOnline) {
        await _offlineRepository.deletePost(postId);
      }
    } catch (e) {
      throw AppException('Failed to delete post: ${e.toString()}');
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      await _activeRepository.likePost(postId, userId);
      if (_connectivityService.isOnline) {
        await _offlineRepository.likePost(postId, userId);
      }
    } catch (e) {
      throw AppException('Failed to like post: ${e.toString()}');
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _activeRepository.unlikePost(postId, userId);
      if (_connectivityService.isOnline) {
        await _offlineRepository.unlikePost(postId, userId);
      }
    } catch (e) {
      throw AppException('Failed to unlike post: ${e.toString()}');
    }
  }

  @override
  Future<void> addComment(String postId, String userId, String comment) async {
    try {
      await _activeRepository.addComment(postId, userId, comment);
      if (_connectivityService.isOnline) {
        await _offlineRepository.addComment(postId, userId, comment);
      }
    } catch (e) {
      throw AppException('Failed to add comment: ${e.toString()}');
    }
  }

  @override
  Future<void> removeComment(String postId, String commentId) async {
    try {
      await _activeRepository.removeComment(postId, commentId);
      if (_connectivityService.isOnline) {
        await _offlineRepository.removeComment(postId, commentId);
      }
    } catch (e) {
      throw AppException('Failed to remove comment: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePostStep(
    String postId,
    String stepId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _activeRepository.updatePostStep(postId, stepId, data);
      if (_connectivityService.isOnline) {
        await _offlineRepository.updatePostStep(postId, stepId, data);
      }
    } catch (e) {
      throw AppException('Failed to update post step: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      return await _activeRepository.searchPosts(query);
    } catch (e) {
      throw AppException('Failed to search posts: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getTrendingPosts({int? limit}) async {
    try {
      return await _activeRepository.getTrendingPosts(limit: limit);
    } catch (e) {
      throw AppException('Failed to get trending posts: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getRecommendedPosts({
    required String userId,
    int? limit,
  }) async {
    try {
      return await _activeRepository.getRecommendedPosts(
        userId: userId,
        limit: limit,
      );
    } catch (e) {
      throw AppException('Failed to get recommended posts: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getUserFeed({
    required String userId,
    int? limit,
    String? startAfter,
  }) async {
    try {
      return await _activeRepository.getUserFeed(
        userId: userId,
        limit: limit,
        startAfter: startAfter,
      );
    } catch (e) {
      throw AppException('Failed to get user feed: ${e.toString()}');
    }
  }

  @override
  Future<void> reportPost(String postId, String userId, String reason) async {
    try {
      await _activeRepository.reportPost(postId, userId, reason);
    } catch (e) {
      throw AppException('Failed to report post: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    try {
      return await _activeRepository.getPostAnalytics(postId);
    } catch (e) {
      throw AppException('Failed to get post analytics: ${e.toString()}');
    }
  }

  @override
  Future<void> hidePost(String postId, String userId) async {
    try {
      await _activeRepository.hidePost(postId, userId);
      if (_connectivityService.isOnline) {
        await _offlineRepository.hidePost(postId, userId);
      }
    } catch (e) {
      throw AppException('Failed to hide post: ${e.toString()}');
    }
  }

  @override
  Future<void> savePost(String postId, String userId) async {
    try {
      await _activeRepository.savePost(postId, userId);
      if (_connectivityService.isOnline) {
        await _offlineRepository.savePost(postId, userId);
      }
    } catch (e) {
      throw AppException('Failed to save post: ${e.toString()}');
    }
  }

  @override
  Future<void> unsavePost(String postId, String userId) async {
    try {
      await _activeRepository.unsavePost(postId, userId);
      if (_connectivityService.isOnline) {
        await _offlineRepository.unsavePost(postId, userId);
      }
    } catch (e) {
      throw AppException('Failed to unsave post: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getPostTags(String postId) async {
    try {
      return await _activeRepository.getPostTags(postId);
    } catch (e) {
      throw AppException('Failed to get post tags: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePostTags(String postId, List<String> tags) async {
    try {
      await _activeRepository.updatePostTags(postId, tags);
      if (_connectivityService.isOnline) {
        await _offlineRepository.updatePostTags(postId, tags);
      }
    } catch (e) {
      throw AppException('Failed to update post tags: ${e.toString()}');
    }
  }
}
