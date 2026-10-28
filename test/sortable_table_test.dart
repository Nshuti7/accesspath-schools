import 'package:accesspath_schools/widgets/due_date_text.dart';
import 'package:accesspath_schools/widgets/sortable_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final rows = [('Ramp', 2), ('Toilet', 1), ('Door', 3)];

  Future<void> pumpTable(WidgetTester tester, List<String> tapped) {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SortableTable<(String, int)>(
            rows: rows,
            onRowTap: (row) => tapped.add(row.$1),
            columns: [
              TableColumnSpec(
                label: 'Name',
                cell: (row) => Text(row.$1),
                sortKey: (row) => row.$1,
              ),
              TableColumnSpec(
                label: 'Rank',
                cell: (row) => Text('${row.$2}'),
                sortKey: (row) => row.$2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> namesTopToBottom(WidgetTester tester) {
    final names = ['Ramp', 'Toilet', 'Door'];
    return names..sort(
      (a, b) => tester
          .getTopLeft(find.text(a))
          .dy
          .compareTo(tester.getTopLeft(find.text(b)).dy),
    );
  }

  testWidgets('sorts by the first column, then by a tapped heading', (
    tester,
  ) async {
    final tapped = <String>[];
    await pumpTable(tester, tapped);
    expect(namesTopToBottom(tester), ['Door', 'Ramp', 'Toilet']);

    await tester.tap(find.text('Rank'));
    await tester.pumpAndSettle();
    expect(namesTopToBottom(tester), ['Toilet', 'Ramp', 'Door']);

    await tester.tap(find.text('Rank'));
    await tester.pumpAndSettle();
    expect(namesTopToBottom(tester), ['Door', 'Ramp', 'Toilet']);

    await tester.tap(find.text('Ramp'));
    expect(tapped, ['Ramp']);
  });

  testWidgets('overdue dates say so in words, not only in red', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DueDateText(date: DateTime(2026, 10, 1), isOverdue: true),
      ),
    );
    expect(find.textContaining('Overdue'), findsOneWidget);
  });
}
