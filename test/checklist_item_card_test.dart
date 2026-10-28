import 'package:accesspath_schools/models/checklist_item.dart';
import 'package:accesspath_schools/screens/checklist/checklist_item_card.dart';
import 'package:accesspath_schools/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ChecklistItem _item(int n) => ChecklistItem(
  id: 'item_$n',
  area: 'toilets',
  question: 'Question $n?',
  whyItMatters: 'Reason $n.',
  guideRef: '16',
  defaultPriority: 'high',
);

Widget _list(String areaId) => MaterialApp(
  home: Scaffold(
    body: ListView(
      // Same kind of key the checklist list uses, which also stores the
      // scroll position.
      key: PageStorageKey(areaId),
      children: [
        for (var n = 0; n < 8; n++)
          ChecklistItemCard(
            item: _item(n),
            answer: null,
            onAnswer: (_) {},
            onPhotoCheck: () {},
          ),
      ],
    ),
  ),
);

void main() {
  // AS-38: the "Why this matters" tile read the list's saved scroll offset
  // as its own expanded flag, threw, and the card turned grey.
  testWidgets('cards survive scrolling, expanding and switching areas', (
    tester,
  ) async {
    await tester.pumpWidget(_list('toilets'));
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.whyThisMatters).first);
    await tester.pumpAndSettle();

    await tester.pumpWidget(_list('signage'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_list('toilets'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(AppStrings.whyThisMatters), findsWidgets);
  });
}
