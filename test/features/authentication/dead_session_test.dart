import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/data/services/auth_service.dart';
import 'package:mae_assignment/features/authentication/data/services/google_sign_in_service.dart';
import 'package:mae_assignment/features/authentication/data/services/user_service.dart';

import '../../helpers/fake_auth_repository.dart';

class _AuthService extends Fake implements AuthService {
  int signOutCalls = 0;
  bool signedIn = true;
  Object? reloadFailure;

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<void> reloadCurrentUser() async {
    // Simulates the backend's answer to a refresh of the saved session.
    // ignore: only_throw_errors
    if (reloadFailure != null) throw reloadFailure!;
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}

class _GoogleService extends Fake implements GoogleSignInService {
  @override
  Future<void> signOut() async {}
}

void main() {
  late _AuthService auth;
  late AuthRepository repository;

  setUp(() {
    auth = _AuthService();
    repository = AuthRepository(auth, _NoUserService(), _GoogleService());
  });

  group('endDeadSession', () {
    for (final code in const [
      'user-token-expired',
      'invalid-user-token',
      'user-not-found',
      'user-disabled',
    ]) {
      test('signs out when the backend answers $code', () async {
        auth.reloadFailure = FirebaseAuthException(code: code);

        await repository.endDeadSession();

        expect(auth.signOutCalls, 1);
      });
    }

    test('keeps a valid session', () async {
      await repository.endDeadSession();

      expect(auth.signOutCalls, 0);
    });

    test('keeps the user signed in when offline', () async {
      auth.reloadFailure = FirebaseAuthException(
        code: 'network-request-failed',
      );

      await repository.endDeadSession();

      expect(auth.signOutCalls, 0);
    });

    test('keeps the user signed in on an unexpected error', () async {
      auth.reloadFailure = StateError('boom');

      await repository.endDeadSession();

      expect(auth.signOutCalls, 0);
    });

    test('does nothing when nobody is signed in', () async {
      auth
        ..signedIn = false
        ..reloadFailure = FirebaseAuthException(code: 'user-token-expired');

      await repository.endDeadSession();

      expect(auth.signOutCalls, 0);
    });
  });

  testWidgets('being signed out mid-session returns to onboarding', (
    tester,
  ) async {
    final uids = StreamController<String?>.broadcast();
    addTearDown(uids.close);
    final fakeAuth = FakeAuthRepository()
      ..signedIn = true
      ..uidStream = uids.stream;
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GrocerlyApp(),
      ),
    );
    uids.add('u1');
    await tester.pumpAndSettle();
    // Signed in with no profile to route by: the placeholder home.
    expect(find.text('Hi, there'), findsOneWidget);

    // The backend ends the session without the user doing anything.
    fakeAuth.signedIn = false;
    uids.add(null);
    await tester.pumpAndSettle();

    expect(find.text('Your neighbourhood grocer, online'), findsOneWidget);
  });
}

class _NoUserService extends Fake implements UserService {}
