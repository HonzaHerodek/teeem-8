import 'package:json_annotation/json_annotation.dart';

part 'rating_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RatingModel {
  final double value; // 1-5 stars
  final String userId;
  final DateTime createdAt;

  RatingModel({
    required this.value,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RatingModel.fromJson(Map<String, dynamic> json) =>
      _$RatingModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);

  RatingModel copyWith({
    double? value,
    String? userId,
    DateTime? createdAt,
  }) {
    return RatingModel(
      value: value ?? this.value,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<int, int>
      ratingDistribution; // Maps star count (1-5) to number of ratings

  RatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory RatingStats.fromRatings(List<RatingModel> ratings) {
    if (ratings.isEmpty) {
      return RatingStats(
        averageRating: 0,
        totalRatings: 0,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }

    var distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    var sum = 0.0;

    for (var rating in ratings) {
      sum += rating.value;
      distribution[rating.value.round()] =
          (distribution[rating.value.round()] ?? 0) + 1;
    }

    return RatingStats(
      averageRating: sum / ratings.length,
      totalRatings: ratings.length,
      ratingDistribution: distribution,
    );
  }

  factory RatingStats.fromJson(Map<String, dynamic> json) =>
      _$RatingStatsFromJson(json);

  Map<String, dynamic> toJson() => _$RatingStatsToJson(this);
}
