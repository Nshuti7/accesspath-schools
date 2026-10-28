import 'package:flutter/material.dart';

import '../../models/action_item.dart';
import '../../models/assessment_area.dart';
import '../../models/gap.dart';
import '../../page_text.dart';
import '../../strings.dart';
import '../../widgets/due_date_text.dart';
import '../../widgets/sortable_table.dart';
import 'action_card.dart';

/// Desktop action tracker: one row per action, sorted by due date first.
/// Opening a row changes its status, as tapping a card does on phones.
class ActionTable extends StatelessWidget {
  const ActionTable({
    super.key,
    required this.actions,
    required this.gapById,
    required this.onOpen,
    required this.now,
  });

  final List<ActionItem> actions;
  final Gap? Function(String gapId) gapById;
  final ValueChanged<ActionItem> onOpen;
  final DateTime now;

  static const _dueDateColumn = 6;

  @override
  Widget build(BuildContext context) {
    String areaName(ActionItem action) {
      final area = gapById(action.gapId)?.area ?? '';
      return AssessmentArea.byId(area)?.name ?? area;
    }

    String source(ActionItem action) =>
        gapById(action.gapId)?.source == Gap.sourceAiPhoto
        ? AppStrings.sourceAiPhoto
        : AppStrings.sourceChecklist;

    String priority(ActionItem action) =>
        gapById(action.gapId)?.priority ?? 'low';

    return SortableTable<ActionItem>(
      rows: actions,
      onRowTap: onOpen,
      initialSortColumn: _dueDateColumn,
      columns: [
        TableColumnSpec(
          label: PageText.columnPriority,
          cell: (action) => Text(PageText.priorityLabel(priority(action))),
          sortKey: (action) => PageText.priorityRank(priority(action)),
        ),
        TableColumnSpec(
          label: PageText.columnQuestion,
          cell: (action) => SizedBox(
            width: 320,
            child: Text(
              action.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          sortKey: (action) => action.title,
        ),
        TableColumnSpec(
          label: PageText.columnArea,
          cell: (action) => Text(areaName(action)),
          sortKey: areaName,
        ),
        TableColumnSpec(
          label: PageText.columnSource,
          cell: (action) => Text(source(action)),
          sortKey: source,
        ),
        TableColumnSpec(
          label: PageText.columnStatus,
          cell: (action) => Text(ActionCard.statusLabel(action.status)),
          sortKey: (action) => ActionItem.statuses.indexOf(action.status),
        ),
        TableColumnSpec(
          label: PageText.columnOwner,
          cell: (action) => Text(action.ownerName),
          sortKey: (action) => action.ownerName,
        ),
        TableColumnSpec(
          label: PageText.columnDueDate,
          cell: (action) => DueDateText(
            date: action.dueDate,
            isOverdue: action.isOverdueOn(now),
          ),
          sortKey: (action) => action.dueDate,
        ),
      ],
    );
  }
}
