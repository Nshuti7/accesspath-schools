import 'package:flutter/material.dart';

/// A tappable count, e.g. "3 Open gaps". With [isWarning] the tile gets a red
/// outline and number; the label always says what the number means.
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

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: isWarning
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colors.error, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
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
      ),
    );
  }
}
