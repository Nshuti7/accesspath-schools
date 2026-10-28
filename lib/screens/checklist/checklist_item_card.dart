import 'package:flutter/material.dart';

import '../../models/answer.dart';
import '../../models/checklist_item.dart';
import '../../strings.dart';
import 'answer_buttons.dart';

class ChecklistItemCard extends StatelessWidget {
  const ChecklistItemCard({
    super.key,
    required this.item,
    required this.answer,
    required this.onAnswer,
    required this.onPhotoCheck,
  });

  final ChecklistItem item;
  final AnswerValue? answer;
  final ValueChanged<AnswerValue> onAnswer;
  final VoidCallback onPhotoCheck;

  String get _sourceLabel {
    final parts = [
      if (item.guideRef != 'TODO') '${AppStrings.guidePage} ${item.guideRef}',
      if (item.isRecommendation) AppStrings.moesRecommendation,
    ];
    return parts.join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.question,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            AnswerButtons(selected: answer, onChanged: onAnswer),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sourceLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onPhotoCheck,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text(AppStrings.photoCheck),
                ),
              ],
            ),
            ExpansionTile(
              // Its own storage slot. Without it the tile shared the list's
              // slot, read the saved scroll offset as its open flag and
              // crashed, leaving a grey card (AS-38).
              key: PageStorageKey('why_${item.id}'),
              title: const Text(AppStrings.whyThisMatters),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 12),
              expandedAlignment: Alignment.centerLeft,
              shape: const Border(),
              collapsedShape: const Border(),
              children: [
                Text(item.whyItMatters, style: theme.textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
