import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/report_summary.dart';
import '../../services/ai_call.dart';
import '../../strings.dart';
import '../../widgets/form_error_text.dart';
import 'generate_summary_button.dart';
import 'report_summary_controller.dart';

/// The AI summary, its error, and a Copy button. On phones it also holds the
/// "Generate summary" button; on desktop that button sits in the page header.
class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({
    super.key,
    required this.controller,
    this.showGenerateButton = true,
  });

  final ReportSummaryController controller;
  final bool showGenerateButton;

  Future<void> _copy(BuildContext context, ReportSummary summary) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: summary.toPlainText()));
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.summaryCopied)),
    );
  }

  static String _messageFor(AiError error) {
    return switch (error) {
      AiError.offline => AppStrings.errorOffline,
      AiError.quotaReached => AppStrings.errorAiQuota,
      AiError.unreadableResponse => AppStrings.errorAiUnreadable,
      AiError.unavailable => AppStrings.errorSummaryUnavailable,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final summary = controller.summary;
        final error = controller.error;
        final canCopy = summary != null && !controller.isLoading;
        final buttons = [
          if (showGenerateButton) GenerateSummaryButton(controller: controller),
          if (canCopy)
            OutlinedButton.icon(
              onPressed: () => _copy(context, summary),
              icon: const Icon(Icons.copy),
              label: const Text(AppStrings.copy),
            ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (summary != null) ...[
              _SummaryContent(summary: summary),
              const SizedBox(height: 8),
            ],
            if (error != null) ...[
              FormErrorText(_messageFor(error)),
              const SizedBox(height: 8),
            ],
            if (buttons.isNotEmpty)
              Wrap(spacing: 8, runSpacing: 8, children: buttons),
          ],
        );
      },
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colors.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.aiSummaryLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.tertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(summary.overview, style: theme.textTheme.bodyLarge),
            if (summary.priorities.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AppStrings.topPriorities,
                style: theme.textTheme.titleMedium,
              ),
              for (final (index, priority) in summary.priorities.indexed)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${index + 1}. ${priority.title}: ${priority.reason}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
            ],
            if (summary.nextSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(AppStrings.nextSteps, style: theme.textTheme.titleMedium),
              for (final step in summary.nextSteps)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('- $step', style: theme.textTheme.bodyLarge),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
