import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class JsonPostRepository implements PostRepository {
  static const String _postsDir = 'posts';

  Future<Directory> get _directory async {
    final appDir = await getApplicationDocumentsDirectory();
    final postsDir = Directory('${appDir.path}/$_postsDir');
    if (!await postsDir.exists()) {
      await postsDir.create(recursive: true);
    }
    return postsDir;
  }

  String _getPostFileName(String postId) => '$postId.json';

  Future<File> _getPostFile(String postId) async {
    final dir = await _directory;
    return File('${dir.path}/${_getPostFileName(postId)}');
  }

  @override
  Future<List<PostModel>> getPosts({
    int? limit,
    String? startAfter,
    String? userId,
    List<String>? tags,
  }) async {
    try {
      final dir = await _directory;
      final files = await dir.list().toList();
      var posts = await Future.wait(
        files.whereType<File>().map((file) async {
          final content = await file.readAsString();
          final Map<String, dynamic> jsonData = json.decode(content) as Map<String, dynamic>;
          return PostModel.fromJson(jsonData);
        }),
      );

      // Apply filters
      if (userId != null) {
        posts = posts.where((post) => post.userId == userId).toList();
      }

      if (tags != null && tags.isNotEmpty) {
        posts = posts.where((post) {
          final postTags = post.aiMetadata?['tags'] as List<dynamic>?;
          return postTags?.any((tag) => tags.contains(tag.toString())) ?? false;
        }).toList();
      }

      // Sort by creation date
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply pagination
      if (startAfter != null) {
        final startIndex = posts.indexWhere((post) => post.id == startAfter);
        if (startIndex != -1 && startIndex < posts.length - 1) {
          posts = posts.sublist(startIndex + 1);
        }
      }

      if (limit != null && posts.length > limit) {
        posts = posts.sublist(0, limit);
      }

      return posts;
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final file = await _getPostFile(postId);
      if (!await file.exists()) {
        throw Exception('Post not found');
      }
      final content = await file.readAsString();
      final Map<String, dynamic> jsonData = json.decode(content) as Map<String, dynamic>;
      return PostModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to fetch post: $e');
    }
  }

  @override
  Future<void> createPost(PostModel post) async {
    try {
      final file = await _getPostFile(post.id);
      await file.writeAsString(json.encode(post.toJson()));
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> updatePost(PostModel post) async {
    try {
      final file = await _getPostFile(post.id);
      if (!await file.exists()) {
        throw Exception('Post not found');
      }
      await file.writeAsString(json.encode(post.toJson()));
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final file = await _getPostFile(postId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    final post = await getPostById(postId);
    if (!post.likes.contains(userId)) {
      final updatedPost = post.copyWith(
        likes: [...post.likes, userId],
      );
      await updatePost(updatedPost);
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    final post = await getPostById(postId);
    if (post.likes.contains(userId)) {
      final updatedPost = post.copyWith(
        likes: post.likes.where((id) => id != userId).toList(),
      );
      await updatePost(updatedPost);
    }
  }

  @override
  Future<void> addComment(String postId, String userId, String comment) async {
    final post = await getPostById(postId);
    final updatedPost = post.copyWith(
      comments: [...post.comments, comment],
    );
    await updatePost(updatedPost);
  }

  @override
  Future<void> removeComment(String postId, String commentId) async {
    final post = await getPostById(postId);
    final updatedPost = post.copyWith(
      comments: post.comments.where((id) => id != commentId).toList(),
    );
    await updatePost(updatedPost);
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    final posts = await getPosts();
    final queryLower = query.toLowerCase();
    return posts.where((post) {
      final searchableContent = [
        post.title,
        post.description,
        ...post.steps.map((step) => step.title),
        ...post.steps.map((step) => step.description),
      ].join(' ').toLowerCase();
      return searchableContent.contains(queryLower);
    }).toList();
  }

  @override
  Future<List<PostModel>> getTrendingPosts({int? limit}) async {
    final posts = await getPosts();
    posts.sort((a, b) {
      final aScore = a.likes.length * 2 + a.comments.length;
      final bScore = b.likes.length * 2 + b.comments.length;
      return bScore.compareTo(aScore);
    });
    if (limit != null && posts.length > limit) {
      return posts.sublist(0, limit);
    }
    return posts;
  }

  @override
  Future<List<PostModel>> getRecommendedPosts({
    required String userId,
    int? limit,
  }) async {
    // For now, just return trending posts
    return getTrendingPosts(limit: limit);
  }

  @override
  Future<List<PostModel>> getUserFeed({
    required String userId,
    int? limit,
    String? startAfter,
  }) async {
    return getPosts(
      limit: limit,
      startAfter: startAfter,
      userId: userId,
    );
  }

  @override
  Future<void> reportPost(String postId, String userId, String reason) async {
    // Implementation for reporting posts could be added here
  }

  @override
  Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    // Basic analytics implementation
    final post = await getPostById(postId);
    return {
      'likes': post.likes.length,
      'comments': post.comments.length,
    };
  }

  @override
  Future<void> hidePost(String postId, String userId) async {
    // Implementation for hiding posts could be added here
  }

  @override
  Future<void> savePost(String postId, String userId) async {
    // Implementation for saving posts could be added here
  }

  @override
  Future<void> unsavePost(String postId, String userId) async {
    // Implementation for unsaving posts could be added here
  }

  @override
  Future<List<String>> getPostTags(String postId) async {
    final post = await getPostById(postId);
    final tags = post.aiMetadata?['tags'] as List<dynamic>?;
    return tags?.map((tag) => tag.toString()).toList() ?? [];
  }

  @override
  Future<void> updatePostTags(String postId, List<String> tags) async {
    final post = await getPostById(postId);
    final updatedPost = post.copyWith(
      aiMetadata: {
        ...?post.aiMetadata,
        'tags': tags,
      },
    );
    await updatePost(updatedPost);
  }

  @override
  Future<void> updatePostStep(
    String postId,
    String stepId,
    Map<String, dynamic> data,
  ) async {
    final post = await getPostById(postId);
    final updatedSteps = post.steps.map((step) {
      if (step.id == stepId) {
        return PostStep(
          id: stepId,
          title: data['title'] as String? ?? step.title,
          description: data['description'] as String? ?? step.description,
          type: data['type'] as StepType? ?? step.type,
          content: data['content'] as Map<String, dynamic>? ?? step.content,
        );
      }
      return step;
    }).toList();

    final updatedPost = post.copyWith(steps: updatedSteps);
    await updatePost(updatedPost);
  }
}
