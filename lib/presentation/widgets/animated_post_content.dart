import 'package:flutter/material.dart';

class AnimatedPostContent extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final bool isAnimatingOut;
  final double topOffset;
  final VoidCallback? onAnimationComplete;

  const AnimatedPostContent({
    super.key,
    required this.child,
    required this.isVisible,
    required this.topOffset,
    this.isAnimatingOut = false,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedPostContent> createState() => _AnimatedPostContentState();
}

class _AnimatedPostContentState extends State<AnimatedPostContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    if (widget.isVisible && !widget.isAnimatingOut) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedPostContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward().then((_) {
        widget.onAnimationComplete?.call();
      });
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reverse().then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight - widget.topOffset;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            top: widget.topOffset,
            bottom: 16, // Ensure space at bottom for content
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final slideValue = widget.isAnimatingOut
                  ? -_slideAnimation.value + 50.0 // Slide down when animating out
                  : _slideAnimation.value; // Slide up when animating in

              return Transform.translate(
                offset: Offset(0, slideValue),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              height: availableHeight,
              child: Center(child: widget.child),
            ),
          ),
        );
      },
    );
  }
}
