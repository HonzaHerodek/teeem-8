import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'circular_action_button.dart';

class RadialFilterMenu extends StatefulWidget {
  final VoidCallback onGroupFilter;
  final VoidCallback onPairFilter;
  final VoidCallback onSelfFilter;

  const RadialFilterMenu({
    super.key,
    required this.onGroupFilter,
    required this.onPairFilter,
    required this.onSelfFilter,
  });

  @override
  State<RadialFilterMenu> createState() => _RadialFilterMenuState();
}

class _RadialFilterMenuState extends State<RadialFilterMenu>
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

  Widget _buildFilterButton(double angle, IconData icon, VoidCallback onPressed) {
    final double radius = 80.0;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = _controller.value;
        final double currentRadius = radius * progress;
        
        return Transform.translate(
          offset: Offset(
            -currentRadius * math.cos(angle), // Negative X to move left from top-right
            currentRadius * math.sin(angle),
          ),
          child: Transform.scale(
            scale: progress,
            child: Opacity(
              opacity: progress,
              child: CircularActionButton(
                icon: icon,
                onPressed: () {
                  onPressed();
                  _toggleMenu();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        // Group filter button (left)
        _buildFilterButton(
          0, // 0 degrees (left)
          Icons.groups,
          widget.onGroupFilter,
        ),
        // Pair filter button (bottom-left)
        _buildFilterButton(
          math.pi / 4, // 45 degrees
          Icons.people,
          widget.onPairFilter,
        ),
        // Self filter button (bottom)
        _buildFilterButton(
          math.pi / 2, // 90 degrees (down)
          Icons.person,
          widget.onSelfFilter,
        ),
        // Main filter button
        CircularActionButton(
          icon: _isOpen ? Icons.close : Icons.filter_list,
          onPressed: _toggleMenu,
        ),
      ],
    );
  }
}
