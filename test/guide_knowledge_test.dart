import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final text = File('assets/data/guide_knowledge.md').readAsStringSync();

  test('guide knowledge stays under 15,000 words', () {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    expect(words.length, lessThan(15000));
  });

  test('every section heading names its guide page', () {
    final headings = RegExp(
      r'^#{2,3} .*$',
      multiLine: true,
    ).allMatches(text).map((match) => match.group(0)!);
    for (final heading in headings) {
      expect(
        heading,
        matches(RegExp(r'\((Guide pp?\. [\dIV, -]+|contents page)\)$')),
        reason: heading,
      );
    }
  });
}
