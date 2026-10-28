import 'package:accesspath_schools/strings.dart';
import 'package:accesspath_schools/widgets/district_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GlobalKey<FormState> formKey;
  late String reported;

  Future<void> pumpField(WidgetTester tester) async {
    formKey = GlobalKey<FormState>();
    reported = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: DistrictField(onChanged: (value) => reported = value),
          ),
        ),
      ),
    );
  }

  testWidgets('typing a full district name counts as choosing it', (
    tester,
  ) async {
    await pumpField(tester);
    await tester.enterText(find.byType(TextField).first, 'kampala');
    await tester.pump();

    expect(formKey.currentState!.validate(), isTrue);
    expect(reported, 'Kampala');
  });

  testWidgets('a partial name still asks for a district', (tester) async {
    await pumpField(tester);
    await tester.enterText(find.byType(TextField).first, 'Kampal');
    await tester.pump();

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text(AppStrings.errorChooseDistrict), findsOneWidget);
  });

  testWidgets('editing a matched name away clears the choice', (tester) async {
    await pumpField(tester);
    final field = find.byType(TextField).first;
    await tester.enterText(field, 'Kampala');
    await tester.pump();
    await tester.enterText(field, 'Kampalax');
    await tester.pump();

    expect(formKey.currentState!.validate(), isFalse);
    expect(reported, '');
  });
}
