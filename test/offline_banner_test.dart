import 'dart:async';

import 'package:accesspath_schools/strings.dart';
import 'package:accesspath_schools/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the offline message only while offline', (tester) async {
    final online = StreamController<bool>();
    addTearDown(online.close);
    await tester.pumpWidget(
      MaterialApp(
        home: OfflineBanner(
          uid: 'teacher',
          onlineChanges: online.stream,
          child: const Text('Page'),
        ),
      ),
    );
    expect(find.text(AppStrings.offlineBanner), findsNothing);

    online.add(false);
    await tester.pump();
    expect(find.text(AppStrings.offlineBanner), findsOneWidget);
    expect(find.text('Page'), findsOneWidget);

    online.add(true);
    // One frame delivers the event, the next shows the rebuilt page.
    await tester.pump();
    await tester.pump();
    expect(find.text(AppStrings.offlineBanner), findsNothing);
  });
}
