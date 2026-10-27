import 'package:flutter/foundation.dart';

import '../models/answer.dart';
import '../models/checklist_item.dart';
import '../services/checklist_service.dart';
import '../services/firestore_service.dart';
import '../strings.dart';

/// Holds the checklist and this school's answers. Shared by the Areas and
/// Checklist screens so progress on the Areas screen updates as soon as an
/// answer is tapped.
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
  bool _isLoading = false;
  bool _isReady = false;
  String? _errorMessage;

  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;

  /// Called whenever the logged-in user changes. Clears the old school's data
  /// so the next person on a shared device never sees it.
  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _schoolId = null;
    _answers.clear();
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
      final answers = await _firestoreService.loadAnswers(user.schoolId);
      // The user logged out while we were loading; drop the results.
      if (uid != _uid) return;
      _schoolId = user.schoolId;
      _answers
        ..clear()
        ..addEntries(answers.map((answer) => MapEntry(answer.itemId, answer)));
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

  /// Shows the new answer straight away, then saves it. Returns false if the
  /// save failed, after putting the previous answer back.
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
    _answers[item.id] = answer;
    notifyListeners();

    try {
      await _firestoreService.saveAnswer(schoolId, answer);
      return true;
    } catch (_) {
      // Only roll back if no newer tap has replaced this answer meanwhile.
      if (identical(_answers[item.id], answer)) {
        if (previous == null) {
          _answers.remove(item.id);
        } else {
          _answers[item.id] = previous;
        }
        notifyListeners();
      }
      return false;
    }
  }
}
