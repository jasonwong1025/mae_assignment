import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/register_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/data/repositories/worker_session_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/worker_profiles.dart';

const _adminUser = AppUser(
  uid: 'uid-1',
  name: 'Jason',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

const _customerUser = AppUser(
  uid: 'uid-2',
  name: 'Aisha',
  email: 'aisha@example.com',
  phone: '0123456789',
  role: UserRole.customer,
);

AppUser _workerUser(WorkerProfile worker) {
  return AppUser(
    uid: worker.id,
    name: worker.name,
    email: worker.email,
    phone: worker.phone,
    role: UserRole.storeWorker,
  );
}

/// Stand-in for the worker profile lookup, so no Firestore is needed.
class _FakeWorkerSession extends Fake implements WorkerSessionRepository {
  WorkerProfile? profile;
  WorkerSessionException? error;
  int loads = 0;

  @override
  Future<WorkerProfile> loadCurrent() async {
    loads++;
    if (error case final failure?) throw failure;
    return profile!;
  }
}

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
    late _FakeWorkerSession workers;

    // One login for everyone: the account's role decides where it lands.
    setUp(() {
      workers = _FakeWorkerSession();
      container.dispose();
      container =
          ProviderContainer(
              overrides: [
                authRepositoryProvider.overrideWithValue(repository),
                workerSessionRepositoryProvider.overrideWithValue(workers),
                adminConsoleOnlyProvider.overrideWithValue(false),
              ],
            )
            // Keeps the autoDispose ViewModel alive for the whole test.
            ..listen(loginViewModelProvider, (_, _) {});
    });

    LoginViewModel viewModel() {
      return container.read(loginViewModelProvider.notifier);
    }

    Future<String?> logIn() {
      return viewModel().signIn(
        emailOrPhone: ' jason@example.com ',
        password: 'password1',
      );
    }

    test('a Store Admin lands on the dashboard', () async {
      repository.userToSignIn = _adminUser;

      expect(await logIn(), AppRoutes.adminDashboard);
      expect(repository.signedIn, isTrue);
      expect(container.read(loginViewModelProvider).hasError, isFalse);
    });

    test('a customer lands on the catalogue', () async {
      repository.userToSignIn = _customerUser;

      expect(await logIn(), AppRoutes.customerCatalogue);
      expect(repository.signedIn, isTrue);
    });

    test(
      'a packer starts their session and lands on their first tab',
      () async {
        final daniel = testWorker('Daniel Lee');
        repository.userToSignIn = _workerUser(daniel);
        workers.profile = daniel;

        expect(await logIn(), workerHomeFor(daniel));
        expect(container.read(workerSessionProvider), daniel);
      },
    );

    test('a driver lands on their own first tab', () async {
      final amir = testWorker('Amir Hamzah');
      repository.userToSignIn = _workerUser(amir);
      workers.profile = amir;

      final home = await logIn();

      expect(home, workerHomeFor(amir));
      expect(home, isNot(workerHomeFor(testWorker('Daniel Lee'))));
    });

    test('a worker who cannot start a session is signed out again', () async {
      final nadia = testWorker('Nadia Yusof');
      repository.userToSignIn = _workerUser(nadia);
      workers.profile = nadia;

      expect(await logIn(), isNull);
      expect(repository.signedIn, isFalse);
      expect(
        container.read(loginViewModelProvider).error.toString(),
        contains('deactivated'),
      );
      expect(container.read(workerSessionProvider), isNull);
    });

    test('a worker whose profile cannot be read is signed out again', () async {
      repository.userToSignIn = _workerUser(testWorker('Daniel Lee'));
      workers.error = const WorkerSessionException(
        'Could not load your profile.',
      );

      expect(await logIn(), isNull);
      expect(repository.signedIn, isFalse);
      expect(
        container.read(loginViewModelProvider).error,
        'Could not load your profile.',
      );
    });

    group('on the HQ web console', () {
      setUp(() {
        container.dispose();
        container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(repository),
            workerSessionRepositoryProvider.overrideWithValue(workers),
            adminConsoleOnlyProvider.overrideWithValue(true),
          ],
        )..listen(loginViewModelProvider, (_, _) {});
      });

      test('a Store Admin logs in', () async {
        repository.userToSignIn = _adminUser;

        expect(await logIn(), AppRoutes.adminDashboard);
        expect(repository.signedIn, isTrue);
      });

      test('a customer is refused and signed out again', () async {
        repository.userToSignIn = _customerUser;

        expect(await logIn(), isNull);
        expect(repository.signedIn, isFalse);
        expect(
          container.read(loginViewModelProvider).error,
          'The web console is for Store Admin. Please use the Grocerly app '
          'on your phone.',
        );
      });

      test('a Store Worker is refused before any session starts', () async {
        final daniel = testWorker('Daniel Lee');
        repository.userToSignIn = _workerUser(daniel);
        workers.profile = daniel;

        expect(await logIn(), isNull);
        expect(repository.signedIn, isFalse);
        expect(workers.loads, 0);
      });
    });

    test('asks for an email when a phone number is entered', () async {
      final result = await viewModel().signIn(
        emailOrPhone: '012-345 6789',
        password: 'password1',
      );

      expect(result, isNull);
      expect(
        container.read(loginViewModelProvider).error,
        'Please log in with your email for now.',
      );
    });

    test('shows the repository error message', () async {
      final result = await viewModel().signIn(
        emailOrPhone: 'jason@example.com',
        password: 'wrong',
      );

      expect(result, isNull);
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
}
