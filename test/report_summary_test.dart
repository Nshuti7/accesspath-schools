import 'package:accesspath_schools/models/action_item.dart';
import 'package:accesspath_schools/models/assessment_stats.dart';
import 'package:accesspath_schools/models/checklist_item.dart';
import 'package:accesspath_schools/models/gap.dart';
import 'package:accesspath_schools/models/report_summary.dart';
import 'package:accesspath_schools/services/ai_call.dart';
import 'package:accesspath_schools/services/report_summary_service.dart';
import 'package:accesspath_schools/strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ramp = ChecklistItem(
    id: 'ramps_gradient',
    area: 'ramps_pathways',
    question: 'Is the ramp no steeper than 1:12?',
    whyItMatters: '',
    recommendation: 'Rebuild the ramp at 1:20 (Guide p. 31).',
    guideRef: '12',
    defaultPriority: 'high',
  );

  Gap gap(String id, String status) => Gap(
    id: id,
    itemId: ramp.id,
    area: ramp.area,
    title: ramp.question,
    priority: 'high',
    source: Gap.sourceChecklist,
    status: status,
  );

  ActionItem action(String id, DateTime due, String status) => ActionItem(
    id: id,
    gapId: 'g1',
    title: 'Fix ramp',
    ownerName: 'Grace',
    dueDate: due,
    status: status,
  );

  test('report data holds unresolved gaps and overdue actions only', () {
    final now = DateTime(2026, 10, 27);
    final data = ReportSummaryService.buildReportData(
      schoolName: 'Kololo Primary',
      stats: const AssessmentStats(
        totalItems: 25,
        answeredCount: 10,
        yesCount: 6,
        openGaps: 1,
        needsVerificationGaps: 1,
        resolvedGaps: 1,
      ),
      gaps: [
        gap('g1', Gap.statusOpen),
        gap('g2', Gap.statusNeedsVerification),
        gap('g3', Gap.statusResolved),
      ],
      itemById: (id) => id == ramp.id ? ramp : null,
      actions: [
        action('a1', DateTime(2026, 10, 1), ActionItem.statusTodo),
        action('a2', DateTime(2026, 10, 1), ActionItem.statusDone),
        action('a3', DateTime(2026, 11, 1), ActionItem.statusTodo),
      ],
      now: now,
    );

    expect(data['scorePercent'], 60);
    final gaps = data['gaps']! as List;
    expect(gaps, hasLength(2));
    expect((gaps.first as Map)['guidePage'], '12');
    expect((gaps.last as Map)['status'], 'needs checking');
    final overdue = data['overdueActions']! as List;
    expect(overdue, hasLength(1));
    expect((overdue.single as Map)['dueDate'], '2026-10-01');
  });

  test('a summary reply is parsed and capped at three priorities', () {
    final summary = ReportSummaryService.parseSummary('''
      {"overview": "Ten of 25 questions answered.",
       "priorities": [{"title": "A", "reason": "a"}, {"title": "B"},
                      {"title": ""}, {"title": "C", "reason": "c"},
                      {"title": "D", "reason": "d"}],
       "nextSteps": ["Fix the ramp", 3, ""]}''');

    expect(summary.overview, 'Ten of 25 questions answered.');
    expect(summary.priorities.map((p) => p.title), ['A', 'B', 'C']);
    expect(summary.nextSteps, ['Fix the ramp']);
  });

  test('bad replies become an unreadable-response error', () {
    final unreadable = throwsA(
      isA<AiException>().having(
        (error) => error.reason,
        'reason',
        AiError.unreadableResponse,
      ),
    );
    expect(() => ReportSummaryService.parseSummary('not json'), unreadable);
    expect(() => ReportSummaryService.parseSummary('[]'), unreadable);
    expect(
      () => ReportSummaryService.parseSummary('{"overview": ""}'),
      unreadable,
    );
  });

  test('copied text keeps the AI label', () {
    const summary = ReportSummary(
      overview: 'Overview.',
      priorities: [(title: 'Ramp', reason: 'Too steep (Guide p. 12).')],
      nextSteps: ['Assign an owner'],
    );
    final text = summary.toPlainText();
    expect(text, startsWith(AppStrings.aiSummaryLabel));
    expect(text, contains('1. Ramp: Too steep (Guide p. 12).'));
    expect(text, contains('- Assign an owner'));
  });
}
