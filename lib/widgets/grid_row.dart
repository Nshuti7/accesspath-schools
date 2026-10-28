import 'package:flutter/material.dart';

import '../layout.dart';

/// One row of a 12-column grid: each child gets `span` of the 12 columns,
/// with a 24 px gutter between them.
class GridRow extends StatelessWidget {
  const GridRow({super.key, required this.cells});

  final List<({int span, Widget child})> cells;

  @override
  Widget build(BuildContext context) {
    assert(
      cells.fold(0, (sum, cell) => sum + cell.span) <= 12,
      'A grid row has at most 12 columns',
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, cell) in cells.indexed) ...[
          if (index > 0) const SizedBox(width: Space.md),
          Expanded(flex: cell.span, child: cell.child),
        ],
      ],
    );
  }
}
