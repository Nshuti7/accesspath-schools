import 'package:flutter/material.dart';

import '../../models/assessment_area.dart';
import '../../strings.dart';

typedef AreaProgress = ({AssessmentArea area, int answered, int total});

/// One compact row per area with a progress bar; tapping opens its checklist.
class AreaProgressList extends StatelessWidget {
  const AreaProgressList({
    super.key,
    required this.areas,
    required this.onOpen,
  });

  final List<AreaProgress> areas;
  final ValueChanged<AssessmentArea> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Semantics(
                header: true,
                child: Text(
                  AppStrings.progressByArea,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            for (final progress in areas)
              InkWell(
                onTap: () => onOpen(progress.area),
                child: MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          progress.area.icon,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                progress.area.name,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: progress.total == 0
                                    ? 0
                                    : progress.answered / progress.total,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${progress.answered}/${progress.total}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
