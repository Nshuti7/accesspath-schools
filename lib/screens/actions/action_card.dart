import 'package:flutter/material.dart';

import '../../models/action_item.dart';
import '../../strings.dart';
import '../../widgets/status_badge.dart';

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.action,
    required this.now,
    required this.onTap,
  });

  final ActionItem action;

  /// Passed in so every card in the list uses the same "today".
  final DateTime now;
  final VoidCallback onTap;

  static String statusLabel(String status) {
    return switch (status) {
      ActionItem.statusInProgress => AppStrings.statusInProgress,
      ActionItem.statusDone => AppStrings.statusDone,
      _ => AppStrings.statusTodo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isOverdue = action.isOverdueOn(now);
    final (badgeBackground, badgeForeground) = switch (action.status) {
      ActionItem.statusDone => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      ActionItem.statusInProgress => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      _ => (colors.surfaceContainerHighest, colors.onSurface),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      // A red outline as well as the "Overdue" text, never colour alone.
      shape: isOverdue
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.error, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      action.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: statusLabel(action.status),
                    background: badgeBackground,
                    foreground: badgeForeground,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person_outline, color: colors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action.ownerName,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.event_outlined,
                    color: isOverdue ? colors.error : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOverdue
                          ? AppStrings.overdue(action.dueDate)
                          : AppStrings.due(action.dueDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isOverdue ? colors.error : null,
                        fontWeight: isOverdue ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (action.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  action.notes,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
