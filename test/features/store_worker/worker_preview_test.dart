import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/mock_workers.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/worker_preview.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';

import '../../helpers/fake_auth_repository.dart';

final WorkerProfile _daniel = mockWorkerProfiles.firstWhere(
  (w) => w.name == 'Daniel Lee',
);
final WorkerProfile _amir = mockWorkerProfiles.firstWhere(
  (w) => w.name == 'Amir Hamzah',
);
final WorkerProfile _nadia = mockWorkerProfiles.firstWhere(
  (w) => w.name == 'Nadia Yusof',
);

/// The whole app on a phone-sized screen, signed out of Firebase.
Future<ProviderContainer> _pumpApp(
  WidgetTester tester, {
  bool previewEnabled = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      workerPreviewEnabledProvider.overrideWithValue(previewEnabled),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const GrocerlyApp()),
  );
  await tester.pumpAndSettle();
  return container;
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

/// Opens the selector and taps the worker called [name].
Future<void> _chooseWorker(
  WidgetTester tester,
  ProviderContainer container,
  String name,
) async {
  await _go(tester, container, AppRoutes.workerDevSelect);
  await _scrollTo(tester, find.text(name));
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

/// Scrolls the page's list until [finder] is on screen. ListView only
/// builds rows near the screen, so rows further down do not exist yet.
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
      bool enabled = true,
    }) {
      return workerRouteRedirect(
        location: location,
        previewEnabled: enabled,
        worker: worker,
        isSignedIn: false,
      );
    }

    test('ignores pages that are not worker pages', () {
      expect(redirect(AppRoutes.adminDashboard, worker: _daniel), isNull);
      expect(redirect(AppRoutes.login), isNull);
    });

    test('sends everyone away when the preview is off', () {
      expect(
        redirect(AppRoutes.workerDevSelect, enabled: false),
        AppRoutes.onboarding,
      );
      expect(
        redirect(AppRoutes.workerPacking, worker: _daniel, enabled: false),
        AppRoutes.onboarding,
      );
    });

    test('always allows the selector when the preview is on', () {
      expect(redirect(AppRoutes.workerDevSelect), isNull);
    });

    test('needs an active worker for every other worker page', () {
      expect(redirect(AppRoutes.workerPacking), AppRoutes.workerDevSelect);
      expect(
        redirect(AppRoutes.workerAccount, worker: _nadia),
        AppRoutes.workerDevSelect,
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
    test('starts empty, selects an active worker, and exits', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final session = container.read(workerSessionProvider.notifier);

      expect(container.read(workerSessionProvider), isNull);
      expect(session.select(_daniel), isNull);
      expect(container.read(workerSessionProvider), _daniel);

      session.exit();
      expect(container.read(workerSessionProvider), isNull);
    });

    test('rejects an inactive worker', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final error = container
          .read(workerSessionProvider.notifier)
          .select(_nadia);

      expect(error, contains('deactivated'));
      expect(container.read(workerSessionProvider), isNull);
    });

    test('rejects everyone when the preview is off', () {
      final container = ProviderContainer(
        overrides: [workerPreviewEnabledProvider.overrideWithValue(false)],
      );
      addTearDown(container.dispose);

      final error = container
          .read(workerSessionProvider.notifier)
          .select(_daniel);

      expect(error, isNotNull);
      expect(container.read(workerSessionProvider), isNull);
    });
  });

  group('Sign-in Store Worker button', () {
    testWidgets('opens the mock worker list without email or password', (
      tester,
    ) async {
      final container = await _pumpApp(tester);
      await _go(tester, container, AppRoutes.login);

      expect(find.text('Packing and delivery'), findsOneWidget);
      await tester.ensureVisible(find.text('Store Worker'));
      await tester.tap(find.text('Store Worker'));
      await tester.pumpAndSettle();

      // No validation errors; the selector opened on top of sign-in.
      expect(find.text('Store Worker preview'), findsOneWidget);
      expect(find.text('Daniel Lee'), findsOneWidget);
    });

    testWidgets('signs in normally when the preview is off', (tester) async {
      final container = await _pumpApp(tester, previewEnabled: false);
      await _go(tester, container, AppRoutes.login);

      expect(find.text('Packing and delivery'), findsOneWidget);
      await tester.ensureVisible(find.text('Store Worker'));
      await tester.tap(find.text('Store Worker'));
      await tester.pumpAndSettle();

      // The empty form is checked instead of opening the mock list.
      expect(find.text('Store Worker preview'), findsNothing);
      expect(_location(container), AppRoutes.login);
    });
  });

  group('Store Worker preview app', () {
    testWidgets('Packing Staff gets three tabs and their branch', (
      tester,
    ) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Daniel Lee');

      expect(_location(container), AppRoutes.workerPacking);
      expect(find.byType(NavigationDestination), findsNWidgets(3));
      expect(
        find.widgetWithText(NavigationDestination, 'Ready for Pickup'),
        findsOneWidget,
      );
      expect(find.text('Grocerly · SS15 Subang'), findsOneWidget);
    });

    testWidgets('Delivery Driver gets two tabs', (tester) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Tan Wei Jie');

      expect(_location(container), AppRoutes.workerDelivery);
      expect(find.byType(NavigationDestination), findsNWidgets(2));
      // Drivers work across branches, so the header shows their coverage
      // rather than a single home branch.
      expect(find.text('Grocerly · Cross-branch delivery'), findsOneWidget);
    });

    testWidgets('an inactive worker is rejected with a reason', (tester) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Nadia Yusof');

      expect(find.text('Cannot start preview'), findsOneWidget);
      expect(find.textContaining('deactivated'), findsOneWidget);
      expect(container.read(workerSessionProvider), isNull);
      expect(_location(container), AppRoutes.workerDevSelect);
    });

    testWidgets('a driver opening a packing page is sent to deliveries', (
      tester,
    ) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Amir Hamzah');

      await _go(tester, container, AppRoutes.workerPacking);
      expect(_location(container), AppRoutes.workerDelivery);

      await _go(tester, container, AppRoutes.workerPickup);
      expect(_location(container), AppRoutes.workerDelivery);
    });

    testWidgets('a packer opening deliveries is sent to My Tasks', (
      tester,
    ) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Hakim Roslan');

      await _go(tester, container, AppRoutes.workerDelivery);
      expect(_location(container), AppRoutes.workerPacking);
    });

    testWidgets('switching worker changes the tabs straight away', (
      tester,
    ) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Daniel Lee');
      expect(find.byType(NavigationDestination), findsNWidgets(3));

      await _chooseWorker(tester, container, 'Amir Hamzah');
      expect(_location(container), AppRoutes.workerDelivery);
      expect(find.byType(NavigationDestination), findsNWidgets(2));
    });

    testWidgets('worker pages need a chosen worker', (tester) async {
      final container = await _pumpApp(tester);

      await _go(tester, container, AppRoutes.workerAccount);
      expect(_location(container), AppRoutes.workerDevSelect);
    });

    testWidgets('a preview session does not open admin pages', (tester) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Daniel Lee');

      await _go(tester, container, AppRoutes.adminDashboard);
      expect(_location(container), AppRoutes.onboarding);
    });

    testWidgets('the selector is closed when the preview is off', (
      tester,
    ) async {
      final container = await _pumpApp(tester, previewEnabled: false);

      await _go(tester, container, AppRoutes.workerDevSelect);
      expect(_location(container), AppRoutes.onboarding);
    });

    testWidgets('Account shows the worker and Exit preview leaves', (
      tester,
    ) async {
      final container = await _pumpApp(tester);
      await _chooseWorker(tester, container, 'Daniel Lee');

      await tester.tap(find.widgetWithText(NavigationDestination, 'Account'));
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.workerAccount);
      expect(find.text('Daniel Lee'), findsOneWidget);
      expect(find.text('daniel.lee@grocerly.my'), findsOneWidget);

      await _scrollTo(tester, find.text('Exit preview'));
      await tester.tap(find.text('Exit preview'));
      await tester.pumpAndSettle();

      expect(_location(container), AppRoutes.login);
      expect(container.read(workerSessionProvider), isNull);
    });
  });
}
