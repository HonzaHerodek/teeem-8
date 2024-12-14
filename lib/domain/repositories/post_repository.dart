import '../../data/models/post_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> getPosts({
    int? limit,
    String? startAfter,
    String? userId,
    List<String>? tags,
  });

  Future<PostModel> getPostById(String postId);

  Future<void> createPost(PostModel post);

  Future<void> updatePost(PostModel post);

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId, String userId);

  Future<void> unlikePost(String postId, String userId);

  Future<void> addComment(String postId, String userId, String comment);

  Future<void> removeComment(String postId, String commentId);

  Future<void> updatePostStep(
    String postId,
    String stepId,
    Map<String, dynamic> data,
  );

  Future<List<PostModel>> searchPosts(String query);

  Future<List<PostModel>> getTrendingPosts({int? limit});

  Future<List<PostModel>> getRecommendedPosts({
    required String userId,
    int? limit,
  });

  Future<List<PostModel>> getUserFeed({
    required String userId,
    int? limit,
    String? startAfter,
  });

  Future<void> reportPost(String postId, String userId, String reason);

  Future<Map<String, dynamic>> getPostAnalytics(String postId);

  Future<void> hidePost(String postId, String userId);

  Future<void> savePost(String postId, String userId);

  Future<void> unsavePost(String postId, String userId);

  Future<List<String>> getPostTags(String postId);

  Future<void> updatePostTags(String postId, List<String> tags);
}
