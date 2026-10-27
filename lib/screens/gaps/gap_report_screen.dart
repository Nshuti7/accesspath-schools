import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/gap.dart';
import '../../providers/assessment_provider.dart';
import '../../strings.dart';
import '../../widgets/info_message.dart';
import '../../widgets/load_error_view.dart';
import 'gap_card.dart';
import 'gap_summary.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AssessmentProvider>().ensureLoaded(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.gapReport)),
      body: _buildBody(context.watch<AssessmentProvider>()),
    );
  }

  Widget _buildBody(AssessmentProvider assessment) {
    final error = assessment.errorMessage;
    if (error != null) {
      return LoadErrorView(message: error, onRetry: assessment.ensureLoaded);
    }
    if (!assessment.isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final gaps = assessment.gaps;
    final active = gaps.where((gap) => !gap.isResolved).toList()
      ..sort(_needsActionFirst);
    final resolved = gaps.where((gap) => gap.isResolved).toList();
    final needsVerificationCount = active
        .where((gap) => gap.status == Gap.statusNeedsVerification)
        .length;

    Widget cardFor(Gap gap) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GapCard(gap: gap, item: assessment.itemById(gap.itemId)),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GapSummary(
              // Verified gaps are confirmed barriers, so they count as open.
              openCount: active.length - needsVerificationCount,
              needsVerificationCount: needsVerificationCount,
              resolvedCount: resolved.length,
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
