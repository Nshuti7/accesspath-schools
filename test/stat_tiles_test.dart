import 'package:accesspath_schools/models/assessment_stats.dart';
import 'package:accesspath_schools/screens/dashboard/stat_tile.dart';
import 'package:accesspath_schools/screens/dashboard/stat_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stats = AssessmentStats(
    totalItems: 25,
    answeredCount: 5,
    yesCount: 3,
    openGaps: 1,
    needsVerificationGaps: 1,
    resolvedGaps: 0,
  );

  Future<Set<double>> rowTops(
    WidgetTester tester, {
    required bool oneRow,
  }) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatTiles(
            stats: stats,
            overdue: 0,
            onOpenGaps: () {},
            onOpenActions: () {},
            inOneRow: oneRow,
          ),
        ),
      ),
    );
    return {
      for (final element in find.byType(StatTile).evaluate())
        tester.getTopLeft(find.byWidget(element.widget)).dy,
    };
  }

  testWidgets('desktop shows the four tiles in one row', (tester) async {
    expect(await rowTops(tester, oneRow: true), hasLength(1));
  });

  testWidgets('phones show the tiles two by two', (tester) async {
    expect(await rowTops(tester, oneRow: false), hasLength(2));
  });
}
