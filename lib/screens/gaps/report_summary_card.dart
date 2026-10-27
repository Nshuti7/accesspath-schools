import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/report_summary.dart';
import '../../services/ai_call.dart';
import '../../strings.dart';
import '../../widgets/form_error_text.dart';

/// "Generate summary" button that turns into the AI summary. The summary lives
/// only in this widget, so it disappears when the user leaves the page.
class ReportSummaryCard extends StatefulWidget {
  const ReportSummaryCard({super.key, required this.onGenerate});

  final Future<ReportSummary> Function() onGenerate;

  @override
  State<ReportSummaryCard> createState() => _ReportSummaryCardState();
}

class _ReportSummaryCardState extends State<ReportSummaryCard> {
  ReportSummary? _summary;
  bool _isLoading = false;
  AiError? _error;

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final summary = await widget.onGenerate();
      if (!mounted) return;
      setState(() => _summary = summary);
    } on AiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.reason);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _copy(ReportSummary summary) async {
    await Clipboard.setData(ClipboardData(text: summary.toPlainText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text(AppStrings.summaryCopied)));
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
    final summary = _summary;
    final error = _error;

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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _isLoading ? null : _generate,
              icon: _isLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(
                _isLoading
                    ? AppStrings.writingSummary
                    : summary == null
                    ? AppStrings.generateSummary
                    : AppStrings.generateAgain,
              ),
            ),
            if (summary != null && !_isLoading)
              OutlinedButton.icon(
                onPressed: () => _copy(summary),
                icon: const Icon(Icons.copy),
                label: const Text(AppStrings.copy),
              ),
          ],
        ),
      ],
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
