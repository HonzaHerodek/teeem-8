import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/presentation/screens/feed/feed_bloc/feed_bloc.dart';
import 'package:myapp/presentation/screens/feed/feed_bloc/feed_event.dart';
import 'dart:math' as math;
import '../models/filter_menu_item.dart';
import '../models/filter_type.dart';
import '../search/filter_search_bar.dart';

class FilterMenu extends StatefulWidget {
  final VoidCallback onGroupFilter;
  final VoidCallback onPairFilter;
  final VoidCallback onSelfFilter;
  final ValueChanged<String>? onSearch;

  const FilterMenu({
    Key? key,
    required this.onGroupFilter,
    required this.onPairFilter,
    required this.onSelfFilter,
    this.onSearch,
  }) : super(key: key);

  @override
  State<FilterMenu> createState() => _FilterMenuState();
}

class _FilterMenuState extends State<FilterMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;
  FilterType? _activeFilterType;
  bool _isSearchVisible = false;

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
      if (!_isOpen) {
        _isSearchVisible = false;
        _activeFilterType = null;
      }
    });
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handleFilterSelected(FilterType type, VoidCallback onFilter) {
    setState(() {
      _activeFilterType = type;
      _isSearchVisible = true;
    });
    onFilter();
    // Dispatch FeedSearchChanged with an empty query
    context.read<FeedBloc>().add(const FeedSearchChanged(''));
  }

  void _handleSearchClose() {
    setState(() {
      _activeFilterType = null;
      _isSearchVisible = false;
    });
  }

  Widget _buildMenuItem(FilterMenuItem item, int index, int totalItems) {
    final double radius = 80.0;
    final double startAngle = math.pi;
    final double angleStep = (math.pi / 2) / (totalItems - 1);
    final double angle = startAngle - (index * angleStep);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = _controller.value;
        final double currentRadius = radius * progress;
        final double x = currentRadius * math.cos(angle);
        final double y = currentRadius * math.sin(angle);

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.scale(
            scale: progress,
            child: Opacity(
              opacity: progress,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(item.icon, color: Colors.white),
                  tooltip: item.tooltip,
                  onPressed: () {
                    item.onPressed();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterItems = FilterMenuItem.defaultItems(
      onGroupFilter: () =>
          _handleFilterSelected(FilterType.group, widget.onGroupFilter),
      onPairFilter: () =>
          _handleFilterSelected(FilterType.pair, widget.onPairFilter),
      onSelfFilter: () =>
          _handleFilterSelected(FilterType.self, widget.onSelfFilter),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isSearchVisible && _activeFilterType != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilterSearchBar(
                filterType: _activeFilterType!,
                onSearch: (query) {
                  context.read<FeedBloc>().add(FeedSearchChanged(query));
                },
                onClose: _handleSearchClose,
              ),
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            ...filterItems.asMap().entries.map((entry) => _buildMenuItem(
                  entry.value,
                  entry.key,
                  filterItems.length,
                )),
            IconButton(
              icon: Icon(
                _isOpen ? Icons.close : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: _toggleMenu,
            ),
          ],
        ),
      ],
    );
  }
}
