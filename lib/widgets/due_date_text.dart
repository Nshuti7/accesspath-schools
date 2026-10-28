import 'package:flutter/material.dart';

import '../page_text.dart';
import '../strings.dart';

/// Due date for a table cell. Overdue dates are red, bold and say "Overdue",
/// so the meaning never depends on colour alone.
class DueDateText extends StatelessWidget {
  const DueDateText({super.key, required this.date, this.isOverdue = false});

  final DateTime? date;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = date;
    if (due == null) {
      return Text(
        PageText.notSet,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (!isOverdue) return Text(AppStrings.formatDate(due));
    final overdueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.error,
      fontWeight: FontWeight.w700,
    );
    // Two lines keep the cell as narrow as a plain date, so the column
    // still fits on a laptop screen.
    return Semantics(
      label: '${PageText.overdue}, ${AppStrings.formatDate(due)}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(PageText.overdue, style: overdueStyle),
            ],
          ),
          Text(AppStrings.formatDate(due), style: overdueStyle),
        ],
      ),
    );
  }
}
