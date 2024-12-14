import 'package:flutter/material.dart';

class RatingStars extends StatefulWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final Function(double)? onRatingChanged;
  final Color? color;
  final Map<int, int>? distribution;
  final int? totalRatings;
  final bool showRatingText;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 24.0,
    this.isInteractive = false,
    this.onRatingChanged,
    this.color,
    this.distribution,
    this.totalRatings,
    this.showRatingText = false,
  }) : super(key: key);

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Fixed width to prevent layout shifts
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stars row
          GestureDetector(
            onTap: widget.distribution != null ? () {
              setState(() {
                _expanded = !_expanded;
              });
            } : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final isHalfStar = widget.rating > index && widget.rating < starValue;
                final isFullStar = widget.rating >= starValue;

                return GestureDetector(
                  onTapDown: widget.isInteractive
                      ? (details) {
                          final RenderBox box = context.findRenderObject() as RenderBox;
                          final localPosition = box.globalToLocal(details.globalPosition);
                          final starWidth = widget.size + 4.0;
                          final starCenter = (index * starWidth) + (starWidth / 2);

                          double newRating;
                          if (localPosition.dx < starCenter) {
                            newRating = starValue - 0.5;
                          } else {
                            newRating = starValue.toDouble();
                          }
                          widget.onRatingChanged?.call(newRating);
                        }
                      : null,
                  child: Icon(
                    isFullStar
                        ? Icons.star
                        : isHalfStar
                            ? Icons.star_half
                            : Icons.star_border,
                    size: widget.size,
                    color: widget.color ?? Colors.amber,
                  ),
                );
              }),
            ),
          ),

          // Expandable stats
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              heightFactor: _expanded ? 1.0 : 0.0,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                tween: Tween<double>(
                  begin: 0.0,
                  end: _expanded ? 1.0 : 0.0,
                ),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0.0, (1 - value) * -20),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showRatingText && widget.distribution != null && widget.totalRatings != null)
                        Text(
                          '${widget.rating.toStringAsFixed(1)} (${widget.totalRatings} ${widget.totalRatings == 1 ? 'rating' : 'ratings'})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.distribution != null && widget.totalRatings != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Rating Distribution',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (var i = 5; i >= 1; i--)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$i star',
                                  style: const TextStyle(color: Colors.amber),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 150,
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                    tween: Tween<double>(
                                      begin: 0,
                                      end: widget.totalRatings! > 0
                                          ? (widget.distribution![i] ?? 0) / widget.totalRatings!
                                          : 0,
                                    ),
                                    builder: (context, value, _) => LinearProgressIndicator(
                                      value: value,
                                      backgroundColor: Colors.grey[800],
                                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.distribution![i] ?? 0}',
                                  style: const TextStyle(color: Colors.amber),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
