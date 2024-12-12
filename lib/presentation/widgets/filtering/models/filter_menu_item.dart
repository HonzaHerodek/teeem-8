import 'package:flutter/material.dart';
import 'filter_type.dart';

class FilterMenuItem {
  final FilterType type;
  final VoidCallback onPressed;

  const FilterMenuItem({
    required this.type,
    required this.onPressed,
  });

  IconData get icon => type.icon;
  String get tooltip => type.displayName;

  static List<FilterMenuItem> defaultItems({
    required VoidCallback onGroupFilter,
    required VoidCallback onPairFilter,
    required VoidCallback onSelfFilter,
  }) {
    return [
      FilterMenuItem(
        type: FilterType.group,
        onPressed: onGroupFilter,
      ),
      FilterMenuItem(
        type: FilterType.pair,
        onPressed: onPairFilter,
      ),
      FilterMenuItem(
        type: FilterType.self,
        onPressed: onSelfFilter,
      ),
    ];
  }
}
