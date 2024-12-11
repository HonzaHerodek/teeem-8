import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final bool enabled;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final theme = Theme.of(context);
    final defaultBaseColor = theme.brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;
    final defaultHighlightColor = theme.brightness == Brightness.light
        ? Colors.grey[100]!
        : Colors.grey[600]!;

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBaseColor,
      highlightColor: highlightColor ?? defaultHighlightColor,
      period: period,
      child: child,
    );
  }
}

class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? margin;
  final Color? color;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class PostCardShimmer extends StatelessWidget {
  final EdgeInsets padding;
  final double borderRadius;

  const PostCardShimmer({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const ShimmerContainer(
                  width: 40,
                  height: 40,
                  borderRadius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerContainer(
                        width: 120,
                        height: 16,
                      ),
                      const SizedBox(height: 4),
                      ShimmerContainer(
                        width: 80,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            const ShimmerContainer(
              height: 16,
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            const ShimmerContainer(
              height: 16,
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            ShimmerContainer(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            const SizedBox(height: 16),

            // Steps Preview
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return const ShimmerContainer(
                    width: 80,
                    height: 80,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Action Bar
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                3,
                (index) => const ShimmerContainer(
                  width: 60,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;
  final double spacing;
  final bool scrollable;

  const ListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      itemCount,
      (index) => ShimmerContainer(
        width: double.infinity,
        height: itemHeight,
        margin: EdgeInsets.only(bottom: spacing),
      ),
    );

    if (scrollable) {
      return ListView(
        padding: padding,
        children: items,
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        children: items,
      ),
    );
  }
}

class GridShimmer extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;
  final EdgeInsets padding;
  final double spacing;
  final bool scrollable;

  const GridShimmer({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 1,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 16,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final grid = GridView.builder(
      padding: padding,
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerContainer();
      },
    );

    return ShimmerLoading(child: grid);
  }
}
