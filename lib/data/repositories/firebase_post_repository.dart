import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class FirebasePostRepository implements PostRepository {
  final FirebaseFirestore _firestore;

  FirebasePostRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<PostModel>> getPosts({
    int? limit,
    String? startAfter,
    String? userId,
    List<String>? tags,
  }) async {
    try {
      var query =
          _firestore.collection('posts').orderBy('createdAt', descending: true);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (startAfter != null) {
        final startAfterDoc =
            await _firestore.collection('posts').doc(startAfter).get();
        query = query.startAfterDocument(startAfterDoc);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PostModel.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      throw AppException('Failed to fetch posts: ${e.toString()}');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) {
        throw NotFoundException('Post not found');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return PostModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw AppException('Failed to fetch post: ${e.toString()}');
    }
  }

  @override
  Future<void> createPost(PostModel post) async {
    try {
      final docRef = _firestore.collection('posts').doc();
      final postData = post.toJson();
      postData['id'] = docRef.id;
      await docRef.set(postData);
    } catch (e) {
      throw AppException('Failed to create post: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePost(PostModel post) async {
    try {
      await _firestore.collection('posts').doc(post.id).update(post.toJson());
    } catch (e) {
      throw AppException('Failed to update post: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw AppException('Failed to delete post: ${e.toString()}');
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw AppException('Failed to like post: ${e.toString()}');
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw AppException('Failed to unlike post: ${e.toString()}');
    }
  }

  @override
  Future<void> addComment(String postId, String userId, String comment) async {
    try {
      final commentData = {
        'userId': userId,
        'content': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(commentData);
    } catch (e) {
      throw AppException('Failed to add comment: ${e.toString()}');
    }
  }

  @override
  Future<void> removeComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      throw AppException('Failed to remove comment: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePostStep(
      String postId, String stepId, Map<String, dynamic> data) async {
    try {
      final stepData = {
        'id': stepId,
        ...data,
      };
      await _firestore.collection('posts').doc(postId).update({
        'steps': FieldValue.arrayUnion([stepData]),
      });
    } catch (e) {
      throw AppException('Failed to update post step: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('searchableText', arrayContains: query.toLowerCase())
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PostModel.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      throw AppException('Failed to search posts: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getTrendingPosts({int? limit}) async {
    try {
      var query = _firestore
          .collection('posts')
          .orderBy('likesCount', descending: true)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PostModel.fromJson(Map<String, dynamic>.from(data));
      }).toList();
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
      // In a real implementation, this would use a recommendation algorithm
      return getTrendingPosts(limit: limit);
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
      var query =
          _firestore.collection('posts').orderBy('createdAt', descending: true);

      if (startAfter != null) {
        final startAfterDoc =
            await _firestore.collection('posts').doc(startAfter).get();
        query = query.startAfterDocument(startAfterDoc);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PostModel.fromJson(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      throw AppException('Failed to get user feed: ${e.toString()}');
    }
  }

  @override
  Future<void> reportPost(String postId, String userId, String reason) async {
    try {
      await _firestore.collection('reports').add({
        'postId': postId,
        'userId': userId,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AppException('Failed to report post: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getPostAnalytics(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) {
        throw NotFoundException('Post not found');
      }

      final data = doc.data()!;
      final likes = (data['likes'] as List<dynamic>?)?.length ?? 0;
      return {
        'views': data['views'] as int? ?? 0,
        'likes': likes,
        'comments': data['commentsCount'] as int? ?? 0,
        'shares': data['sharesCount'] as int? ?? 0,
      };
    } catch (e) {
      throw AppException('Failed to get post analytics: ${e.toString()}');
    }
  }

  @override
  Future<void> hidePost(String postId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'hiddenPosts': FieldValue.arrayUnion([postId]),
      });
    } catch (e) {
      throw AppException('Failed to hide post: ${e.toString()}');
    }
  }

  @override
  Future<void> savePost(String postId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'savedPosts': FieldValue.arrayUnion([postId]),
      });
    } catch (e) {
      throw AppException('Failed to save post: ${e.toString()}');
    }
  }

  @override
  Future<void> unsavePost(String postId, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'savedPosts': FieldValue.arrayRemove([postId]),
      });
    } catch (e) {
      throw AppException('Failed to unsave post: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getPostTags(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) {
        throw NotFoundException('Post not found');
      }

      final data = doc.data()!;
      final tags = data['tags'] as List<dynamic>?;
      return tags?.map((tag) => tag.toString()).toList() ?? [];
    } catch (e) {
      throw AppException('Failed to get post tags: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePostTags(String postId, List<String> tags) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'tags': tags,
        'searchableTags': tags.map((tag) => tag.toLowerCase()).toList(),
      });
    } catch (e) {
      throw AppException('Failed to update post tags: ${e.toString()}');
    }
  }
}
