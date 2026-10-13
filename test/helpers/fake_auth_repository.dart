import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

/// Stand-in for AuthRepository so tests don't need a real Firebase project.
/// Methods that are not overridden throw if called (that's what Fake does).
class FakeAuthRepository extends Fake implements AuthRepository {
  /// The user signIn() returns. Null makes signIn() fail.
  AppUser? userToSignIn;

  /// If set, signUp() and signIn() throw this.
  AuthException? errorToThrow;

  bool signedIn = false;
  String? lastSignUpPhone;

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    lastSignUpPhone = phone;
    signedIn = true;
    return AppUser(
      uid: 'uid-1',
      name: name,
      email: email,
      phone: phone,
      role: UserRole.customer,
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (userToSignIn == null) {
      throw const AuthException('Incorrect email or password.');
    }
    signedIn = true;
    return userToSignIn!;
  }

  @override
  Future<void> signOut() async {
    signedIn = false;
  }
}
