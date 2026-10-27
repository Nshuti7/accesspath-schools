import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/action_item.dart';
import '../../models/gap.dart';
import '../../providers/action_provider.dart';
import '../../providers/assessment_provider.dart';
import '../../strings.dart';
import '../../widgets/info_message.dart';
import '../../widgets/load_error_view.dart';
import 'action_card.dart';
import 'status_sheet.dart';

class ActionTrackerScreen extends StatefulWidget {
  const ActionTrackerScreen({super.key});

  @override
  State<ActionTrackerScreen> createState() => _ActionTrackerScreenState();
}

class _ActionTrackerScreenState extends State<ActionTrackerScreen> {
  /// Null shows every status.
  String? _filter;

  @override
  void initState() {
    super.initState();
    // Actions load by themselves once the school is known from this.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AssessmentProvider>().ensureLoaded(),
    );
  }

  Future<void> _changeStatus(ActionItem action) async {
    final status = await showStatusSheet(context, action.status);
    if (!mounted || status == null || status == action.status) return;

    final assessment = context.read<AssessmentProvider>();
    final saved = await context.read<ActionProvider>().setStatus(
      action,
      status,
    );
    if (!mounted) return;
    if (!saved) {
      _showMessage(AppStrings.errorUpdateAction);
      return;
    }

    final gap = assessment.gapById(action.gapId);
    if (status != ActionItem.statusDone || gap == null || gap.isResolved) {
      return;
    }
    // Done does not always mean fixed, so the person decides.
    final resolve = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.markGapResolvedQuestion),
        content: Text(gap.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.yesResolve),
          ),
        ],
      ),
    );
    if (resolve != true || !mounted) return;
    final resolved = await assessment.setGapStatus(gap.id, Gap.statusResolved);
    if (mounted) {
      _showMessage(
        resolved ? AppStrings.gapMarkedResolved : AppStrings.errorUpdateGap,
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.actionTracker)),
      body: _buildBody(
        context.watch<AssessmentProvider>(),
        context.watch<ActionProvider>(),
      ),
    );
  }

  Widget _buildBody(AssessmentProvider assessment, ActionProvider actions) {
    final error = assessment.errorMessage ?? actions.errorMessage;
    if (error != null) {
      return LoadErrorView(
        message: error,
        onRetry: assessment.errorMessage != null
            ? assessment.ensureLoaded
            : actions.load,
      );
    }
    if (!assessment.isReady || !actions.isReady) {
      return const Center(child: CircularProgressIndicator());
    }

    final all = actions.actions;
    final shown = _filter == null
        ? all
        : all.where((action) => action.status == _filter).toList();
    final now = DateTime.now();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in [null, ...ActionItem.statuses])
                  ChoiceChip(
                    label: Text(
                      status == null
                          ? AppStrings.filterAll
                          : ActionCard.statusLabel(status),
                    ),
                    selected: _filter == status,
                    onSelected: (_) => setState(() => _filter = status),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (all.isEmpty)
              const InfoMessage(AppStrings.noActionsYet)
            else if (shown.isEmpty)
              const InfoMessage(AppStrings.noActionsForFilter),
            for (final action in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ActionCard(
                  action: action,
                  now: now,
                  onTap: () => _changeStatus(action),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
