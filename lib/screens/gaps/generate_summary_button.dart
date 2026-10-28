import 'package:flutter/material.dart';

import '../../strings.dart';
import 'report_summary_controller.dart';

/// Shown in the desktop page header and inside the summary card on phones.
class GenerateSummaryButton extends StatelessWidget {
  const GenerateSummaryButton({super.key, required this.controller});

  final ReportSummaryController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isLoading = controller.isLoading;
        return FilledButton.icon(
          onPressed: isLoading ? null : controller.generate,
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome_outlined),
          label: Text(
            isLoading
                ? AppStrings.writingSummary
                : controller.summary == null
                ? AppStrings.generateSummary
                : AppStrings.generateAgain,
          ),
        );
      },
    );
  }
}
