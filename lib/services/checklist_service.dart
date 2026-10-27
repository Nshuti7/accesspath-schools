import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/checklist_item.dart';

class ChecklistService {
  ChecklistService({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _assetPath = 'assets/data/checklist.json';

  final AssetBundle _bundle;
  List<ChecklistItem>? _cache;

  /// The checklist ships with the app and never changes while it runs, so it
  /// is read once and reused.
  Future<List<ChecklistItem>> loadChecklist() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    final items = List<ChecklistItem>.unmodifiable(
      decoded.map(
        (entry) => ChecklistItem.fromMap(entry as Map<String, dynamic>),
      ),
    );
    _cache = items;
    return items;
  }

  Future<List<ChecklistItem>> loadChecklistForArea(String area) async {
    final items = await loadChecklist();
    return items.where((item) => item.area == area).toList();
  }
}
