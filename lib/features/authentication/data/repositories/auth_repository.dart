import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/features/authentication/data/services/auth_service.dart';
import 'package:mae_assignment/features/authentication/data/services/google_sign_in_service.dart';
import 'package:mae_assignment/features/authentication/data/services/user_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authServiceProvider),
    ref.watch(userServiceProvider),
    ref.watch(googleSignInServiceProvider),
  );
});

/// Profile of the signed-in user, or null if nobody is signed in.
final FutureProvider<AppUser?> currentUserProvider =
    FutureProvider.autoDispose<AppUser?>((ref) {
      return ref.watch(authRepositoryProvider).getCurrentUser();
    });

/// The signed-in uid (null when signed out), following every sign-in and
/// sign-out.
final StreamProvider<String?> authUidProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).uidChanges;
});

/// Error with a message that is safe to show on screen.
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Sign-up, sign-in and sign-out. Combines the Firebase account
/// (AuthService) with the user's profile in Firestore (UserService),
/// and turns Firebase errors into friendly messages.
class AuthRepository {
  AuthRepository(
    this._authService,
    this._userService,
    this._googleSignInService,
  );

  final AuthService _authService;
  final UserService _userService;
  final GoogleSignInService _googleSignInService;

  bool get isSignedIn => _authService.isSignedIn;

  /// The signed-in uid (null when signed out), emitted on every change.
  Stream<String?> get uidChanges => _authService.uidChanges;

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
      await _userService.createUser(user).timeout(FirestoreConfig.readTimeout);
    } on Object catch (_) {
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
      user = await _userService
          .getUser(account.uid)
          .timeout(FirestoreConfig.readTimeout);
    } on Object catch (_) {
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

  /// Google is offered to customers only. A new Firebase account receives a
  /// customer profile; an existing profile is preserved and checked.
  Future<AppUser?> signInWithGoogle() async {
    final User? account;
    try {
      account = await _googleSignInService.signIn();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'operation-not-allowed') {
        throw const AuthException('Google sign-in is not enabled yet.');
      }
      throw AuthException(_messageFor(error));
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
        throw const AuthException(
          'Google sign-in is not configured for this app yet.',
        );
      }
      throw const AuthException(
        'Could not sign in with Google. Please try again.',
      );
    } on GoogleSignInTokenException {
      throw const AuthException(
        'Google could not verify this account. Please try again.',
      );
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Google sign-in failed before Firebase authentication completed.',
        name: 'grocerly.auth',
        error: error,
        stackTrace: stackTrace,
      );
      throw const AuthException(
        'Could not sign in with Google. Please try again.',
      );
    }

    if (account == null) return null;
    final email = account.email;
    if (email == null || email.isEmpty) {
      await signOut();
      throw const AuthException('Google did not provide an email address.');
    }

    final proposedCustomer = AppUser(
      uid: account.uid,
      name: account.displayName?.trim().isNotEmpty == true
          ? account.displayName!.trim()
          : email.split('@').first,
      email: email,
      phone: '',
      role: UserRole.customer,
    );

    final AppUser profile;
    try {
      profile = await _userService
          .getOrCreateCustomer(proposedCustomer)
          .timeout(FirestoreConfig.readTimeout);
    } on Object catch (_) {
      await signOut();
      throw const AuthException(
        'Could not load your account. Please check your connection '
        'and try again.',
      );
    }

    if (profile.role != UserRole.customer) {
      await signOut();
      throw const AuthException(
        'This account belongs to a store role. Please use its regular sign-in.',
      );
    }
    return profile;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    try {
      await _googleSignInService.signOut();
    } on Exception catch (error, stackTrace) {
      // The Firebase session has ended even if the optional Google chooser
      // cleanup fails. Keep the user signed out and record the failure.
      developer.log(
        'Google account chooser cleanup failed after Firebase sign-out.',
        name: 'grocerly.auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Error codes that mean the saved session can never work again (account
  /// deleted or disabled, tokens revoked, or the session came from another
  /// backend such as the emulator).
  static const Set<String> _deadSessionCodes = {
    'user-token-expired',
    'invalid-user-token',
    'user-not-found',
    'user-disabled',
  };

  /// Firebase keeps a user signed in on the device until the backend
  /// rejects their refresh token, and does not tell the app when that
  /// happens. Call this on app start: it asks the backend to refresh the
  /// account and signs out if the session is dead.
  ///
  /// Offline or slow connections are not a reason to sign out, so any other
  /// failure leaves the user signed in.
  Future<void> endDeadSession() async {
    if (!_authService.isSignedIn) return;
    try {
      await _authService.reloadCurrentUser().timeout(
        FirestoreConfig.readTimeout,
      );
    } on FirebaseAuthException catch (error) {
      if (_deadSessionCodes.contains(error.code)) await signOut();
    } on Object catch (error) {
      developer.log(
        'Could not check the saved session; keeping the user signed in.',
        name: 'grocerly.auth',
        error: error,
      );
    }
  }

  /// Profile of the signed-in user, or null if nobody is signed in.
  Future<AppUser?> getCurrentUser() async {
    final account = _authService.currentUser;
    if (account == null) return null;
    return await _userService
        .getUser(account.uid)
        .timeout(FirestoreConfig.readTimeout);
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
