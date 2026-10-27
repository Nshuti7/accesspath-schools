import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../strings.dart';

/// Holds who is logged in. The router listens to this to decide which screen
/// to show, so logging in or out moves the user automatically.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, FirestoreService? firestoreService})
    : _authService = authService ?? AuthService(),
      _firestoreService = firestoreService ?? FirestoreService() {
    _user = _authService.currentUser;
    _subscription = _authService.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  late final StreamSubscription<User?> _subscription;

  User? _user;
  bool _isBusy = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _authService.signIn(email: email, password: password));
  }

  Future<bool> signUp({
    required String name,
    required String schoolName,
    required String email,
    required String password,
  }) {
    return _run(() async {
      final user = await _authService.createAccount(
        email: email,
        password: password,
      );
      try {
        await _firestoreService.createSchoolWithAdmin(
          uid: user.uid,
          name: name,
          email: email,
          schoolName: schoolName,
        );
      } catch (_) {
        // Without the school record the account is unusable, so remove it
        // and let the user try again with the same email.
        await user.delete();
        rethrow;
      }
    });
  }

  Future<void> signOut() => _authService.signOut();

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (error) {
      _errorMessage = AuthService.messageFor(error);
      return false;
    } catch (_) {
      _errorMessage = AppStrings.errorGeneric;
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
