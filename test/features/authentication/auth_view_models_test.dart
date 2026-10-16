import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/google_sign_in_view_model.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/register_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';

const _adminUser = AppUser(
  uid: 'uid-1',
  name: 'Jason',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  group('LoginViewModel', () {
    // Keeps the autoDispose ViewModel alive for the whole test.
    setUp(() => container.listen(loginViewModelProvider, (_, _) {}));

    LoginViewModel viewModel() {
      return container.read(loginViewModelProvider.notifier);
    }

    test('signs in when the role matches', () async {
      repository.userToSignIn = _adminUser;

      final result = await viewModel().signIn(
        emailOrPhone: ' jason@example.com ',
        password: 'password1',
        role: UserRole.storeAdmin,
      );

      expect(result, isTrue);
      expect(repository.signedIn, isTrue);
      expect(container.read(loginViewModelProvider).hasError, isFalse);
    });

    test('signs out again when the role does not match', () async {
      repository.userToSignIn = _adminUser;

      final result = await viewModel().signIn(
        emailOrPhone: 'jason@example.com',
        password: 'password1',
        role: UserRole.customer,
      );

      expect(result, isFalse);
      expect(repository.signedIn, isFalse);
      expect(
        container.read(loginViewModelProvider).error,
        'This is a Store Admin account. Please continue as Store Admin.',
      );
    });

    test('asks for an email when a phone number is entered', () async {
      final result = await viewModel().signIn(
        emailOrPhone: '012-345 6789',
        password: 'password1',
        role: UserRole.customer,
      );

      expect(result, isFalse);
      expect(
        container.read(loginViewModelProvider).error,
        'Please sign in with your email for now.',
      );
    });

    test('shows the repository error message', () async {
      final result = await viewModel().signIn(
        emailOrPhone: 'jason@example.com',
        password: 'wrong',
        role: UserRole.customer,
      );

      expect(result, isFalse);
      expect(
        container.read(loginViewModelProvider).error,
        'Incorrect email or password.',
      );
    });
  });

  group('RegisterViewModel', () {
    setUp(() => container.listen(registerViewModelProvider, (_, _) {}));

    RegisterViewModel viewModel() {
      return container.read(registerViewModelProvider.notifier);
    }

    test('creates the account and saves the phone as digits', () async {
      final result = await viewModel().createAccount(
        name: 'Lim Wei Ming',
        email: 'lim@example.com',
        phone: '012-345 6789',
        password: 'password1',
      );

      expect(result, isTrue);
      expect(repository.lastSignUpPhone, '0123456789');
    });

    test('shows the repository error message', () async {
      repository.errorToThrow = const AuthException(
        'An account with this email already exists.',
      );

      final result = await viewModel().createAccount(
        name: 'Lim Wei Ming',
        email: 'lim@example.com',
        phone: '0123456789',
        password: 'password1',
      );

      expect(result, isFalse);
      expect(
        container.read(registerViewModelProvider).error,
        'An account with this email already exists.',
      );
    });
  });

  group('GoogleSignInViewModel', () {
    setUp(() => container.listen(googleSignInViewModelProvider, (_, _) {}));

    test('signs in a customer', () async {
      repository.googleUserToSignIn = const AppUser(
        uid: 'customer-1',
        name: 'May',
        email: 'may@example.com',
        phone: '',
        role: UserRole.customer,
      );

      final result = await container
          .read(googleSignInViewModelProvider.notifier)
          .signIn();

      expect(result, isTrue);
      expect(repository.googleSignInCalls, 1);
      expect(container.read(googleSignInViewModelProvider).hasError, isFalse);
    });

    test('closing the Google chooser does not show an error', () async {
      repository.cancelGoogleSignIn = true;

      final result = await container
          .read(googleSignInViewModelProvider.notifier)
          .signIn();

      expect(result, isFalse);
      expect(container.read(googleSignInViewModelProvider).hasError, isFalse);
    });

    test('shows a safe repository error', () async {
      repository.errorToThrow = const AuthException('Google sign-in failed.');

      final result = await container
          .read(googleSignInViewModelProvider.notifier)
          .signIn();

      expect(result, isFalse);
      expect(
        container.read(googleSignInViewModelProvider).error,
        'Google sign-in failed.',
      );
    });
  });
}
