import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/services/auth_service.dart';

/// Device-free tests for AuthService using a Firebase Auth fake.
/// No device, emulator or network, so identical on every OS.
void main() {
  group('AuthService', () {
    test('starts signed out', () {
      final service = AuthService(MockFirebaseAuth());
      expect(service.isSignedIn, isFalse);
      expect(service.currentUser, isNull);
    });

    test('createAccount signs the new user in', () async {
      final service = AuthService(MockFirebaseAuth());

      final user = await service.createAccount(
        email: 'may@example.com',
        password: 'password123',
      );

      expect(user, isNotNull);
      expect(service.isSignedIn, isTrue);
    });

    test('signIn returns the account and marks the session signed in', () async {
      final service = AuthService(MockFirebaseAuth());

      final user = await service.signIn(
        email: 'may@example.com',
        password: 'password123',
      );

      expect(user, isNotNull);
      expect(service.isSignedIn, isTrue);
    });

    test('signOut clears the session', () async {
      final service = AuthService(MockFirebaseAuth(signedIn: true));
      expect(service.isSignedIn, isTrue);

      await service.signOut();

      expect(service.isSignedIn, isFalse);
    });
  });
}
