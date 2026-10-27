import 'package:accesspath_schools/models/action_item.dart';
import 'package:accesspath_schools/strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ActionItem dueOn(DateTime date, {String status = ActionItem.statusTodo}) =>
      ActionItem(
        id: 'a1',
        gapId: 'g1',
        title: 'Fit handrails',
        ownerName: 'Facilities manager',
        dueDate: date,
        status: status,
      );

  final now = DateTime(2026, 11, 10, 15, 30);

  test('due yesterday and not done is overdue', () {
    expect(dueOn(DateTime(2026, 11, 9)).isOverdueOn(now), isTrue);
  });

  test('due today is not overdue, even late in the day', () {
    expect(dueOn(DateTime(2026, 11, 10)).isOverdueOn(now), isFalse);
  });

  test('done actions are never overdue', () {
    final action = dueOn(DateTime(2026, 1, 1), status: ActionItem.statusDone);
    expect(action.isOverdueOn(now), isFalse);
  });

  test('fromMap and toMap keep the fields', () {
    final action = ActionItem.fromMap(
      'a1',
      dueOn(DateTime(2026, 12, 1)).toMap(),
    );
    expect(action.ownerName, 'Facilities manager');
    expect(action.dueDate, DateTime(2026, 12, 1));
    expect(action.status, ActionItem.statusTodo);
  });

  test('dates are written with the month name', () {
    expect(AppStrings.formatDate(DateTime(2026, 11, 3)), '3 Nov 2026');
  });
}
