import 'dart:async';
import '../../core/services/rating_service.dart';
import '../../data/models/rating_model.dart';
import '../../core/services/logger_service.dart';

class MockRatingService extends RatingService {
  final Map<String, List<RatingModel>> _postRatings = {};
  final Map<String, List<RatingModel>> _userRatings = {};
  final _delay = const Duration(milliseconds: 500); // Simulate network delay

  MockRatingService({LoggerService? logger}) : super(logger: logger) {
    _initializeTestData();
  }

  void _initializeTestData() {
    // Initialize some test ratings for the test user
    final testUserId = 'user_1';
    _userRatings[testUserId] = [
      RatingModel(
          value: 4.5,
          userId: 'user_2',
          createdAt: DateTime.now().subtract(const Duration(days: 5))),
      RatingModel(
          value: 5.0,
          userId: 'user_3',
          createdAt: DateTime.now().subtract(const Duration(days: 3))),
      RatingModel(
          value: 4.0,
          userId: 'user_4',
          createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ];

    // Initialize some test ratings for posts
    for (var i = 1; i <= 5; i++) {
      final postId = 'post_$i';
      _postRatings[postId] = [
        RatingModel(
            value: 4.0,
            userId: 'user_2',
            createdAt: DateTime.now().subtract(Duration(days: i + 2))),
        RatingModel(
            value: 5.0,
            userId: 'user_3',
            createdAt: DateTime.now().subtract(Duration(days: i + 1))),
        RatingModel(
            value: 4.5,
            userId: 'user_4',
            createdAt: DateTime.now().subtract(Duration(days: i))),
      ];
    }
  }

  @override
  Future<void> ratePost(String postId, String userId, double rating) async {
    await Future.delayed(_delay);
    final newRating = RatingModel(
      value: rating,
      userId: userId,
      createdAt: DateTime.now(),
    );

    if (!_postRatings.containsKey(postId)) {
      _postRatings[postId] = [];
    }

    final ratings = _postRatings[postId]!;
    final existingIndex = ratings.indexWhere((r) => r.userId == userId);

    if (existingIndex != -1) {
      ratings[existingIndex] = newRating;
    } else {
      ratings.add(newRating);
    }
  }

  @override
  Future<void> rateUser(
      String targetUserId, String ratingUserId, double rating) async {
    await Future.delayed(_delay);
    final newRating = RatingModel(
      value: rating,
      userId: ratingUserId,
      createdAt: DateTime.now(),
    );

    if (!_userRatings.containsKey(targetUserId)) {
      _userRatings[targetUserId] = [];
    }

    final ratings = _userRatings[targetUserId]!;
    final existingIndex = ratings.indexWhere((r) => r.userId == ratingUserId);

    if (existingIndex != -1) {
      ratings[existingIndex] = newRating;
    } else {
      ratings.add(newRating);
    }
  }

  @override
  Future<RatingStats> getPostRatingStats(String postId) async {
    await Future.delayed(_delay);
    final ratings = _postRatings[postId] ?? [];
    return RatingStats.fromRatings(ratings);
  }

  @override
  Future<RatingStats> getUserRatingStats(String userId) async {
    await Future.delayed(_delay);
    final ratings = _userRatings[userId] ?? [];
    return RatingStats.fromRatings(ratings);
  }
}
