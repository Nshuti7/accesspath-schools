import 'package:flutter/material.dart';

import '../../models/action_item.dart';
import '../../models/assessment_area.dart';
import '../../models/gap.dart';
import '../../page_text.dart';
import '../../strings.dart';
import '../../widgets/due_date_text.dart';
import '../../widgets/sortable_table.dart';
import 'gap_card.dart';

/// Desktop gap report: one row per gap, sortable by any column. Opening a row
/// shows the full gap card (recommendation, photo finding, Assign).
class GapTable extends StatelessWidget {
  const GapTable({
    super.key,
    required this.gaps,
    required this.actionForGap,
    required this.onOpen,
    required this.now,
  });

  final List<Gap> gaps;
  final ActionItem? Function(String gapId) actionForGap;
  final ValueChanged<Gap> onOpen;
  final DateTime now;

  static const _farFuture = '9999-12-31';

  @override
  Widget build(BuildContext context) {
    String areaName(Gap gap) => AssessmentArea.byId(gap.area)?.name ?? gap.area;
    String source(Gap gap) => gap.source == Gap.sourceAiPhoto
        ? AppStrings.sourceAiPhoto
        : AppStrings.sourceChecklist;

    return SortableTable<Gap>(
      rows: gaps,
      onRowTap: onOpen,
      columns: [
        TableColumnSpec(
          label: PageText.columnPriority,
          cell: (gap) => Text(PageText.priorityLabel(gap.priority)),
          sortKey: (gap) => PageText.priorityRank(gap.priority),
        ),
        TableColumnSpec(
          label: PageText.columnQuestion,
          cell: (gap) => SizedBox(
            width: 240,
            child: Text(
              gap.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          sortKey: (gap) => gap.title,
        ),
        TableColumnSpec(
          label: PageText.columnArea,
          cell: (gap) => Text(areaName(gap)),
          sortKey: areaName,
        ),
        TableColumnSpec(
          label: PageText.columnSource,
          cell: (gap) => Text(source(gap)),
          sortKey: source,
        ),
        TableColumnSpec(
          label: PageText.columnStatus,
          cell: (gap) => Text(GapCard.statusLabel(gap.status)),
          sortKey: (gap) => GapCard.statusLabel(gap.status),
        ),
        TableColumnSpec(
          label: PageText.columnOwner,
          cell: (gap) =>
              Text(actionForGap(gap.id)?.ownerName ?? PageText.notAssigned),
          sortKey: (gap) => actionForGap(gap.id)?.ownerName ?? '',
        ),
        TableColumnSpec(
          label: PageText.columnDueDate,
          cell: (gap) {
            final action = actionForGap(gap.id);
            return DueDateText(
              date: action?.dueDate,
              isOverdue: action?.isOverdueOn(now) ?? false,
            );
          },
          sortKey: (gap) =>
              actionForGap(gap.id)?.dueDate.toIso8601String() ?? _farFuture,
        ),
      ],
    );
  }
}
