import 'package:flutter/material.dart';

import '../../strings.dart';

/// The three counts at the top of the gap report.
class GapSummary extends StatelessWidget {
  const GapSummary({
    super.key,
    required this.openCount,
    required this.needsVerificationCount,
    required this.resolvedCount,
  });

  final int openCount;
  final int needsVerificationCount;
  final int resolvedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _CountTile(count: openCount, label: AppStrings.statusOpen),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountTile(
            count: needsVerificationCount,
            label: AppStrings.statusNeedsVerification,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _CountTile(
            count: resolvedCount,
            label: AppStrings.statusResolved,
          ),
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count', style: theme.textTheme.headlineMedium),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
