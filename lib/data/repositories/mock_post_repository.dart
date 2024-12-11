import 'dart:async';
import '../../core/services/test_data_service.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class MockPostRepository implements PostRepository {
  final List<PostModel> _posts = [];
  final _delay = const Duration(milliseconds: 500);

  MockPostRepository() {
    _initializeTestPosts();
  }

  void _initializeTestPosts() {
    _posts.clear();
    // Add the long test post first to ensure it's at the top
    final longPost = TestDataService.generateLongTestPost();
    _posts.add(longPost);
    // Add more test posts to ensure we have enough content
    final testData = TestDataService.generateTestPosts(count: 5);
    _posts.addAll(testData);
    // Force refresh the list to ensure changes are visible
    _posts.insert(0, _posts.removeLast());
  }

  @override
  Future<List<PostModel>> getPosts({int? limit, String? startAfter, String? userId, List<String>? tags}) async {
    await Future.delayed(_delay);
    if (_posts.isEmpty) {
      _initializeTestPosts();
    }
    return _posts;
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    await Future.delayed(_delay);
    return _posts.firstWhere((post) => post.id == postId);
  }

  @override
  Future<void> createPost(PostModel post) async {
    await Future.delayed(_delay);
    _posts.insert(0, post);
  }

  @override
  Future<void> updatePost(PostModel post) async {
    await Future.delayed(_delay);
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await Future.delayed(_delay);
    _posts.removeWhere((post) => post.id == postId);
  }

  @override
  Future<void> updatePostTags(String postId, List<String> tags) async {
    await Future.delayed(_delay);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      Map<String, dynamic> metadata = {};
      if (_posts[index].aiMetadata != null) {
        metadata.addAll(_posts[index].aiMetadata!);
      }
      metadata['tags'] = tags;
      final updatedPost = _posts[index].copyWith(aiMetadata: metadata);
      _posts[index] = updatedPost;
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await Future.delayed(_delay);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final likes = List<String>.from(_posts[index].likes)..add(userId);
      _posts[index] = _posts[index].copyWith(likes: likes);
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await Future.delayed(_delay);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final likes = List<String>.from(_posts[index].likes)..remove(userId);
      _posts[index] = _posts[index].copyWith(likes: likes);
    }
  }

  @override
  Future<void> addComment(String postId, String userId, String comment) async {
    await Future.delayed(_delay);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final comments = List<String>.from(_posts[index].comments)..add(comment);
      _posts[index] = _posts[index].copyWith(comments: comments);
    }
  }

  @override
  Future<void> removeComment(String postId, String commentId) async {
    await Future.delayed(_delay);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final comments = List<String>.from(_posts[index].comments)..remove(commentId);
      _posts[index] = _posts[index].copyWith(comments: comments);
    }
  }

  @override
  Future<List<String>> getPostTags(String postId) async {
    await Future.delayed(_delay);
    final post = _posts.firstWhere((post) => post.id == postId);
    final tags = post.aiMetadata?['tags'] as List<dynamic>?;
    return tags?.map((tag) => tag.toString()).toList() ?? [];
  }

  @override
  Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    await Future.delayed(_delay);
    return TestDataService.generateTestAnalytics();
  }

  @override
  Future<List<PostModel>> getRecommendedPosts({required String userId, int? limit}) async {
    await Future.delayed(_delay);
    return _posts.take(limit ?? 10).toList();
  }

  @override
  Future<List<PostModel>> getUserFeed({required String userId, int? limit, String? startAfter}) async {
    await Future.delayed(_delay);
    return _posts.take(limit ?? 20).toList();
  }

  @override
  Future<List<PostModel>> getTrendingPosts({int? limit}) async {
    await Future.delayed(_delay);
    final sortedPosts = List<PostModel>.from(_posts)
      ..sort((a, b) => b.likes.length.compareTo(a.likes.length));
    return limit != null ? sortedPosts.take(limit).toList() : sortedPosts;
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    await Future.delayed(_delay);
    final queryLower = query.toLowerCase();
    return _posts.where((post) =>
      post.title.toLowerCase().contains(queryLower) ||
      post.description.toLowerCase().contains(queryLower)
    ).toList();
  }

  @override
  Future<void> updatePostStep(String postId, String stepId, Map<String, dynamic> data) async {
    await Future.delayed(_delay);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final updatedSteps = _posts[index].steps.map((step) {
        if (step.id == stepId) {
          return PostStep(
            id: step.id,
            title: data['title'] as String? ?? step.title,
            description: data['description'] as String? ?? step.description,
            type: step.type,
            content: data['content'] as Map<String, dynamic>? ?? step.content,
          );
        }
        return step;
      }).toList();
      _posts[index] = _posts[index].copyWith(steps: updatedSteps);
    }
  }

  @override
  Future<void> reportPost(String postId, String userId, String reason) async {
    await Future.delayed(_delay);
  }

  @override
  Future<void> hidePost(String postId, String userId) async {
    await Future.delayed(_delay);
  }

  @override
  Future<void> savePost(String postId, String userId) async {
    await Future.delayed(_delay);
  }

  @override
  Future<void> unsavePost(String postId, String userId) async {
    await Future.delayed(_delay);
  }
}
