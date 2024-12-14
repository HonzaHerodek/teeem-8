import 'package:flutter/material.dart';

enum FilterType {
  none,
  group,
  pair,
  self,
}

extension FilterTypeExtension on FilterType {
  String get displayName {
    switch (this) {
      case FilterType.none:
        return 'All Posts';
      case FilterType.group:
        return 'Group Posts';
      case FilterType.pair:
        return 'Pair Posts';
      case FilterType.self:
        return 'Individual Posts';
    }
  }

  String get searchPlaceholder {
    switch (this) {
      case FilterType.none:
        return 'Search all posts...';
      case FilterType.group:
        return 'Search in group posts...';
      case FilterType.pair:
        return 'Search in pair posts...';
      case FilterType.self:
        return 'Search in individual posts...';
    }
  }

  IconData get icon {
    switch (this) {
      case FilterType.none:
        return Icons.filter_list;
      case FilterType.group:
        return Icons.groups;
      case FilterType.pair:
        return Icons.people;
      case FilterType.self:
        return Icons.person;
    }
  }
}
