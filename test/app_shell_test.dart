import 'package:accesspath_schools/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpShell(WidgetTester tester, double width, String location) {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        home: AppShell(location: location, child: const SizedBox()),
      ),
    );
  }

  testWidgets('phones get a bottom navigation bar', (tester) async {
    await pumpShell(tester, 400, '/');
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('wide screens get a side rail', (tester) async {
    await pumpShell(tester, 1200, '/');
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a checklist page keeps Assess selected', (tester) async {
    await pumpShell(tester, 400, '/areas/toilets');
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 1);
  });
}
