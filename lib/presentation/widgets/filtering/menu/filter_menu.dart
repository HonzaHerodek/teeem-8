import 'package:flutter/material.dart';
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
    print('_toggleMenu called, current _isOpen: $_isOpen');
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
        _isSearchVisible = false;
        _activeFilterType = null;
      }
    });
    print('After toggle - _isOpen: $_isOpen, _isSearchVisible: $_isSearchVisible');
  }

  void _handleFilterSelected(FilterType type, VoidCallback onFilter) {
    print('_handleFilterSelected called with type: ${type.displayName}');
    setState(() {
      _activeFilterType = type;
      _isSearchVisible = true;
    });
    onFilter();
    print(
        'After filter selection - _activeFilterType: ${_activeFilterType?.displayName}, _isSearchVisible: $_isSearchVisible');
  }

  void _handleSearchClose() {
    print('_handleSearchClose called');
    setState(() {
      _activeFilterType = null;
      _isSearchVisible = false;
    });
    print('After search close - _activeFilterType: null, _isSearchVisible: false');
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
                    print('Filter menu item clicked: ${item.type.displayName}');
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

    print(
        'FilterMenu build - _isSearchVisible: $_isSearchVisible, _activeFilterType: ${_activeFilterType?.displayName}');

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 48,
      child: Stack(
        alignment: Alignment.centerRight,
        clipBehavior: Clip.none,
        children: [
          // TODO: Implement the search bar with chips to appear next to the filtering menu (on the left side). All components (including search bar) except for chips exist. The search bar doesn't show. - BUG Also, there shouldn't be row bar on top of the screen.
          // Search Bar
          if (_isSearchVisible && _activeFilterType != null)
            Positioned(
              right: 48, // Positioned to the left of the filtering area
              child: Container(
                width: 300,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FilterSearchBar(
                  filterType: _activeFilterType!,
                  onSearch: widget.onSearch ?? (_) {},
                  onClose: _handleSearchClose,
                ),
              ),
            ),
          // Menu Button and Items
          Positioned(
            right: 0,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...filterItems.asMap().entries.map(
                        (entry) => _buildMenuItem(
                            entry.value, entry.key, filterItems.length),
                      ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isOpen ? Icons.close : Icons.filter_list,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMenu,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
