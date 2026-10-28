import 'package:flutter/material.dart';

import '../layout.dart';
import '../page_text.dart';
import '../strings.dart';
import 'selectable_tile.dart';

typedef SidebarDestination = ({
  String route,
  String label,
  IconData icon,
  IconData selectedIcon,
});

/// Desktop navigation: app name at the top, labelled pages in the middle,
/// and the school (opens its profile) plus log out at the bottom.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.schoolName,
    required this.onOpenSchool,
    required this.onLogOut,
  });

  final List<SidebarDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String schoolName;
  final VoidCallback onOpenSchool;
  final VoidCallback onLogOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: Space.sidebarWidth,
      color: colors.surfaceContainerLow,
      padding: const EdgeInsets.all(Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xs,
              Space.xs,
              Space.xs,
              Space.md,
            ),
            child: Row(
              children: [
                Icon(Icons.accessible_forward, color: colors.primary, size: 32),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    AppStrings.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Semantics(
              label: PageText.mainNavigation,
              container: true,
              child: ListView(
                children: [
                  for (final (index, destination) in destinations.indexed)
                    SelectableTile(
                      icon: index == selectedIndex
                          ? destination.selectedIcon
                          : destination.icon,
                      label: destination.label,
                      isSelected: index == selectedIndex,
                      onTap: () => onSelected(index),
                    ),
                ],
              ),
            ),
          ),
          const Divider(),
          if (schoolName.isNotEmpty)
            SelectableTile(
              icon: Icons.school_outlined,
              label: schoolName,
              isSelected: false,
              onTap: onOpenSchool,
              semanticsHint: PageText.openSchoolProfile,
            ),
          SelectableTile(
            icon: Icons.logout,
            label: AppStrings.logOut,
            isSelected: false,
            onTap: onLogOut,
          ),
        ],
      ),
    );
  }
}
