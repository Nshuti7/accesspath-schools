import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/action_item.dart';
import '../models/gap.dart';
import '../services/firestore_service.dart';
import '../strings.dart';

/// Holds this school's actions. Fed the school id by AssessmentProvider, so
/// it loads by itself once the school is known.
class ActionProvider extends ChangeNotifier {
  ActionProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  String? _schoolId;
  final Map<String, ActionItem> _actions = {};
  bool _isLoading = false;
  bool _isReady = false;
  String? _errorMessage;

  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;

  /// Soonest due first.
  List<ActionItem> get actions =>
      _actions.values.toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  int overdueCount(DateTime now) =>
      _actions.values.where((action) => action.isOverdueOn(now)).length;

  ActionItem? actionForGap(String gapId) {
    for (final action in _actions.values) {
      if (action.gapId == gapId) return action;
    }
    return null;
  }

  void setSchool(String? schoolId) {
    if (schoolId == _schoolId) return;
    _schoolId = schoolId;
    _actions.clear();
    _isReady = false;
    _errorMessage = null;
    // This runs inside a provider update during build, where notifying is not
    // allowed, so start loading just after it.
    if (schoolId != null) scheduleMicrotask(load);
  }

  Future<void> load() async {
    final schoolId = _schoolId;
    if (schoolId == null || _isLoading) return;

    _isLoading = true;
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final actions = await _firestoreService.loadActions(schoolId);
      if (schoolId != _schoolId) return;
      _actions
        ..clear()
        ..addEntries(actions.map((action) => MapEntry(action.id, action)));
      _isReady = true;
    } catch (_) {
      _errorMessage = AppStrings.errorLoadActions;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAction({
    required Gap gap,
    required String title,
    required String ownerName,
    required DateTime dueDate,
    required String notes,
  }) async {
    final schoolId = _schoolId;
    if (schoolId == null) return false;

    final draft = ActionItem(
      id: '',
      gapId: gap.id,
      title: title,
      ownerName: ownerName,
      dueDate: dueDate,
      notes: notes,
    );
    try {
      final id = await _firestoreService.addAction(schoolId, draft);
      _actions[id] = draft.copyWith(id: id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Shows the new status straight away; reverts and returns false if the
  /// save fails.
  Future<bool> setStatus(ActionItem action, String status) async {
    final schoolId = _schoolId;
    if (schoolId == null) return false;

    final updated = action.copyWith(status: status);
    _actions[action.id] = updated;
    notifyListeners();
    try {
      await _firestoreService.updateActionStatus(schoolId, action.id, status);
      return true;
    } catch (_) {
      if (identical(_actions[action.id], updated)) {
        _actions[action.id] = action;
        notifyListeners();
      }
      return false;
    }
  }
}
