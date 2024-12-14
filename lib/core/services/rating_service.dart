import '../../data/models/rating_model.dart';
import 'logger_service.dart';

abstract class RatingService {
  final LoggerService _logger;

  RatingService({LoggerService? logger}) : _logger = logger ?? LoggerService();

  LoggerService get logger => _logger;

  Future<void> ratePost(String postId, String userId, double rating);
  Future<void> rateUser(
      String targetUserId, String ratingUserId, double rating);
  Future<RatingStats> getPostRatingStats(String postId);
  Future<RatingStats> getUserRatingStats(String userId);
}
