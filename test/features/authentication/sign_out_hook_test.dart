import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/data/services/auth_service.dart';
import 'package:mae_assignment/features/authentication/data/services/google_sign_in_service.dart';
import 'package:mae_assignment/features/authentication/data/services/user_service.dart';

class _AuthService extends Fake implements AuthService {
  final events = <String>[];

  @override
  Future<void> signOut() async => events.add('firebase signed out');
}

class _GoogleService extends Fake implements GoogleSignInService {
  @override
  Future<void> signOut() async {}
}

class _UserService extends Fake implements UserService {}

/// Signing out first runs cleanup that needs the user to still be signed in
/// (such as removing this phone from push notifications).
void main() {
  late _AuthService auth;

  AuthRepository repositoryWith(Future<void> Function()? hook) {
    return AuthRepository(
      auth,
      _UserService(),
      _GoogleService(),
      beforeSignOut: hook,
    );
  }

  setUp(() => auth = _AuthService());

  test('the cleanup runs before the Firebase sign-out', () async {
    final repository = repositoryWith(() async => auth.events.add('cleanup'));

    await repository.signOut();

    expect(auth.events, ['cleanup', 'firebase signed out']);
  });

  test('a failing cleanup never keeps the user signed in', () async {
    final repository = repositoryWith(() async => throw Exception('offline'));

    await repository.signOut();

    expect(auth.events, ['firebase signed out']);
  });

  test('signing out works with no cleanup at all', () async {
    await repositoryWith(null).signOut();

    expect(auth.events, ['firebase signed out']);
  });
}
