import 'package:flutter/material.dart';

import '../../models/assessment_area.dart';
import '../../models/checklist_item.dart';
import '../../models/gap.dart';
import '../../strings.dart';

class GapCard extends StatelessWidget {
  const GapCard({super.key, required this.gap, required this.item});

  final Gap gap;

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
                _Badge(
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
                _Badge(
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              // Enabled once the Action tracker exists.
              child: TextButton.icon(
                onPressed: null,
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final badgeIcon = icon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeIcon != null) ...[
            Icon(badgeIcon, size: 18, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
