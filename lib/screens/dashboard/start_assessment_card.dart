import 'package:flutter/material.dart';

import '../../strings.dart';

/// Shown instead of the score until the first question is answered, so a new
/// school sees one clear thing to do rather than a row of zeros.
class StartAssessmentCard extends StatelessWidget {
  const StartAssessmentCard({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.fact_check_outlined,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                AppStrings.startFirstAssessment,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.startFirstAssessmentBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.arrow_forward),
              label: const Text(AppStrings.startFirstAssessment),
            ),
          ],
        ),
      ),
    );
  }
}
