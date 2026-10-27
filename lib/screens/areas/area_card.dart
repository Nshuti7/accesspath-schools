import 'package:flutter/material.dart';

import '../../models/assessment_area.dart';
import '../../strings.dart';

class AreaCard extends StatelessWidget {
  const AreaCard({
    super.key,
    required this.area,
    required this.itemCount,
    required this.answeredCount,
    required this.onTap,
  });

  final AssessmentArea area;
  final int itemCount;
  final int answeredCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = itemCount == 0 ? 0.0 : answeredCount / itemCount;
    final percent = (progress * 100).round();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // Read the card as one sentence instead of separate fragments.
        child: MergeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(area.icon, size: 40, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(area.name, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.answeredOf(answeredCount, itemCount),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text('$percent%', style: theme.textTheme.titleLarge),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
