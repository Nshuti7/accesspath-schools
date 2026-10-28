import 'package:accesspath_schools/models/report_summary.dart';
import 'package:accesspath_schools/screens/gaps/report_summary_controller.dart';
import 'package:accesspath_schools/services/ai_call.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const summary = ReportSummary(
    overview: 'Overview.',
    priorities: [],
    nextSteps: [],
  );

  test('keeps the summary after a successful request', () async {
    final controller = ReportSummaryController(() async => summary);
    await controller.generate();
    expect(controller.summary, summary);
    expect(controller.error, isNull);
    expect(controller.isLoading, isFalse);
  });

  test('keeps the friendly error when the request fails', () async {
    final controller = ReportSummaryController(
      () async => throw const AiException(AiError.offline),
    );
    await controller.generate();
    expect(controller.summary, isNull);
    expect(controller.error, AiError.offline);
  });
}
