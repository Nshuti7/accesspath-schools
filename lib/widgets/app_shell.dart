import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import '../strings.dart';

/// Main navigation: a side rail on wide screens (tablet, laptop browser) and a
/// bottom bar on phones, where the thumb can reach it.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  /// Wide enough for the rail plus a comfortable content column.
  static const wideBreakpoint = 800.0;

  static const _destinations = [
    (
      route: AppRoutes.dashboard,
      label: AppStrings.navDashboard,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    (
      route: AppRoutes.areas,
      label: AppStrings.navAssess,
      icon: Icons.fact_check_outlined,
      selectedIcon: Icons.fact_check,
    ),
    (
      route: AppRoutes.gaps,
      label: AppStrings.navGaps,
      icon: Icons.report_outlined,
      selectedIcon: Icons.report,
    ),
    (
      route: AppRoutes.actions,
      label: AppStrings.navActions,
      icon: Icons.task_alt_outlined,
      selectedIcon: Icons.task_alt,
    ),
    (
      route: AppRoutes.guide,
      label: AppStrings.navGuide,
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
    ),
  ];

  final String location;
  final Widget child;

  /// Sub-pages keep their section highlighted, e.g. a checklist under Assess.
  int get _selectedIndex {
    for (var i = _destinations.length - 1; i > 0; i--) {
      if (location.startsWith(_destinations[i].route)) return i;
    }
    return 0;
  }

  void _onSelected(BuildContext context, int index) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= wideBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _onSelected(context, index),
              labelType: NavigationRailLabelType.all,
              groupAlignment: -1,
              destinations: [
                for (final destination in _destinations)
                  NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => _onSelected(context, index),
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
