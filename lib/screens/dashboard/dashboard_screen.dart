import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/assessment_area.dart';
import '../../models/assessment_stats.dart';
import '../../models/gap.dart';
import '../../providers/action_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../router.dart';
import '../../strings.dart';
import '../../widgets/data_gate.dart';
import 'area_progress_list.dart';
import 'next_steps_card.dart';
import 'score_card.dart';
import 'start_assessment_card.dart';
import 'stat_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Content width at which cards sit side by side instead of stacking.
  static const _twoColumnWidth = 720.0;
  static const _nextStepsLimit = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navDashboard),
        actions: [
          TextButton(
            onPressed: () => context.read<AuthProvider>().signOut(),
            child: const Text(AppStrings.logOut),
          ),
        ],
      ),
      body: DataGate(needsActions: true, builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final school = context.watch<SchoolProvider>();
    final assessment = context.watch<AssessmentProvider>();
    final actions = context.watch<ActionProvider>();
    final stats = assessment.stats;
    final firstName = (school.user?.name ?? '').split(' ').first;
    final theme = Theme.of(context);

    final areaProgress = AreaProgressList(
      areas: [
        for (final area in AssessmentArea.all)
          (
            area: area,
            answered: assessment.answeredCountForArea(area.id),
            total: assessment.itemsForArea(area.id).length,
          ),
      ],
      onOpen: (area) => context.go(AppRoutes.checklist(area.id)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _twoColumnWidth;
        Widget pair(Widget first, Widget second) => isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: first),
                  const SizedBox(width: 16),
                  Expanded(child: second),
                ],
              )
            : Column(children: [first, const SizedBox(height: 16), second]);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  AppStrings.greeting(DateTime.now(), firstName),
                  style: theme.textTheme.bodyLarge,
                ),
                Semantics(
                  header: true,
                  child: Text(
                    school.school?.name ?? '',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 16),
                if (stats.answeredCount == 0) ...[
                  StartAssessmentCard(
                    onStart: () => context.go(AppRoutes.areas),
                  ),
                  const SizedBox(height: 16),
                  areaProgress,
                ] else ...[
                  pair(
                    ScoreCard(stats: stats),
                    _statGrid(
                      context,
                      stats,
                      actions.overdueCount(DateTime.now()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  pair(
                    NextStepsCard(
                      gaps: _nextSteps(assessment, actions),
                      // Push, so saving the action returns here.
                      onAssign: (gap) =>
                          context.push(AppRoutes.assignAction(gap.id)),
                    ),
                    areaProgress,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statGrid(BuildContext context, AssessmentStats stats, int overdue) {
    void toGaps() => context.go(AppRoutes.gaps);
    final tiles = [
      StatTile(
        count: stats.openGaps,
        label: AppStrings.openGaps,
        icon: Icons.report_outlined,
        onTap: toGaps,
      ),
      StatTile(
        count: stats.needsVerificationGaps,
        label: AppStrings.statusNeedsVerification,
        icon: Icons.help_outline,
        onTap: toGaps,
      ),
      StatTile(
        count: stats.resolvedGaps,
        label: AppStrings.statusResolved,
        icon: Icons.check_circle_outline,
        onTap: toGaps,
      ),
      StatTile(
        count: overdue,
        label: AppStrings.overdueActions,
        icon: Icons.warning_amber_rounded,
        isWarning: overdue > 0,
        onTap: () => context.go(AppRoutes.actions),
      ),
    ];
    // Always two by two: four tiles in a row are too narrow on phones.
    Widget row(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 8),
        Expanded(child: b),
      ],
    );
    return Column(
      children: [
        row(tiles[0], tiles[1]),
        const SizedBox(height: 8),
        row(tiles[2], tiles[3]),
      ],
    );
  }

  /// Open (or verified) high-priority gaps with no action yet, in checklist
  /// order so the list is stable between visits.
  static List<Gap> _nextSteps(
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
        .take(_nextStepsLimit)
        .toList();
  }
}
