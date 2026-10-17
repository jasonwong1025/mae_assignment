import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/app_user.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(userServiceProvider),
  );
});

/// Profile of the signed-in user, or null if nobody is signed in.
final currentUserProvider = FutureProvider.autoDispose<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

/// Error with a message that is safe to show on screen.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sign-up, sign-in and sign-out. Combines the Firebase account
/// (AuthService) with the user's profile in Firestore (UserService),
/// and turns Firebase errors into friendly messages.
class AuthRepository {
  AuthRepository(this._authService, this._userService);

  /// Firestore keeps retrying when it cannot reach the server (no internet,
  /// database missing), so without a limit the page would load forever.
  static const Duration _firestoreTimeout = Duration(seconds: 15);

  final AuthService _authService;
  final UserService _userService;

  bool get isSignedIn => _authService.isSignedIn;

  /// Creates a customer account. Public sign-up is for customers only;
  /// staff accounts are set up separately.
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final User account;
    try {
      account = await _authService.createAccount(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }

    final user = AppUser(
      uid: account.uid,
      name: name,
      email: email,
      phone: phone,
      role: UserRole.customer,
    );

    try {
      await _userService.createUser(user).timeout(_firestoreTimeout);
    } catch (_) {
      // Without a profile the account is unusable, so remove it and let
      // the user try again with the same email.
      await _authService.deleteCurrentUser();
      throw const AuthException(
        'Could not save your details. Please check your connection '
        'and try again.',
      );
    }

    return user;
  }

  /// Signs in and returns the user's profile.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final User account;
    try {
      account = await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }

    final AppUser? user;
    try {
      user = await _userService.getUser(account.uid).timeout(_firestoreTimeout);
    } catch (_) {
      await _authService.signOut();
      throw const AuthException(
        'Could not load your account. Please check your connection '
        'and try again.',
      );
    }

    if (user == null) {
      await _authService.signOut();
      throw const AuthException(
        'Your account details are missing. Please contact support.',
      );
    }
    if (!user.isActive) {
      await _authService.signOut();
      throw const AuthException(
        'Your account was deactivated. Please contact your manager.',
      );
    }
    return user;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Profile of the signed-in user, or null if nobody is signed in.
  Future<AppUser?> getCurrentUser() async {
    final account = _authService.currentUser;
    if (account == null) return null;
    return _userService.getUser(account.uid);
  }

  /// Firebase error codes: https://firebase.google.com/docs/auth/admin/errors
  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      // Newer Firebase versions return "invalid-credential" for both a
      // wrong password and an unknown email, so we cannot tell which.
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check and try again.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled yet.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
