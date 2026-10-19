import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/orders/data/services/delivery_proof_service.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/data/repositories/worker_session_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/worker_profiles.dart';
import '../../helpers/worker_test_store.dart';

final WorkerProfile _daniel = testWorker('Daniel Lee');
final WorkerProfile _amir = testWorker('Amir Hamzah');
final WorkerProfile _nadia = testWorker('Nadia Yusof');

/// Stand-in for the profile lookup, so tests need no Firestore.
class FakeWorkerSessionRepository extends Fake
    implements WorkerSessionRepository {
  FakeWorkerSessionRepository(this.profile);

  WorkerProfile? profile;
  WorkerSessionException? error;

  @override
  Future<WorkerProfile> loadCurrent() async {
    if (error != null) throw error!;
    return profile!;
  }
}

AppUser _userFor(WorkerProfile worker) {
  return AppUser(
    uid: worker.id,
    name: worker.name,
    email: worker.email,
    phone: worker.phone,
    role: UserRole.storeWorker,
  );
}

/// The whole app on a phone-sized screen. [signedInAs] is a worker who is
/// already signed in when the app opens (null: signed out).
Future<(ProviderContainer, FakeAuthRepository)> _pumpApp(
  WidgetTester tester, {
  WorkerProfile? signedInAs,
  WorkerProfile? profileToLoad,
  WorkerSessionException? loadError,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final auth = FakeAuthRepository();
  final worker = signedInAs ?? profileToLoad;
  if (worker != null) auth.userToSignIn = _userFor(worker);
  if (signedInAs != null) auth.signedIn = true;

  final session = FakeWorkerSessionRepository(worker)..error = loadError;
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      workerSessionRepositoryProvider.overrideWithValue(session),
      // The worker screens read orders; an empty in-memory database is
      // enough here.
      firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
      deliveryProofServiceProvider.overrideWithValue(
        FakeDeliveryProofService(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const GrocerlyApp()),
  );
  await tester.pumpAndSettle();
  return (container, auth);
}

GoRouter _router(ProviderContainer container) {
  return container.read(appRouterProvider);
}

String _location(ProviderContainer container) {
  return _router(container).routerDelegate.currentConfiguration.uri.path;
}

Future<void> _go(
  WidgetTester tester,
  ProviderContainer container,
  String location,
) async {
  _router(container).go(location);
  await tester.pumpAndSettle();
}

/// Fills in the sign-in form and taps the Store Worker button.
Future<void> _signInAsWorker(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await _go(tester, container, AppRoutes.login);
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'worker@grocerly.my');
  await tester.enterText(fields.at(1), 'Worker123!');
  await tester.ensureVisible(find.text('Store Worker'));
  await tester.tap(find.text('Store Worker'));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
}

void main() {
  group('workerRouteRedirect', () {
    String? redirect(
      String location, {
      WorkerProfile? worker,
      bool isSignedIn = true,
    }) {
      return workerRouteRedirect(
        location: location,
        worker: worker,
        isSignedIn: isSignedIn,
      );
    }

    test('ignores pages that are not worker pages', () {
      expect(redirect(AppRoutes.adminDashboard, worker: _daniel), isNull);
      expect(redirect(AppRoutes.login, isSignedIn: false), isNull);
    });

    test('sends signed-out people to onboarding', () {
      expect(
        redirect(AppRoutes.workerPacking, worker: _daniel, isSignedIn: false),
        AppRoutes.onboarding,
      );
    });

    test('needs an active worker profile for every worker page', () {
      expect(redirect(AppRoutes.workerPacking), AppRoutes.onboarding);
      expect(
        redirect(AppRoutes.workerAccount, worker: _nadia),
        AppRoutes.onboarding,
      );
    });

    test('keeps each role to its own pages', () {
      expect(redirect(AppRoutes.workerPacking, worker: _daniel), isNull);
      expect(redirect(AppRoutes.workerPickup, worker: _daniel), isNull);
      expect(redirect(AppRoutes.workerAccount, worker: _daniel), isNull);
      expect(
        redirect(AppRoutes.workerDelivery, worker: _daniel),
        AppRoutes.workerPacking,
      );

      expect(redirect(AppRoutes.workerDelivery, worker: _amir), isNull);
      expect(redirect(AppRoutes.workerAccount, worker: _amir), isNull);
      expect(
        redirect(AppRoutes.workerPacking, worker: _amir),
        AppRoutes.workerDelivery,
      );
      expect(
        redirect(AppRoutes.workerPickup, worker: _amir),
        AppRoutes.workerDelivery,
      );
    });

    test('covers order pages inside a tab', () {
      expect(
        redirect(AppRoutes.workerPackingOrder('o1'), worker: _daniel),
        isNull,
      );
      expect(
        redirect(AppRoutes.workerDeliveryOrder('o1'), worker: _daniel),
        AppRoutes.workerPacking,
      );
      expect(
        redirect(AppRoutes.workerPickupOrder('o1'), worker: _amir),
        AppRoutes.workerDelivery,
      );
    });
  });

  group('WorkerSessionViewModel', () {
    ProviderContainer containerFor(FakeWorkerSessionRepository session) {
      final container = ProviderContainer(
        overrides: [workerSessionRepositoryProvider.overrideWithValue(session)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('starts empty, opens for an active worker, and exits', () {
      final container = containerFor(FakeWorkerSessionRepository(_daniel));
      final session = container.read(workerSessionProvider.notifier);

      expect(container.read(workerSessionProvider), isNull);
      expect(session.open(_daniel), isNull);
      expect(container.read(workerSessionProvider), _daniel);

      session.exit();
      expect(container.read(workerSessionProvider), isNull);
    });

    test('rejects an inactive worker', () {
      final container = containerFor(FakeWorkerSessionRepository(_nadia));

      final error = container.read(workerSessionProvider.notifier).open(_nadia);

      expect(error, contains('deactivated'));
      expect(container.read(workerSessionProvider), isNull);
    });

    test('rejects a packer who has no branch', () {
      final noBranch = WorkerProfile(
        id: _daniel.id,
        name: _daniel.name,
        email: _daniel.email,
        phone: _daniel.phone,
        role: _daniel.role,
        isActive: true,
      );
      final container = containerFor(FakeWorkerSessionRepository(noBranch));

      final error = container
          .read(workerSessionProvider.notifier)
          .open(noBranch);

      expect(error, contains('no branch'));
      expect(container.read(workerSessionProvider), isNull);
    });

    test("start loads the signed-in worker's profile", () async {
      final container = containerFor(FakeWorkerSessionRepository(_amir));

      final error = await container
          .read(workerSessionProvider.notifier)
          .start();

      expect(error, isNull);
      expect(container.read(workerSessionProvider), _amir);
    });

    test(
      'start returns the reason when the profile cannot be loaded',
      () async {
        final session = FakeWorkerSessionRepository(null)
          ..error = const WorkerSessionException(
            'Your worker profile is missing.',
          );
        final container = containerFor(session);

        final error = await container
            .read(workerSessionProvider.notifier)
            .start();

        expect(error, 'Your worker profile is missing.');
        expect(container.read(workerSessionProvider), isNull);
      },
    );

    test('the session ends when the Firebase session ends', () async {
      final uids = StreamController<String?>();
      addTearDown(uids.close);
      final auth = FakeAuthRepository()..uidStream = uids.stream;
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          workerSessionRepositoryProvider.overrideWithValue(
            FakeWorkerSessionRepository(_daniel),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(authUidProvider, (previous, next) {});

      container.read(workerSessionProvider.notifier).open(_daniel);
      uids.add(_daniel.id);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(workerSessionProvider), _daniel);

      uids.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(workerSessionProvider), isNull);
    });
  });

  group('Sign in as a Store Worker', () {
    testWidgets('a packer lands on My Tasks with their branch', (tester) async {
      final (container, _) = await _pumpApp(tester, profileToLoad: _daniel);
      await _signInAsWorker(tester, container);

      expect(_location(container), AppRoutes.workerPacking);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(
        find.widgetWithText(NavigationDestination, 'Ready for Pickup'),
        findsOneWidget,
      );
      expect(find.text('Grocerly · SS15 Subang'), findsOneWidget);
    });

    testWidgets('a driver lands on My Deliveries with two tabs', (
      tester,
    ) async {
      final (container, _) = await _pumpApp(tester, profileToLoad: _amir);
      await _signInAsWorker(tester, container);

      expect(_location(container), AppRoutes.workerDelivery);
      expect(find.byType(NavigationDestination), findsNWidgets(2));
      // Drivers work across branches, so the header shows their coverage
      // rather than a single home branch.
      expect(find.text('Grocerly · Cross-branch delivery'), findsOneWidget);
    });

    testWidgets('an unusable profile signs the worker out with a reason', (
      tester,
    ) async {
      final (container, auth) = await _pumpApp(tester, profileToLoad: _nadia);
      await _signInAsWorker(tester, container);

      expect(find.textContaining('deactivated'), findsOneWidget);
      expect(auth.signedIn, isFalse);
      expect(container.read(workerSessionProvider), isNull);
      expect(_location(container), AppRoutes.login);
    });

    testWidgets('a missing profile signs the worker out with a reason', (
      tester,
    ) async {
      final (container, auth) = await _pumpApp(
        tester,
        profileToLoad: _daniel,
        loadError: const WorkerSessionException(
          'Your worker profile is missing.',
        ),
      );
      await _signInAsWorker(tester, container);

      expect(find.text('Your worker profile is missing.'), findsOneWidget);
      expect(auth.signedIn, isFalse);
      expect(_location(container), AppRoutes.login);
    });

    testWidgets('reopening the app with a live session restores the worker', (
      tester,
    ) async {
      final (container, _) = await _pumpApp(tester, signedInAs: _amir);

      expect(_location(container), AppRoutes.workerDelivery);
      expect(container.read(workerSessionProvider), _amir);
    });
  });

  group('Store Worker app', () {
    testWidgets('a driver opening a packing page is sent to deliveries', (
      tester,
    ) async {
      final (container, _) = await _pumpApp(tester, signedInAs: _amir);

      await _go(tester, container, AppRoutes.workerPacking);
      expect(_location(container), AppRoutes.workerDelivery);

      await _go(tester, container, AppRoutes.workerPickup);
      expect(_location(container), AppRoutes.workerDelivery);
    });

    testWidgets('a packer opening deliveries is sent to My Tasks', (
      tester,
    ) async {
      final (container, _) = await _pumpApp(tester, signedInAs: _daniel);

      await _go(tester, container, AppRoutes.workerDelivery);
      expect(_location(container), AppRoutes.workerPacking);
    });

    testWidgets('worker pages need a signed-in worker', (tester) async {
      final (container, _) = await _pumpApp(tester);

      await _go(tester, container, AppRoutes.workerAccount);
      expect(_location(container), AppRoutes.onboarding);
    });

    testWidgets('a worker session does not open admin pages', (tester) async {
      final (container, _) = await _pumpApp(tester, signedInAs: _daniel);

      await _go(tester, container, AppRoutes.adminDashboard);
      expect(_location(container), isNot(AppRoutes.adminDashboard));
    });

    testWidgets('Account shows the worker and Sign out leaves', (tester) async {
      final (container, auth) = await _pumpApp(tester, signedInAs: _daniel);

      await tester.tap(find.widgetWithText(NavigationDestination, 'Account'));
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.workerAccount);
      expect(find.text('Daniel Lee'), findsOneWidget);
      expect(find.text('daniel.lee@grocerly.my'), findsOneWidget);

      await _scrollTo(tester, find.text('Sign out'));
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.onboarding);
      expect(auth.signedIn, isFalse);
      expect(container.read(workerSessionProvider), isNull);
    });
  });
}
