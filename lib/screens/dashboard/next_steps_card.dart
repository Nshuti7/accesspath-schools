import 'package:flutter/material.dart';

import '../../models/assessment_area.dart';
import '../../models/gap.dart';
import '../../providers/action_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../strings.dart';

class NextStepsCard extends StatelessWidget {
  const NextStepsCard({super.key, required this.gaps, required this.onAssign});

  /// Already filtered and limited to the few to show.
  final List<Gap> gaps;
  final ValueChanged<Gap> onAssign;

  static const _limit = 3;

  /// Open (or verified) high-priority gaps with no action yet, in checklist
  /// order so the list is stable between visits.
  static List<Gap> pickGaps(
    AssessmentProvider assessment,
    ActionProvider actions,
  ) {
    final order = {
      for (final (index, item) in assessment.items.indexed) item.id: index,
    };
    int rank(Gap gap) => order[gap.itemId] ?? order.length;
    final candidates = assessment.gaps.where(
      (gap) =>
          gap.priority == 'high' &&
          (gap.status == Gap.statusOpen || gap.status == Gap.statusVerified) &&
          actions.actionForGap(gap.id) == null,
    );
    return (candidates.toList()..sort((a, b) => rank(a).compareTo(rank(b))))
        .take(_limit)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                AppStrings.nextSteps,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 4),
            if (gaps.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.nextStepsNone,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(AppStrings.nextStepsIntro, style: mutedStyle),
              for (final gap in gaps) ...[
                const Divider(height: 24),
                Text(gap.title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AssessmentArea.byId(gap.area)?.name ?? gap.area,
                        style: mutedStyle,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => onAssign(gap),
                      icon: const Icon(Icons.person_add_alt_outlined),
                      label: const Text(AppStrings.assign),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
