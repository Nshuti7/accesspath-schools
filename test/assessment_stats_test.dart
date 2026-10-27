import 'package:accesspath_schools/models/answer.dart';
import 'package:accesspath_schools/models/assessment_stats.dart';
import 'package:accesspath_schools/models/gap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Answer answer(String id, AnswerValue value) =>
      Answer(itemId: id, area: 'toilets', value: value, updatedBy: 'u1');

  Gap gap(String id, String status) => Gap(
    id: id,
    itemId: id,
    area: 'toilets',
    title: '',
    priority: 'high',
    source: Gap.sourceChecklist,
    status: status,
  );

  test('score is yes answers out of answers given, not out of all items', () {
    final stats = AssessmentStats.from(
      totalItems: 25,
      answers: [
        answer('a', AnswerValue.yes),
        answer('b', AnswerValue.yes),
        answer('c', AnswerValue.no),
        answer('d', AnswerValue.unsure),
      ],
      gaps: const [],
    );
    expect(stats.answeredCount, 4);
    expect(stats.scorePercent, 50);
  });

  test('no answers means no score rather than 0%', () {
    final stats = AssessmentStats.from(
      totalItems: 25,
      answers: const [],
      gaps: const [],
    );
    expect(stats.scorePercent, isNull);
  });

  test('gap counts treat verified gaps as open', () {
    final stats = AssessmentStats.from(
      totalItems: 25,
      answers: const [],
      gaps: [
        gap('a', Gap.statusOpen),
        gap('b', Gap.statusVerified),
        gap('c', Gap.statusNeedsVerification),
        gap('d', Gap.statusResolved),
      ],
    );
    expect(stats.openGaps, 2);
    expect(stats.needsVerificationGaps, 1);
    expect(stats.resolvedGaps, 1);
  });
}
