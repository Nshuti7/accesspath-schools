import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../page_text.dart';
import '../../models/gap.dart';
import '../../models/report_summary.dart';
import '../../providers/action_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/school_provider.dart';
import '../../router.dart';
import '../../services/report_summary_service.dart';
import '../../strings.dart';
import '../../widgets/info_message.dart';
import '../../widgets/data_gate.dart';
import '../../widgets/page_scaffold.dart';
import 'gap_card.dart';
import 'gap_summary.dart';
import 'report_summary_card.dart';

class GapReportScreen extends StatefulWidget {
  const GapReportScreen({super.key});

  @override
  State<GapReportScreen> createState() => _GapReportScreenState();
}

class _GapReportScreenState extends State<GapReportScreen> {
  static const _priorities = [
    ('high', AppStrings.highPriority),
    ('medium', AppStrings.mediumPriority),
    ('low', AppStrings.lowPriority),
  ];

  final _summaryService = ReportSummaryService();

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: AppStrings.gapReport,
      description: PageText.gaps,
      body: DataGate(
        needsActions: true,
        builder: (context) => _buildBody(
          context.watch<AssessmentProvider>(),
          context.watch<ActionProvider>(),
        ),
      ),
    );
  }

  Widget _buildBody(AssessmentProvider assessment, ActionProvider actions) {
    final gaps = assessment.gaps;
    final active = gaps.where((gap) => !gap.isResolved).toList()
      ..sort(_needsActionFirst);
    final resolved = gaps.where((gap) => gap.isResolved).toList();
    final stats = assessment.stats;

    Widget cardFor(Gap gap) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GapCard(
        gap: gap,
        item: assessment.itemById(gap.itemId),
        action: actions.actionForGap(gap.id),
        onAssign: () => context.go(AppRoutes.assignAction(gap.id)),
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (gaps.isNotEmpty) ...[
              ReportSummaryCard(
                onGenerate: () => _summarise(assessment, actions),
              ),
              const SizedBox(height: 24),
            ],
            GapSummary(
              openCount: stats.openGaps,
              needsVerificationCount: stats.needsVerificationGaps,
              resolvedCount: stats.resolvedGaps,
            ),
            const SizedBox(height: 24),
            if (gaps.isEmpty) const InfoMessage(AppStrings.noGapsYet),
            for (final (priority, heading) in _priorities)
              ..._section(
                heading,
                active.where((gap) => gap.priority == priority).toList(),
                cardFor,
              ),
            if (resolved.isNotEmpty)
              ExpansionTile(
                title: Text(AppStrings.resolvedGaps(resolved.length)),
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                collapsedShape: const Border(),
                children: resolved.map(cardFor).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Future<ReportSummary> _summarise(
    AssessmentProvider assessment,
    ActionProvider actions,
  ) {
    return _summaryService.summarise(
      schoolName: context.read<SchoolProvider>().school?.name ?? '',
      stats: assessment.stats,
      gaps: assessment.gaps,
      itemById: assessment.itemById,
      actions: actions.actions,
      now: DateTime.now(),
    );
  }

  List<Widget> _section(
    String heading,
    List<Gap> gaps,
    Widget Function(Gap) cardFor,
  ) {
    if (gaps.isEmpty) return const [];
    return [
      Semantics(
        header: true,
        child: Text(
          '$heading (${gaps.length})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      const SizedBox(height: 12),
      ...gaps.map(cardFor),
      const SizedBox(height: 12),
    ];
  }

  /// Confirmed and open gaps before ones that still need checking.
  static int _needsActionFirst(Gap a, Gap b) {
    int rank(Gap gap) => gap.status == Gap.statusNeedsVerification ? 1 : 0;
    return rank(a).compareTo(rank(b));
  }
}
