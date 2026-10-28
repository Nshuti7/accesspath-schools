import 'package:flutter/material.dart';

import '../../widgets/hover_card.dart';

/// A tappable count, e.g. "3 Open gaps". With [isWarning] the tile gets a red
/// outline and number; the label always says what the number means. Lifts on
/// hover and shows a thick outline on keyboard focus.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isWarning = false,
  });

  final int count;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = isWarning ? colors.error : colors.primary;

    return HoverCard(
      onTap: onTap,
      borderColor: isWarning ? colors.error : null,
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accent),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isWarning ? colors.error : null,
                ),
              ),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
