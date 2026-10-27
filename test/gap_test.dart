import 'package:accesspath_schools/models/answer.dart';
import 'package:accesspath_schools/models/checklist_item.dart';
import 'package:accesspath_schools/models/gap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const item = ChecklistItem(
    id: 'ramps_handrails',
    area: 'ramps_pathways',
    question: 'Do ramps have a handrail on both sides?',
    whyItMatters: '',
    guideRef: '12',
    defaultPriority: 'medium',
  );

  Gap? after(AnswerValue value, Gap? existing) =>
      Gap.afterChecklistAnswer(item: item, value: value, existing: existing);

  Gap existingWith(String status) => Gap(
    id: item.id,
    itemId: item.id,
    area: item.area,
    title: item.question,
    priority: 'high',
    source: Gap.sourceChecklist,
    status: status,
  );

  test('No creates an open gap keyed by the item id', () {
    final gap = after(AnswerValue.no, null)!;
    expect(gap.id, item.id);
    expect(gap.status, Gap.statusOpen);
    expect(gap.priority, 'medium');
    expect(gap.source, Gap.sourceChecklist);
  });

  test('Unsure creates a gap that needs verification', () {
    expect(
      after(AnswerValue.unsure, null)!.status,
      Gap.statusNeedsVerification,
    );
  });

  test('Yes with no earlier gap writes nothing', () {
    expect(after(AnswerValue.yes, null), isNull);
  });

  test('Yes resolves an existing gap and keeps its priority', () {
    final gap = after(AnswerValue.yes, existingWith(Gap.statusOpen))!;
    expect(gap.status, Gap.statusResolved);
    expect(gap.priority, 'high');
  });

  test('No reopens a resolved gap', () {
    final gap = after(AnswerValue.no, existingWith(Gap.statusResolved))!;
    expect(gap.status, Gap.statusOpen);
  });

  test('No keeps a verified gap verified, so nothing is written', () {
    expect(after(AnswerValue.no, existingWith(Gap.statusVerified)), isNull);
  });

  test('Same status as before writes nothing', () {
    expect(after(AnswerValue.no, existingWith(Gap.statusOpen)), isNull);
  });
}
