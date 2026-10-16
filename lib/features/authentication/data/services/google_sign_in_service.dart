import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService(FirebaseAuth.instance, GoogleSignIn.instance);
});

/// Exchanges a Google account for a Firebase session. Firebase remains the
/// source of truth for whether the user is signed in.
class GoogleSignInService {
  GoogleSignInService(this._auth, this._google);

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  Future<void>? _initialization;

  /// Returns null when the user closes the account chooser or web popup.
  Future<User?> signIn() async {
    if (kIsWeb) {
      try {
        final credential = await _auth.signInWithPopup(GoogleAuthProvider());
        return credential.user;
      } on FirebaseAuthException catch (error) {
        if (error.code == 'popup-closed-by-user' ||
            error.code == 'cancelled-popup-request') {
          return null;
        }
        rethrow;
      }
    }

    // google_sign_in 7.x requires initialization exactly once before use.
    await (_initialization ??= _google.initialize());
    try {
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const GoogleSignInTokenException();
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return (await _auth.signInWithCredential(credential)).user;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb && _initialization != null) {
      await _google.signOut();
    }
  }
}

class GoogleSignInTokenException implements Exception {
  const GoogleSignInTokenException();
}
