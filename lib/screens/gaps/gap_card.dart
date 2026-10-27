import 'package:flutter/material.dart';

import '../../models/action_item.dart';
import '../../models/assessment_area.dart';
import '../../models/checklist_item.dart';
import '../../models/gap.dart';
import '../../strings.dart';
import '../../widgets/status_badge.dart';

class GapCard extends StatelessWidget {
  const GapCard({
    super.key,
    required this.gap,
    required this.item,
    required this.action,
    required this.onAssign,
  });

  final Gap gap;

  /// The action assigned to fix this gap, if there is one.
  final ActionItem? action;
  final VoidCallback onAssign;

  /// The linked checklist item, used for the guide page. Null if the item was
  /// removed from checklist.json after the gap was saved.
  final ChecklistItem? item;

  static String statusLabel(String status) {
    return switch (status) {
      Gap.statusNeedsVerification => AppStrings.statusNeedsVerification,
      Gap.statusVerified => AppStrings.statusVerified,
      Gap.statusResolved => AppStrings.statusResolved,
      _ => AppStrings.statusOpen,
    };
  }

  String? get _guideLabel {
    final linked = item;
    if (linked == null || linked.guideRef == 'TODO') return null;
    final page = '${AppStrings.guidePage} ${linked.guideRef}';
    return linked.isRecommendation
        ? '$page  ·  ${AppStrings.moesRecommendation}'
        : page;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final isPhoto = gap.source == Gap.sourceAiPhoto;
    final areaName = AssessmentArea.byId(gap.area)?.name ?? gap.area;
    final guideLabel = _guideLabel;
    final assigned = action;
    final recommendation = item?.recommendation ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  label: isPhoto
                      ? AppStrings.sourceAiPhoto
                      : AppStrings.sourceChecklist,
                  icon: isPhoto ? Icons.photo_camera_outlined : Icons.checklist,
                  background: isPhoto
                      ? colors.tertiaryContainer
                      : colors.secondaryContainer,
                  foreground: isPhoto
                      ? colors.onTertiaryContainer
                      : colors.onSecondaryContainer,
                ),
                StatusBadge(
                  label: statusLabel(gap.status),
                  background: colors.surfaceContainerHighest,
                  foreground: colors.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              gap.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(areaName, style: mutedStyle),
            if (guideLabel != null) Text(guideLabel, style: mutedStyle),
            if (gap.aiDescription.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(AppStrings.photoCheckSaw, style: mutedStyle),
              Text(gap.aiDescription, style: theme.textTheme.bodyLarge),
            ],
            if (recommendation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(AppStrings.whatToDo, style: mutedStyle),
              Text(recommendation, style: theme.textTheme.bodyLarge),
            ],
            const SizedBox(height: 8),
            if (assigned != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.assignedTo(
                          assigned.ownerName,
                          assigned.dueDate,
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            // Resolved gaps need no new action.
            else if (!gap.isResolved)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAssign,
                  icon: const Icon(Icons.person_add_alt_outlined),
                  label: const Text(AppStrings.assign),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
