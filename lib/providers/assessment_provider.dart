import 'package:flutter/foundation.dart';

import '../models/answer.dart';
import '../models/checklist_item.dart';
import '../models/gap.dart';
import '../models/photo_finding.dart';
import '../services/checklist_service.dart';
import '../services/firestore_service.dart';
import '../strings.dart';

/// Holds the checklist and this school's answers and gaps. Shared by the
/// Areas, Checklist, Photo check and Gap report screens so each one shows a
/// change as soon as it is made on another.
class AssessmentProvider extends ChangeNotifier {
  AssessmentProvider({
    ChecklistService? checklistService,
    FirestoreService? firestoreService,
  }) : _checklistService = checklistService ?? ChecklistService(),
       _firestoreService = firestoreService ?? FirestoreService();

  final ChecklistService _checklistService;
  final FirestoreService _firestoreService;

  String? _uid;
  String? _schoolId;
  List<ChecklistItem> _items = const [];
  final Map<String, Answer> _answers = {};
  final Map<String, Gap> _gaps = {};
  bool _isLoading = false;
  bool _isReady = false;
  String? _errorMessage;

  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;
  List<Gap> get gaps => List.unmodifiable(_gaps.values);

  /// Only set once loading has finished, so listeners can rely on it.
  String? get schoolId => _isReady ? _schoolId : null;

  Gap? gapById(String gapId) => _gaps[gapId];

  /// Called whenever the logged-in user changes. Clears the old school's data
  /// so the next person on a shared device never sees it.
  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _schoolId = null;
    _answers.clear();
    _gaps.clear();
    _isReady = false;
    _errorMessage = null;
  }

  Future<void> ensureLoaded() async {
    final uid = _uid;
    if (_isReady || _isLoading || uid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _checklistService.loadChecklist();
      final user = await _firestoreService.getUser(uid);
      if (user == null) throw StateError('No profile for $uid');
      final (answers, gaps) = await (
        _firestoreService.loadAnswers(user.schoolId),
        _firestoreService.loadGaps(user.schoolId),
      ).wait;
      // The user logged out while we were loading; drop the results.
      if (uid != _uid) return;
      _schoolId = user.schoolId;
      _answers
        ..clear()
        ..addEntries(answers.map((answer) => MapEntry(answer.itemId, answer)));
      _gaps
        ..clear()
        ..addEntries(gaps.map((gap) => MapEntry(gap.id, gap)));
      _isReady = true;
    } catch (_) {
      _errorMessage = AppStrings.errorLoadAssessment;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ChecklistItem> itemsForArea(String area) {
    return _items.where((item) => item.area == area).toList();
  }

  int answeredCountForArea(String area) {
    return _answers.values.where((answer) => answer.area == area).length;
  }

  AnswerValue? answerFor(String itemId) => _answers[itemId]?.value;

  ChecklistItem? itemById(String itemId) {
    for (final item in _items) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  /// Records a photo finding the user accepted as an open gap.
  Future<bool> addGapFromPhoto(ChecklistItem item, PhotoFinding finding) async {
    final schoolId = _schoolId;
    if (schoolId == null) return false;

    final gap = Gap(
      id: '',
      itemId: item.id,
      area: item.area,
      title: item.question,
      priority: item.defaultPriority,
      source: Gap.sourceAiPhoto,
      aiDescription: finding.finding,
    );
    try {
      final id = await _firestoreService.addGap(schoolId, gap);
      _gaps[id] = gap.copyWith(id: id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Used by the Action tracker when an action is done and the user confirms
  /// the gap is fixed. Reverts and returns false if the save fails.
  Future<bool> setGapStatus(String gapId, String status) async {
    final schoolId = _schoolId;
    final previous = _gaps[gapId];
    if (schoolId == null || previous == null) return false;

    final updated = previous.copyWith(status: status);
    _gaps[gapId] = updated;
    notifyListeners();
    try {
      await _firestoreService.updateGapStatus(schoolId, gapId, status);
      return true;
    } catch (_) {
      if (identical(_gaps[gapId], updated)) {
        _gaps[gapId] = previous;
        notifyListeners();
      }
      return false;
    }
  }

  /// Shows the new answer (and its checklist gap) straight away, then saves
  /// both. Returns false if the save failed, after putting the old ones back.
  Future<bool> setAnswer(ChecklistItem item, AnswerValue value) async {
    final schoolId = _schoolId;
    final uid = _uid;
    if (schoolId == null || uid == null) return false;

    final previous = _answers[item.id];
    final answer = Answer(
      itemId: item.id,
      area: item.area,
      value: value,
      updatedBy: uid,
      note: previous?.note ?? '',
    );
    // A checklist gap's doc id is its item id; photo gaps never use that id.
    final previousGap = _gaps[item.id];
    final gap = Gap.afterChecklistAnswer(
      item: item,
      value: value,
      existing: previousGap,
    );
    _answers[item.id] = answer;
    if (gap != null) _gaps[item.id] = gap;
    notifyListeners();

    try {
      await _firestoreService.saveAnswer(schoolId, answer, checklistGap: gap);
      return true;
    } catch (_) {
      // Only roll back if no newer tap has replaced these meanwhile.
      if (identical(_answers[item.id], answer)) {
        _restore(_answers, item.id, previous);
        if (gap != null) _restore(_gaps, item.id, previousGap);
        notifyListeners();
      }
      return false;
    }
  }

  static void _restore<T>(Map<String, T> map, String key, T? previous) {
    if (previous == null) {
      map.remove(key);
    } else {
      map[key] = previous;
    }
  }
}
