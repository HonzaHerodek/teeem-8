import 'package:flutter/material.dart';
import 'filter_type.dart';

class FilterMenuItem {
  final String tooltip;
  final IconData icon;
  final FilterType filterType;
  final VoidCallback onPressed;

  FilterMenuItem({
    required this.tooltip,
    required this.icon,
    required this.filterType,
    required this.onPressed,
  });

  static List<FilterMenuItem> defaultItems({
    required VoidCallback onGroupFilter,
    required VoidCallback onPairFilter,
    required VoidCallback onSelfFilter,
  }) {
    return [
      FilterMenuItem(
        tooltip: 'Group Posts',
        icon: Icons.groups,
        filterType: FilterType.group,
        onPressed: onGroupFilter,
      ),
      FilterMenuItem(
        tooltip: 'Pair Posts',
        icon: Icons.people,
        filterType: FilterType.pair,
        onPressed: onPairFilter,
      ),
      FilterMenuItem(
        tooltip: 'Individual Posts',
        icon: Icons.person,
        filterType: FilterType.self,
        onPressed: onSelfFilter,
      ),
    ];
  }
}
