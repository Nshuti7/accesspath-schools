import 'package:firebase_auth/firebase_auth.dart';

import '../strings.dart';

/// Thin wrapper around Firebase Auth so screens never talk to Firebase directly.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<User> createAccount({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<void> signOut() => _auth.signOut();

  /// Turns Firebase error codes into short messages a school staff member can act on.
  static String messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return AppStrings.errorInvalidEmail;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.errorWrongLogin;
      case 'email-already-in-use':
        return AppStrings.errorEmailInUse;
      case 'weak-password':
        return AppStrings.errorWeakPassword;
      case 'user-disabled':
        return AppStrings.errorAccountDisabled;
      case 'network-request-failed':
        return AppStrings.errorOffline;
      case 'too-many-requests':
        return AppStrings.errorTooManyTries;
      default:
        return AppStrings.errorGeneric;
    }
  }
}
