import 'dart:convert';
import 'dart:io';

import 'package:accesspath_schools/models/checklist_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final raw = File('assets/data/checklist.json').readAsStringSync();
  final items = (jsonDecode(raw) as List<dynamic>)
      .map((entry) => ChecklistItem.fromMap(entry as Map<String, dynamic>))
      .toList();

  test('item ids are unique', () {
    expect(items.map((item) => item.id).toSet(), hasLength(items.length));
  });

  test('every recommendation says where it comes from', () {
    final source = RegExp(r'\((Guide pp?\. [\d, ]+|general guidance)\)\.?$');
    for (final item in items) {
      expect(
        source.hasMatch(item.recommendation),
        isTrue,
        reason: '${item.id}: "${item.recommendation}"',
      );
    }
  });
}
