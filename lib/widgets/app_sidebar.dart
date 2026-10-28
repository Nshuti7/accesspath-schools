import 'package:flutter/material.dart';

import '../layout.dart';
import '../page_text.dart';
import '../strings.dart';

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
                    _SidebarItem(
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
            _SidebarItem(
              icon: Icons.school_outlined,
              label: schoolName,
              isSelected: false,
              onTap: onOpenSchool,
              semanticsHint: PageText.openSchoolProfile,
            ),
          _SidebarItem(
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.semanticsHint,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = isSelected
        ? colors.onPrimaryContainer
        : colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs / 2),
      child: Semantics(
        button: true,
        selected: isSelected,
        hint: semanticsHint,
        child: Material(
          // Filled background plus bold text and a bar, never colour alone.
          color: isSelected ? colors.primaryContainer : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            focusColor: colors.primary.withValues(alpha: 0.16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isSelected ? colors.primary : Colors.transparent,
                    width: 4,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icon, color: isSelected ? colors.primary : foreground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: foreground,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
