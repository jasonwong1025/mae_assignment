import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mae_assignment/core/firebase/firebase_emulators.dart';
import 'package:mae_assignment/features/authentication/data/services/auth_service.dart';
import 'package:mae_assignment/features/authentication/data/services/user_service.dart';
import 'package:mae_assignment/firebase_options.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

/// Layer 3 tests: the real Firebase SDKs against the Emulator Suite.
///
/// Run with the emulators up and the flag set, e.g.:
///   fvm flutter test integration_test -d linux \
///     --dart-define=USE_FIREBASE_EMULATOR=true
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late UserService userService;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // These tests only make sense against the emulators; refuse to run
    // against the shared project so a stray run cannot create real accounts.
    if (!FirebaseEmulators.enabled) {
      fail(
        'Run with --dart-define=USE_FIREBASE_EMULATOR=true so these tests '
        'use the emulators, not the shared Firebase project.',
      );
    }
    FirebaseEmulators.connect();
    authService = AuthService(FirebaseAuth.instance);
    userService = UserService(FirebaseFirestore.instance);
  });

  // A clean slate per test: sign out and remove any account left behind.
  tearDown(() async {
    await FirebaseAuth.instance.currentUser?.delete().catchError((_) {});
    await FirebaseAuth.instance.signOut();
  });

  group('AuthService', () {
    test('creates an account and signs it back in', () async {
      const email = 'customer1@example.com';
      const password = 'password123';

      final created = await authService.createAccount(
        email: email,
        password: password,
      );
      expect(created.email, email);
      expect(authService.isSignedIn, isTrue);

      await authService.signOut();
      expect(authService.isSignedIn, isFalse);

      final signedIn = await authService.signIn(
        email: email,
        password: password,
      );
      expect(signedIn.uid, created.uid);
    });

    test('wrong password is rejected', () async {
      const email = 'customer2@example.com';
      await authService.createAccount(email: email, password: 'password123');
      await authService.signOut();

      await expectLater(
        authService.signIn(email: email, password: 'wrong-password'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  group('UserService', () {
    test('creates then reads a profile', () async {
      final account = await authService.createAccount(
        email: 'customer3@example.com',
        password: 'password123',
      );
      final user = AppUser(
        uid: account.uid,
        name: 'May',
        email: 'customer3@example.com',
        phone: '0123456789',
        role: UserRole.customer,
      );

      await userService.createUser(user);
      final loaded = await userService.getUser(account.uid);

      expect(loaded, isNotNull);
      expect(loaded!.name, 'May');
      expect(loaded.role, UserRole.customer);
      expect(loaded.createdAt, isNotNull); // server timestamp resolved
    });

    test('getOrCreateCustomer keeps an existing profile', () async {
      final account = await authService.createAccount(
        email: 'customer4@example.com',
        password: 'password123',
      );

      final existing = AppUser(
        uid: account.uid,
        name: 'Preferred Name',
        email: 'customer4@example.com',
        phone: '0199999999',
        role: UserRole.customer,
      );
      await userService.createUser(existing);

      // A later Google sign-in proposes different details for the same uid.
      final proposed = AppUser(
        uid: account.uid,
        name: 'Google Name',
        email: 'customer4@example.com',
        phone: '',
        role: UserRole.customer,
      );
      final result = await userService.getOrCreateCustomer(proposed);

      expect(result.name, 'Preferred Name');
      expect(result.phone, '0199999999');
    });

    test('getUser returns null when there is no profile', () async {
      final loaded = await userService.getUser('does-not-exist');
      expect(loaded, isNull);
    });
  });
}
