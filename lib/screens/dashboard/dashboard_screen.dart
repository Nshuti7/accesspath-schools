import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../layout.dart';
import '../../models/assessment_area.dart';
import '../../page_text.dart';
import '../../providers/action_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../router.dart';
import '../../strings.dart';
import '../../widgets/data_gate.dart';
import '../../widgets/grid_row.dart';
import '../../widgets/page_scaffold.dart';
import 'area_progress_list.dart';
import 'next_steps_card.dart';
import 'score_card.dart';
import 'start_assessment_card.dart';
import 'stat_tiles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Content width at which cards sit side by side instead of stacking.
  static const _twoColumnWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    final school = context.watch<SchoolProvider>();
    final firstName = (school.user?.name ?? '').split(' ').first;
    final answeredCount = context
        .watch<AssessmentProvider>()
        .stats
        .answeredCount;
    final schoolName = school.school?.name ?? '';
    final greeting = AppStrings.greeting(DateTime.now(), firstName);

    return PageScaffold(
      title: AppStrings.navDashboard,
      description: schoolName.isEmpty ? greeting : '$greeting  ·  $schoolName',
      primaryAction: FilledButton.icon(
        onPressed: () => context.go(AppRoutes.areas),
        icon: const Icon(Icons.fact_check_outlined),
        label: Text(
          answeredCount > 0
              ? PageText.continueAssessment
              : PageText.startAssessment,
        ),
      ),
      appBarActions: [
        IconButton(
          // Push, so the back arrow returns to the dashboard.
          onPressed: () => context.push(AppRoutes.schoolProfile),
          icon: const Icon(Icons.school_outlined),
          tooltip: AppStrings.schoolProfile,
        ),
        TextButton(
          onPressed: () => context.read<AuthProvider>().signOut(),
          child: const Text(AppStrings.logOut),
        ),
      ],
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
    final isDesktop = Breakpoints.isDesktop(context);

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
    final startCard = StartAssessmentCard(
      onStart: () => context.go(AppRoutes.areas),
    );
    final scoreCard = ScoreCard(stats: stats);
    StatTiles statTiles({bool inOneRow = false}) => StatTiles(
      stats: stats,
      overdue: actions.overdueCount(DateTime.now()),
      onOpenGaps: () => context.go(AppRoutes.gaps),
      onOpenActions: () => context.go(AppRoutes.actions),
      inOneRow: inOneRow,
    );
    final nextSteps = NextStepsCard(
      gaps: NextStepsCard.pickGaps(assessment, actions),
      // Push, so saving the action returns here.
      onAssign: (gap) => context.push(AppRoutes.assignAction(gap.id)),
    );

    // Desktop: a 12-column grid. The greeting is already in the page header.
    if (isDesktop) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.lg),
        children: stats.answeredCount == 0
            ? [
                GridRow(
                  cells: [
                    (span: 6, child: startCard),
                    (span: 6, child: areaProgress),
                  ],
                ),
              ]
            : [
                GridRow(
                  cells: [
                    (span: 4, child: scoreCard),
                    (span: 8, child: statTiles(inOneRow: true)),
                  ],
                ),
                const SizedBox(height: Space.md),
                GridRow(
                  cells: [
                    (span: 6, child: nextSteps),
                    (span: 6, child: areaProgress),
                  ],
                ),
              ],
      );
    }

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
                  startCard,
                  const SizedBox(height: 16),
                  areaProgress,
                ] else ...[
                  pair(scoreCard, statTiles()),
                  const SizedBox(height: 16),
                  pair(nextSteps, areaProgress),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
