import 'package:flutter/material.dart';

import '../../models/checklist_item.dart';
import '../../models/photo_finding.dart';
import '../../strings.dart';

class FindingCard extends StatelessWidget {
  const FindingCard({
    super.key,
    required this.finding,
    required this.item,
    required this.isSaving,
    required this.onAccept,
    required this.onDismiss,
  });

  final PhotoFinding finding;
  final ChecklistItem item;
  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.report_problem_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.possibleIssue,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(finding.finding, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(AppStrings.confidence(finding.confidence), style: mutedStyle),
            const SizedBox(height: 12),
            Text(AppStrings.linkedQuestion, style: mutedStyle),
            Text(item.question, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onDismiss,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                    ),
                    child: const Text(AppStrings.dismiss),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isSaving ? null : onAccept,
                    child: isSaving
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Text(AppStrings.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
