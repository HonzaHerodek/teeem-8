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
    // Close the radial menu
    setState(() {
      _isOpen = false;
      _activeFilterType = type;
      _isSearchVisible = true;
    });
    _controller.reverse().then((_) {
      // After menu closes, show search bar
      onFilter();
      // Clear any existing search
      context.read<FeedBloc>().add(const FeedSearchChanged(''));
    });
  }

  void _handleSearchClose() {
    setState(() {
      _activeFilterType = null;
      _isSearchVisible = false;
    });
    // Reset search when closing
    context.read<FeedBloc>().add(const FeedSearchChanged(''));
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
                decoration: BoxDecoration(
                  color: _activeFilterType == item.filterType
                      ? Colors.pink
                      : Colors.pink.withOpacity(0.5),
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

    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isSearchVisible && _activeFilterType != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterSearchBar(
                  key: ValueKey(_activeFilterType),
                  filterType: _activeFilterType!,
                  onSearch: (query) {
                    context.read<FeedBloc>().add(FeedSearchChanged(query));
                  },
                  onClose: _handleSearchClose,
                ),
              ),
            )
          else
            const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isSearchVisible ? Colors.pink : Colors.transparent,
            ),
            child: IconButton(
              icon: Icon(
                _isOpen ? Icons.close : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: _toggleMenu,
            ),
          ),
          const SizedBox(width: 8),
          ...filterItems.asMap().entries.map((entry) => _buildMenuItem(
                entry.value,
                entry.key,
                filterItems.length,
              )),
        ],
      ),
    );
  }
}
