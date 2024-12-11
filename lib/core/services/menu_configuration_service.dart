import 'package:flutter/material.dart';
import '../../presentation/widgets/radial_menu.dart';
import 'feed_filter_service.dart';

class MenuConfiguration {
  final List<RadialMenuItem> items;
  final IconData mainIcon;
  final IconData closeIcon;

  const MenuConfiguration({
    required this.items,
    required this.mainIcon,
    this.closeIcon = Icons.close,
  });
}

class MenuConfigurationService {
  MenuConfiguration getFeedTopRightMenu({
    required void Function(FilterType) onFilterSelected,
  }) {
    return MenuConfiguration(
      mainIcon: Icons.filter_list,
      items: [
        RadialMenuItem(
          icon: Icons.groups,
          onPressed: () => onFilterSelected(FilterType.group),
          tooltip: 'Group Posts',
        ),
        RadialMenuItem(
          icon: Icons.people,
          onPressed: () => onFilterSelected(FilterType.pair),
          tooltip: 'Pair Posts',
        ),
        RadialMenuItem(
          icon: Icons.person,
          onPressed: () => onFilterSelected(FilterType.self),
          tooltip: 'Individual Posts',
        ),
      ],
    );
  }

  // Add more menu configurations here as needed
  // Example:
  // MenuConfiguration getProfileMenu({
  //   required void Function() onSettingsPressed,
  //   required void Function() onLogoutPressed,
  // }) {
  //   return MenuConfiguration(
  //     mainIcon: Icons.more_vert,
  //     items: [
  //       RadialMenuItem(
  //         icon: Icons.settings,
  //         onPressed: onSettingsPressed,
  //         tooltip: 'Settings',
  //       ),
  //       RadialMenuItem(
  //         icon: Icons.logout,
  //         onPressed: onLogoutPressed,
  //         tooltip: 'Logout',
  //       ),
  //     ],
  //   );
  // }
}
