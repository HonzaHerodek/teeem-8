import 'package:flutter/material.dart';

class SlidingPanel extends StatefulWidget {
  final Widget child;
  final bool isOpen;
  final VoidCallback? onClose;
  final double width;

  const SlidingPanel({
    super.key,
    required this.child,
    required this.isOpen,
    this.onClose,
    this.width = 0.75, // 75% of screen width by default
  });

  @override
  State<SlidingPanel> createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay
        if (widget.isOpen)
          GestureDetector(
            onTap: widget.onClose,
            child: AnimatedOpacity(
              opacity: widget.isOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black,
              ),
            ),
          ),
        // Sliding panel
        SlideTransition(
          position: _offsetAnimation,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              elevation: 16,
              child: Container(
                width: MediaQuery.of(context).size.width * widget.width,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
