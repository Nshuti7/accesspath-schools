import 'package:flutter/material.dart';

import '../../models/assessment_stats.dart';
import '../../strings.dart';
import 'stat_tile.dart';

/// The four counts on the dashboard: two by two on phones, where four in a row
/// are too narrow, and one row of four on desktop.
class StatTiles extends StatelessWidget {
  const StatTiles({
    super.key,
    required this.stats,
    required this.overdue,
    required this.onOpenGaps,
    required this.onOpenActions,
    this.inOneRow = false,
  });

  final AssessmentStats stats;
  final int overdue;
  final VoidCallback onOpenGaps;
  final VoidCallback onOpenActions;
  final bool inOneRow;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatTile(
        count: stats.openGaps,
        label: AppStrings.openGaps,
        icon: Icons.report_outlined,
        onTap: onOpenGaps,
      ),
      StatTile(
        count: stats.needsVerificationGaps,
        label: AppStrings.statusNeedsVerification,
        icon: Icons.help_outline,
        onTap: onOpenGaps,
      ),
      StatTile(
        count: stats.resolvedGaps,
        label: AppStrings.statusResolved,
        icon: Icons.check_circle_outline,
        onTap: onOpenGaps,
      ),
      StatTile(
        count: overdue,
        label: AppStrings.overdueActions,
        icon: Icons.warning_amber_rounded,
        isWarning: overdue > 0,
        onTap: onOpenActions,
      ),
    ];

    Widget row(List<Widget> children) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, tile) in children.indexed) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(child: tile),
        ],
      ],
    );

    if (inOneRow) return row(tiles);
    return Column(
      children: [
        row(tiles.sublist(0, 2)),
        const SizedBox(height: 8),
        row(tiles.sublist(2)),
      ],
    );
  }
}
