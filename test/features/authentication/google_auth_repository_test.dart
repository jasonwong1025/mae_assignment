import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/data/services/auth_service.dart';
import 'package:mae_assignment/features/authentication/data/services/google_sign_in_service.dart';
import 'package:mae_assignment/features/authentication/data/services/user_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

class _FirebaseUser extends Fake implements User {
  _FirebaseUser(this.uid, this.email, this.displayName);

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
}

class _GoogleService extends Fake implements GoogleSignInService {
  User? account;
  int signOutCalls = 0;

  @override
  Future<User?> signIn() async => account;

  @override
  Future<void> signOut() async => signOutCalls++;
}

class _AuthService extends Fake implements AuthService {
  int signOutCalls = 0;

  @override
  Future<void> signOut() async => signOutCalls++;
}

class _UserService extends Fake implements UserService {
  AppUser? stored;
  Object? failure;
  int writes = 0;

  @override
  Future<AppUser> getOrCreateCustomer(AppUser customer) async {
    if (failure != null) throw failure!;
    if (stored != null) return stored!;
    writes++;
    return stored = customer;
  }
}

void main() {
  late _AuthService auth;
  late _GoogleService google;
  late _UserService users;
  late AuthRepository repository;

  setUp(() {
    auth = _AuthService();
    google = _GoogleService();
    users = _UserService();
    repository = AuthRepository(auth, users, google);
  });

  test('new Google customer gets one customer profile', () async {
    google.account = _FirebaseUser('uid-1', 'may@example.com', 'May Tan');

    final profile = await repository.signInWithGoogle();

    expect(profile?.uid, 'uid-1');
    expect(profile?.name, 'May Tan');
    expect(profile?.phone, '');
    expect(profile?.role, UserRole.customer);
    expect(users.writes, 1);
  });

  test('existing profile is reused without overwriting its details', () async {
    google.account = _FirebaseUser('uid-1', 'may@example.com', 'Google Name');
    users.stored = const AppUser(
      uid: 'uid-1',
      name: 'Preferred Name',
      email: 'may@example.com',
      phone: '0123456789',
      role: UserRole.customer,
    );

    final profile = await repository.signInWithGoogle();

    expect(profile?.name, 'Preferred Name');
    expect(profile?.phone, '0123456789');
    expect(users.writes, 0);
  });

  test('store role is rejected and Firebase session is ended', () async {
    google.account = _FirebaseUser('uid-1', 'admin@example.com', 'Admin');
    users.stored = const AppUser(
      uid: 'uid-1',
      name: 'Admin',
      email: 'admin@example.com',
      phone: '',
      role: UserRole.storeAdmin,
    );

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(isA<AuthException>()),
    );
    expect(users.writes, 0);
    expect(auth.signOutCalls, 1);
    expect(google.signOutCalls, 1);
  });

  test('cancellation leaves the session alone', () async {
    expect(await repository.signInWithGoogle(), isNull);
    expect(users.writes, 0);
    expect(auth.signOutCalls, 0);
  });

  test('profile failure ends the Firebase session', () async {
    google.account = _FirebaseUser('uid-1', 'may@example.com', 'May');
    users.failure = StateError('database unavailable');

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          contains('Could not load your account'),
        ),
      ),
    );
    expect(auth.signOutCalls, 1);
  });
}
