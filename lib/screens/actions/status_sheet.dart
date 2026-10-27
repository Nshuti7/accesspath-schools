import 'package:flutter/material.dart';

import '../../models/action_item.dart';
import '../../strings.dart';
import 'action_card.dart';

/// Bottom sheet listing the three action statuses. Returns the one picked,
/// or null if the sheet was closed.
Future<String?> showStatusSheet(BuildContext context, String current) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => StatusSheet(current: current),
  );
}

class StatusSheet extends StatelessWidget {
  const StatusSheet({super.key, required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Semantics(
              header: true,
              child: Text(
                AppStrings.changeStatus,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          for (final status in ActionItem.statuses)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              minTileHeight: 56,
              selected: status == current,
              leading: Icon(
                status == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(ActionCard.statusLabel(status)),
              onTap: () => Navigator.of(context).pop(status),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
