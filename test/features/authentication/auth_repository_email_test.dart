import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/hardcoded_admin.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/data/services/auth_service.dart';
import 'package:mae_assignment/features/authentication/data/services/google_sign_in_service.dart';
import 'package:mae_assignment/features/authentication/data/services/user_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

/// Device-free tests for AuthRepository's email flows, wiring the real
/// AuthService and UserService onto in-memory Firebase fakes. This is the
/// portable replacement for the Dart integration test: it exercises the real
/// orchestration (create account + write profile, hardcoded admin, sign-in
/// returning the stored profile) with no device, emulator or network.
/// These email-flow tests never trigger Google sign-in, but AuthRepository
/// calls GoogleSignInService.signOut() during signOut(), so that one method
/// is a no-op here.
class _UnusedGoogleService extends Fake implements GoogleSignInService {
  @override
  Future<void> signOut() async {}
}

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late AuthRepository repository;

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    repository = AuthRepository(
      AuthService(auth),
      UserService(firestore),
      _UnusedGoogleService(),
    );
  });

  group('signUp', () {
    test('creates a Firebase account and a customer profile', () async {
      final user = await repository.signUp(
        name: 'May',
        email: 'may@example.com',
        phone: '0123456789',
        password: 'password123',
      );

      expect(user.role, UserRole.customer);
      expect(user.name, 'May');
      expect(repository.isSignedIn, isTrue);

      // The profile really landed in Firestore under the account uid.
      final stored = await firestore.collection('users').doc(user.uid).get();
      expect(stored.exists, isTrue);
      expect(stored.data()!['role'], 'customer');
    });
  });

  group('signIn', () {
    test('returns the stored profile for a real account', () async {
      // Arrange: an account that has already signed up.
      final created = await repository.signUp(
        name: 'May',
        email: 'may@example.com',
        phone: '0123456789',
        password: 'password123',
      );
      await repository.signOut();
      expect(repository.isSignedIn, isFalse);

      // Act
      final user = await repository.signIn(
        email: 'may@example.com',
        password: 'password123',
      );

      // Assert: same profile, now signed in.
      expect(user.uid, created.uid);
      expect(user.name, 'May');
      expect(repository.isSignedIn, isTrue);
    });

    test('hardcoded admin signs in without touching Firebase', () async {
      final user = await repository.signIn(
        email: HardcodedAdmin.email,
        password: HardcodedAdmin.password,
      );

      expect(user.role, UserRole.storeAdmin);
      expect(repository.isSignedIn, isTrue);
      // No real Firebase account was created for the admin.
      expect(auth.currentUser, isNull);
    });

    test('missing profile ends the session and reports an error', () async {
      // A Firebase account exists but no users/{uid} profile was written.
      await auth.createUserWithEmailAndPassword(
        email: 'ghost@example.com',
        password: 'password123',
      );
      await auth.signOut();

      await expectLater(
        repository.signIn(email: 'ghost@example.com', password: 'password123'),
        throwsA(isA<AuthException>()),
      );
      expect(repository.isSignedIn, isFalse);
    });
  });

  group('getCurrentUser', () {
    test('returns null when nobody is signed in', () async {
      expect(await repository.getCurrentUser(), isNull);
    });

    test('returns the profile after sign-up', () async {
      await repository.signUp(
        name: 'May',
        email: 'may@example.com',
        phone: '',
        password: 'password123',
      );

      final current = await repository.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.email, 'may@example.com');
    });
  });
}
