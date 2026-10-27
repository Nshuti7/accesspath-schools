import 'package:accesspath_schools/services/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validIds = {'ramps_handrails', 'toilets_grab_rails'};

  Matcher throwsUnreadable() => throwsA(
    isA<PhotoCheckException>().having(
      (error) => error.reason,
      'reason',
      PhotoCheckError.unreadableResponse,
    ),
  );

  test('reads a valid list of findings', () {
    final findings = GeminiService.parseFindings(
      '[{"itemId":"ramps_handrails","finding":"No handrail on the left.","confidence":"high"}]',
      validIds,
    );
    expect(findings, hasLength(1));
    expect(findings.single.itemId, 'ramps_handrails');
    expect(findings.single.confidence, 'high');
  });

  test('an empty list means no findings', () {
    expect(GeminiService.parseFindings('[]', validIds), isEmpty);
  });

  test('skips unknown ids and malformed entries, keeps the rest', () {
    final findings = GeminiService.parseFindings(
      '[{"itemId":"made_up","finding":"x","confidence":"high"},'
      '"not an object",'
      '{"itemId":"toilets_grab_rails","finding":"  "},'
      '{"itemId":"toilets_grab_rails","finding":"No rail.","confidence":"sure"}]',
      validIds,
    );
    expect(findings, hasLength(1));
    expect(findings.single.confidence, 'low');
  });

  test('broken JSON, empty text or a non-list throws unreadable', () {
    expect(
      () => GeminiService.parseFindings('[{"itemId":', validIds),
      throwsUnreadable(),
    );
    expect(() => GeminiService.parseFindings('', validIds), throwsUnreadable());
    expect(
      () => GeminiService.parseFindings(null, validIds),
      throwsUnreadable(),
    );
    expect(
      () => GeminiService.parseFindings('{"findings":[]}', validIds),
      throwsUnreadable(),
    );
  });
}
