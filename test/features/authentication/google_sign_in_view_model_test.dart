// Reference pattern for unit-testing a Riverpod view model with mocktail.
//
// mocktail stubs collaborators (here AuthRepository) and verifies how the
// view model drives them, with no Firebase, emulator or widgets. Copy this
// shape for other view-model tests: a Mock class, a ProviderContainer with
// the dependency overridden, then arrange/act/assert.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/google_sign_in_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _customer = AppUser(
  uid: 'uid-1',
  name: 'May',
  email: 'may@example.com',
  phone: '',
  role: UserRole.customer,
);

void main() {
  late MockAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() => container.dispose());

  GoogleSignInViewModel viewModel() =>
      container.read(googleSignInViewModelProvider.notifier);

  test('signIn returns true and calls the repository once', () async {
    when(
      () => repository.signInWithGoogle(),
    ).thenAnswer((_) async => _customer);

    final result = await viewModel().signIn();

    expect(result, isTrue);
    verify(() => repository.signInWithGoogle()).called(1);
  });

  test('signIn returns false when the user cancels (null)', () async {
    when(() => repository.signInWithGoogle()).thenAnswer((_) async => null);

    final result = await viewModel().signIn();

    expect(result, isFalse);
  });

  test('signIn surfaces an AuthException as an error state', () async {
    when(
      () => repository.signInWithGoogle(),
    ).thenThrow(const AuthException('Google sign-in is not enabled yet.'));

    final result = await viewModel().signIn();

    expect(result, isFalse);
    expect(
      container.read(googleSignInViewModelProvider),
      isA<AsyncError<void>>(),
    );
  });
}
