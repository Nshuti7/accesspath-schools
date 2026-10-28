import 'package:accesspath_schools/widgets/app_shell.dart';
import 'package:accesspath_schools/widgets/app_sidebar.dart';
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

  testWidgets('small tablets get a side rail', (tester) async {
    await pumpShell(tester, 900, '/');
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('desktop gets the full sidebar with school and log out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var loggedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          location: '/gaps',
          schoolName: 'Kololo Primary',
          onLogOut: () => loggedOut = true,
          child: const SizedBox(),
        ),
      ),
    );

    expect(find.byType(AppSidebar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('Kololo Primary'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Gaps')),
      matchesSemantics(
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        label: 'Gaps',
      ),
    );
    await tester.tap(find.text('Log out'));
    expect(loggedOut, isTrue);
  });

  testWidgets('a checklist page keeps Assess selected', (tester) async {
    await pumpShell(tester, 400, '/areas/toilets');
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 1);
  });

  testWidgets('the guide tab is in the navigation', (tester) async {
    await pumpShell(tester, 400, '/guide');
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations, hasLength(5));
    expect(bar.selectedIndex, 4);
  });
}
