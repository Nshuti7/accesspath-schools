import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/school.dart';
import '../services/firestore_service.dart';
import '../strings.dart';

/// The one place that looks up who is logged in and which school they belong
/// to. The other data providers wait for [schoolId] before loading.
class SchoolProvider extends ChangeNotifier {
  SchoolProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  String? _uid;
  AppUser? _user;
  School? _school;
  bool _isLoading = false;
  bool _isReady = false;
  String? _errorMessage;

  bool get isReady => _isReady;
  String? get errorMessage => _errorMessage;
  String? get uid => _uid;
  AppUser? get user => _user;
  School? get school => _school;

  /// Null until the school has loaded, so listeners can rely on it.
  String? get schoolId => _isReady ? _school?.id : null;

  /// Called whenever the logged-in user changes. Clears the old school so the
  /// next person on a shared device never sees it.
  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _user = null;
    _school = null;
    _isReady = false;
    _errorMessage = null;
    // This runs inside a provider update during build, where notifying is not
    // allowed, so start loading just after it.
    if (uid != null) scheduleMicrotask(load);
  }

  Future<void> load() async {
    final uid = _uid;
    if (uid == null || _isLoading) return;

    _isLoading = true;
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final user = await _firestoreService.getUser(uid);
      if (user == null) throw StateError('No profile for $uid');
      final school = await _firestoreService.getSchool(user.schoolId);
      if (school == null) throw StateError('No school ${user.schoolId}');
      // The user logged out while we were loading; drop the results.
      if (uid != _uid) return;
      _user = user;
      _school = school;
      _isReady = true;
    } catch (_) {
      _errorMessage = AppStrings.errorLoadSchool;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
