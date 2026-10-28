import 'package:flutter/material.dart';

import '../layout.dart';

class TableColumnSpec<T> {
  const TableColumnSpec({
    required this.label,
    required this.cell,
    required this.sortKey,
  });

  final String label;
  final Widget Function(T row) cell;
  final Comparable<Object> Function(T row) sortKey;
}

/// Desktop table: click a column heading to sort by it, click again to
/// reverse. Rows are clickable and keyboard focusable.
class SortableTable<T> extends StatefulWidget {
  const SortableTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.onRowTap,
    this.initialSortColumn = 0,
  });

  final List<TableColumnSpec<T>> columns;
  final List<T> rows;
  final ValueChanged<T> onRowTap;
  final int initialSortColumn;

  @override
  State<SortableTable<T>> createState() => _SortableTableState<T>();
}

class _SortableTableState<T> extends State<SortableTable<T>> {
  late int _sortColumn = widget.initialSortColumn;
  bool _ascending = true;

  List<T> get _sortedRows {
    final column = widget.columns[_sortColumn];
    final indexed = widget.rows.indexed.toList();
    indexed.sort((a, b) {
      final byKey = column.sortKey(a.$2).compareTo(column.sortKey(b.$2));
      final ordered = _ascending ? byKey : -byKey;
      // Ties keep their original order so rows do not jump around.
      return ordered != 0 ? ordered : a.$1.compareTo(b.$1);
    });
    return [for (final (_, row) in indexed) row];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        // Scroll sideways rather than squash columns on narrow windows.
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            sortColumnIndex: _sortColumn,
            sortAscending: _ascending,
            showCheckboxColumn: false,
            // The default 56 px gaps push the last column off a laptop screen.
            columnSpacing: Space.md,
            horizontalMargin: Space.sm,
            dataRowMinHeight: 56,
            dataRowMaxHeight: 80,
            columns: [
              for (final (index, column) in widget.columns.indexed)
                DataColumn(
                  label: Text(column.label),
                  onSort: (_, _) => setState(() {
                    _ascending = index == _sortColumn ? !_ascending : true;
                    _sortColumn = index;
                  }),
                ),
            ],
            rows: [
              for (final row in _sortedRows)
                DataRow(
                  onSelectChanged: (_) => widget.onRowTap(row),
                  cells: [
                    for (final column in widget.columns)
                      DataCell(column.cell(row)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
