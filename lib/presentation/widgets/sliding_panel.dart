import 'package:flutter/material.dart';

class SlidingPanel extends StatefulWidget {
  final Widget child;
  final bool isOpen;
  final VoidCallback? onClose;
  final double width;
  final List<Rect>? excludeFromOverlay;

  const SlidingPanel({
    super.key,
    required this.child,
    required this.isOpen,
    this.onClose,
    this.width = 0.75,
    this.excludeFromOverlay,
  });

  @override
  State<SlidingPanel> createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _dragStartX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SlidingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartX = details.localPosition.dx;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final dragDistance = details.localPosition.dx - _dragStartX;
    final screenWidth = MediaQuery.of(context).size.width;
    final normalizedDrag = dragDistance / screenWidth;
    
    if (normalizedDrag < 0) {
      _controller.value = 1.0 + normalizedDrag;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -500 || _controller.value < 0.5) {
      widget.onClose?.call();
    } else {
      _controller.forward();
    }
  }

  bool _shouldHandleTap(Offset position) {
    if (widget.excludeFromOverlay == null) return true;
    
    for (final excludedArea in widget.excludeFromOverlay!) {
      if (excludedArea.contains(position)) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelWidth = MediaQuery.of(context).size.width * widget.width;
    const cornerRadius = 50.0;

    return Stack(
      children: [
        // Semi-transparent overlay with animation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Only show overlay when animation is in progress or panel is open
            if (_controller.value > 0) {
              return Positioned.fill(
                child: IgnorePointer(
                  ignoring: !widget.isOpen,
                  child: GestureDetector(
                    onTapDown: (details) {
                      if (_shouldHandleTap(details.localPosition)) {
                        widget.onClose?.call();
                      }
                    },
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.14 * _controller.value),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Sliding panel
        SlideTransition(
          position: _offsetAnimation,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onHorizontalDragStart: widget.isOpen ? _handleDragStart : null,
              onHorizontalDragUpdate: widget.isOpen ? _handleDragUpdate : null,
              onHorizontalDragEnd: widget.isOpen ? _handleDragEnd : null,
              child: Material(
                elevation: 16,
                color: Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(cornerRadius),
                  bottomRight: Radius.circular(cornerRadius),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(cornerRadius),
                    bottomRight: Radius.circular(cornerRadius),
                  ),
                  child: Container(
                    width: panelWidth,
                    height: double.infinity,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
