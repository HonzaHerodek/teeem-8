import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/rating_service.dart';
import '../../core/services/logger_service.dart';
import '../../data/models/rating_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';

class FirebaseRatingService extends RatingService {
  final FirebaseFirestore _firestore;

  FirebaseRatingService({
    required FirebaseFirestore firestore,
    LoggerService? logger,
  })  : _firestore = firestore,
        super(logger: logger);

  @override
  Future<void> ratePost(String postId, String userId, double rating) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);

      final newRating = RatingModel(
        value: rating,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('Post not found');
        }

        final post = PostModel.fromJson(postDoc.data()!);
        final existingRatingIndex =
            post.ratings.indexWhere((r) => r.userId == userId);

        List<RatingModel> updatedRatings;
        if (existingRatingIndex != -1) {
          updatedRatings = List.from(post.ratings);
          updatedRatings[existingRatingIndex] = newRating;
        } else {
          updatedRatings = [...post.ratings, newRating];
        }

        transaction.update(postRef, {
          'ratings': updatedRatings.map((r) => r.toJson()).toList(),
        });
      });

      logger.i('Successfully rated post: $postId');
    } catch (e) {
      logger.e('Error rating post: $e');
      rethrow;
    }
  }

  @override
  Future<void> rateUser(
      String targetUserId, String ratingUserId, double rating) async {
    try {
      final userRef = _firestore.collection('users').doc(targetUserId);

      final newRating = RatingModel(
        value: rating,
        userId: ratingUserId,
        createdAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final user = UserModel.fromJson(userDoc.data()!);
        final existingRatingIndex =
            user.ratings.indexWhere((r) => r.userId == ratingUserId);

        List<RatingModel> updatedRatings;
        if (existingRatingIndex != -1) {
          updatedRatings = List.from(user.ratings);
          updatedRatings[existingRatingIndex] = newRating;
        } else {
          updatedRatings = [...user.ratings, newRating];
        }

        transaction.update(userRef, {
          'ratings': updatedRatings.map((r) => r.toJson()).toList(),
        });
      });

      logger.i('Successfully rated user: $targetUserId');
    } catch (e) {
      logger.e('Error rating user: $e');
      rethrow;
    }
  }

  @override
  Future<RatingStats> getPostRatingStats(String postId) async {
    try {
      final postDoc = await _firestore.collection('posts').doc(postId).get();
      if (!postDoc.exists) {
        throw Exception('Post not found');
      }

      final post = PostModel.fromJson(postDoc.data()!);
      final ratings = post.ratings;
      
      if (ratings.isEmpty) {
        return RatingStats(
          averageRating: 0,
          totalRatings: 0,
          ratingDistribution: {},
        );
      }

      final totalRatings = ratings.length;
      final sumRatings = ratings.fold<double>(0, (sum, rating) => sum + rating.value);
      final averageRating = sumRatings / totalRatings;

      final distribution = <int, int>{};
      for (final rating in ratings) {
        final value = rating.value.round();
        distribution[value] = (distribution[value] ?? 0) + 1;
      }

      return RatingStats(
        averageRating: averageRating,
        totalRatings: totalRatings,
        ratingDistribution: distribution,
      );
    } catch (e) {
      logger.e('Error getting post rating stats: $e');
      rethrow;
    }
  }

  @override
  Future<RatingStats> getUserRatingStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final user = UserModel.fromJson(userDoc.data()!);
      final ratings = user.ratings;
      
      if (ratings.isEmpty) {
        return RatingStats(
          averageRating: 0,
          totalRatings: 0,
          ratingDistribution: {},
        );
      }

      final totalRatings = ratings.length;
      final sumRatings = ratings.fold<double>(0, (sum, rating) => sum + rating.value);
      final averageRating = sumRatings / totalRatings;

      final distribution = <int, int>{};
      for (final rating in ratings) {
        final value = rating.value.round();
        distribution[value] = (distribution[value] ?? 0) + 1;
      }

      return RatingStats(
        averageRating: averageRating,
        totalRatings: totalRatings,
        ratingDistribution: distribution,
      );
    } catch (e) {
      logger.e('Error getting user rating stats: $e');
      rethrow;
    }
  }
}
