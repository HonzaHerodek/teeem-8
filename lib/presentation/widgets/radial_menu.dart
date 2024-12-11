import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'circular_action_button.dart';

class RadialMenuItem {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const RadialMenuItem({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });
}

enum RadialMenuAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class RadialMenu extends StatefulWidget {
  final List<RadialMenuItem> items;
  final IconData mainIcon;
  final IconData closeIcon;
  final RadialMenuAlignment alignment;

  const RadialMenu({
    super.key,
    required this.items,
    this.mainIcon = Icons.more_vert,
    this.closeIcon = Icons.close,
    this.alignment = RadialMenuAlignment.topRight,
  });

  @override
  State<RadialMenu> createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  (double, double) _calculateOffset(double radius, double angle) {
    // Calculate base offset
    double x = radius * math.cos(angle);
    double y = radius * math.sin(angle);

    // Adjust based on alignment
    switch (widget.alignment) {
      case RadialMenuAlignment.topRight:
        return (-x, y);
      case RadialMenuAlignment.topLeft:
        return (x, y);
      case RadialMenuAlignment.bottomRight:
        return (-x, -y);
      case RadialMenuAlignment.bottomLeft:
        return (x, -y);
    }
  }

  double _getStartAngle() {
    switch (widget.alignment) {
      case RadialMenuAlignment.topRight:
        return 0; // Start from left (0°)
      case RadialMenuAlignment.topLeft:
        return 0; // Start from right (0°)
      case RadialMenuAlignment.bottomRight:
        return -math.pi / 2; // Start from top (-90°)
      case RadialMenuAlignment.bottomLeft:
        return -math.pi / 2; // Start from top (-90°)
    }
  }

  Widget _buildMenuItem(RadialMenuItem item, int index) {
    final double radius = 80.0;
    final double startAngle = _getStartAngle();
    final double angleStep = (math.pi / 2) / (widget.items.length - 1);
    final double angle = startAngle + (index * angleStep);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = _controller.value;
        final double currentRadius = radius * progress;
        final (double dx, double dy) = _calculateOffset(currentRadius, angle);
        
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
            scale: progress,
            child: Opacity(
              opacity: progress,
              child: item.tooltip != null
                ? Tooltip(
                    message: item.tooltip!,
                    child: _buildButton(item),
                  )
                : _buildButton(item),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(RadialMenuItem item) {
    return CircularActionButton(
      icon: item.icon,
      onPressed: () {
        item.onPressed();
        _toggleMenu();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(
        widget.alignment == RadialMenuAlignment.topLeft || 
        widget.alignment == RadialMenuAlignment.bottomLeft ? -1 : 1,
        widget.alignment == RadialMenuAlignment.topLeft || 
        widget.alignment == RadialMenuAlignment.topRight ? -1 : 1,
      ),
      children: [
        // Menu items
        ...widget.items.asMap().entries.map((entry) => 
          _buildMenuItem(entry.value, entry.key),
        ),
        // Main menu button
        CircularActionButton(
          icon: _isOpen ? widget.closeIcon : widget.mainIcon,
          onPressed: _toggleMenu,
        ),
      ],
    );
  }
}
