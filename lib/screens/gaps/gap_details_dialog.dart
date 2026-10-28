import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../layout.dart';
import '../../models/action_item.dart';
import '../../models/checklist_item.dart';
import '../../models/gap.dart';
import '../../page_text.dart';
import '../../router.dart';
import 'gap_card.dart';

/// The desktop table only has room for short columns, so a row opens the full
/// gap card with the recommendation and the Assign button.
Future<void> showGapDetailsDialog(
  BuildContext context, {
  required Gap gap,
  required ChecklistItem? item,
  required ActionItem? action,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GapCard(
                gap: gap,
                item: item,
                action: action,
                onAssign: () {
                  Navigator.of(dialogContext).pop();
                  context.go(AppRoutes.assignAction(gap.id));
                },
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(PageText.close),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
