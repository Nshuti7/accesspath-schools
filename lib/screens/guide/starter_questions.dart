import 'package:flutter/material.dart';

import '../../strings.dart';

/// Shown on an empty chat so people know what kind of question works.
class StarterQuestions extends StatelessWidget {
  const StarterQuestions({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.guideIntro, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text(AppStrings.guideStarterTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final question in AppStrings.guideStarterQuestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => onSelected(question),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: const Size.fromHeight(56),
              ),
              child: Text(question),
            ),
          ),
      ],
    );
  }
}
