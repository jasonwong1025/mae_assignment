import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

/// Thin wrapper around Firebase Authentication.
/// Only talks to Firebase; error messages and profiles are handled
/// by AuthRepository.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// The signed-in account, or null. Firebase remembers it between app
  /// launches, so users stay signed in.
  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  /// The signed-in uid, or null when signed out. Emits the current value on
  /// listen and again whenever the user signs in or out.
  Stream<String?> get uidChanges =>
      _auth.authStateChanges().map((user) => user?.uid).distinct();

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

  Future<User> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Asks the backend to refresh the signed-in account. Throws a
  /// [FirebaseAuthException] such as `user-token-expired` when the saved
  /// session is no longer valid. Does nothing when signed out.
  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  /// Deletes the signed-in account. Used to undo a sign-up that failed
  /// halfway, so the same email can be used again.
  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }
}
