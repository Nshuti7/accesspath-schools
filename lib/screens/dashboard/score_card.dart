import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/assessment_stats.dart';
import '../../strings.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.stats});

  final AssessmentStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final percent = stats.scorePercent ?? 0;
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                AppStrings.accessibilityScore,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // The ring is decoration; screen readers get the number.
                Semantics(
                  label: AppStrings.scoreSemantics(percent),
                  child: ExcludeSemantics(
                    child: SizedBox.square(
                      dimension: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              startDegreeOffset: 270,
                              sectionsSpace: 0,
                              centerSpaceRadius: 52,
                              pieTouchData: PieTouchData(enabled: false),
                              sections: [
                                if (percent > 0)
                                  _ring(percent.toDouble(), colors.primary),
                                if (percent < 100)
                                  _ring(
                                    (100 - percent).toDouble(),
                                    colors.surfaceContainerHighest,
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.questionsAnswered(
                          stats.answeredCount,
                          stats.totalItems,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(AppStrings.scoreExplainer, style: mutedStyle),
                      const SizedBox(height: 8),
                      Text(AppStrings.selfCheckNote, style: mutedStyle),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static PieChartSectionData _ring(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 16,
      showTitle: false,
    );
  }
}
