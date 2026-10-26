import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:mae_assignment/features/authentication/presentation/views/login_view.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/data/repositories/worker_session_repository.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/worker_profiles.dart';

class _FakeWorkerSession extends Fake implements WorkerSessionRepository {
  WorkerProfile? profile;

  @override
  Future<WorkerProfile> loadCurrent() async => profile!;
}

AppUser _user(UserRole role) {
  return AppUser(
    uid: 'u1',
    name: 'Someone',
    email: 'someone@example.com',
    phone: '0123456789',
    role: role,
  );
}

/// One login for everyone: there are no role buttons, and the account's
/// role decides where it lands.
void main() {
  late FakeAuthRepository repository;
  late _FakeWorkerSession workers;

  setUp(() {
    repository = FakeAuthRepository();
    workers = _FakeWorkerSession();
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final daniel = testWorker('Daniel Lee');
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginView(),
        ),
        for (final (path, label) in [
          (AppRoutes.adminDashboard, 'ADMIN DASHBOARD'),
          (AppRoutes.customerCatalogue, 'CUSTOMER CATALOGUE'),
          (workerHomeFor(daniel), 'PACKER TASKS'),
          (AppRoutes.register, 'REGISTER'),
        ])
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(body: Text(label)),
          ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          workerSessionRepositoryProvider.overrideWithValue(workers),
          adminConsoleOnlyProvider.overrideWithValue(false),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillIn(WidgetTester tester) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'someone@example.com');
    await tester.enterText(fields.at(1), 'password1');
  }

  Future<void> tapLogIn(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('shows one Log in button and no role choice', (tester) async {
    await pump(tester);

    expect(find.text('Log in to continue'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
    expect(find.text('CONTINUE AS'), findsNothing);
    expect(find.text('Store Admin'), findsNothing);
    expect(find.text('Store Worker'), findsNothing);
    expect(find.text('Customer'), findsNothing);
    // The other ways in are still there.
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('New to Grocerly? Create an account'), findsOneWidget);
  });

  testWidgets('a customer lands on the catalogue', (tester) async {
    repository.userToSignIn = _user(UserRole.customer);
    await pump(tester);

    await fillIn(tester);
    await tapLogIn(tester);

    expect(find.text('CUSTOMER CATALOGUE'), findsOneWidget);
  });

  testWidgets('a Store Admin lands on the dashboard', (tester) async {
    repository.userToSignIn = _user(UserRole.storeAdmin);
    await pump(tester);

    await fillIn(tester);
    await tapLogIn(tester);

    expect(find.text('ADMIN DASHBOARD'), findsOneWidget);
  });

  testWidgets('a packer lands on their tasks', (tester) async {
    repository.userToSignIn = _user(UserRole.storeWorker);
    workers.profile = testWorker('Daniel Lee');
    await pump(tester);

    await fillIn(tester);
    await tapLogIn(tester);

    expect(find.text('PACKER TASKS'), findsOneWidget);
  });

  testWidgets('Enter on the password field logs in', (tester) async {
    repository.userToSignIn = _user(UserRole.customer);
    await pump(tester);

    await fillIn(tester);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('CUSTOMER CATALOGUE'), findsOneWidget);
  });

  testWidgets('an empty form is not sent', (tester) async {
    repository.userToSignIn = _user(UserRole.customer);
    await pump(tester);

    await tapLogIn(tester);

    expect(repository.signedIn, isFalse);
    expect(find.text('Log in to continue'), findsOneWidget);
  });

  testWidgets('a wrong password shows why and stays on the page', (
    tester,
  ) async {
    await pump(tester);

    await fillIn(tester);
    await tapLogIn(tester);

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Log in to continue'), findsOneWidget);
  });
}
