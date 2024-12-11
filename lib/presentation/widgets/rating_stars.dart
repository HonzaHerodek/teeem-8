import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final Function(double)? onRatingChanged;
  final Color? color;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 24.0,
    this.isInteractive = false,
    this.onRatingChanged,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isHalfStar = rating > index && rating < starValue;
        final isFullStar = rating >= starValue;

        return GestureDetector(
          onTapDown: isInteractive
              ? (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition =
                      box.globalToLocal(details.globalPosition);
                  final starWidth = size + 4.0; // Adding padding
                  final starCenter = (index * starWidth) + (starWidth / 2);

                  // Calculate rating based on tap position within the star
                  double newRating;
                  if (localPosition.dx < starCenter) {
                    newRating = starValue - 0.5;
                  } else {
                    newRating = starValue.toDouble();
                  }
                  onRatingChanged?.call(newRating);
                }
              : null,
          child: Icon(
            isFullStar
                ? Icons.star
                : isHalfStar
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: color ?? Theme.of(context).primaryColor,
          ),
        );
      }),
    );
  }
}

class RatingStatsDisplay extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> distribution;
  final double? userRating;
  final Function(double)? onRatingChanged;

  const RatingStatsDisplay({
    Key? key,
    required this.averageRating,
    required this.totalRatings,
    required this.distribution,
    this.userRating,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RatingStars(
              rating: averageRating,
              isInteractive: userRating != null,
              onRatingChanged: onRatingChanged,
            ),
            const SizedBox(width: 8),
            Text(
              '${averageRating.toStringAsFixed(1)} (${totalRatings} ${totalRatings == 1 ? 'rating' : 'ratings'})',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (userRating != null) ...[
          const SizedBox(height: 8),
          Text(
            'Your rating: ${userRating!.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          final starCount = 5 - index;
          final count = distribution[starCount] ?? 0;
          final percentage = totalRatings > 0
              ? (count / totalRatings * 100).toStringAsFixed(1)
              : '0.0';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  '$starCount',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 4),
                Icon(Icons.star, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: totalRatings > 0 ? count / totalRatings : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
