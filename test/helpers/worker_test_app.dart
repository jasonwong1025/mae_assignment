import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/repositories/driver_tracking_repository.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/view_models/driver_tracking_view_model.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import 'fake_auth_repository.dart';
import 'fake_location_service.dart';
import 'worker_profiles.dart';
import 'worker_test_store.dart';

/// The whole app on a phone-sized screen, signed in as the test worker
/// [workerName]
/// opened at [location]. Uses its own in-memory order database (zero
/// delay), returned so tests can make changes "from another device".
///
/// [repository] replaces the default store (e.g. one with different
/// sample orders); [store] uses a store the test made, so it can change or
/// read the database; [gps] is the phone's fake GPS; [overrides] adds more
/// provider overrides (e.g. a fake launcher).
Future<(ProviderContainer, WorkerOrdersRepository)> pumpWorkerApp(
  WidgetTester tester,
  String workerName, {
  required String location,
  WorkerOrdersRepository? repository,
  WorkerTestStore? store,
  FakeLocationService? gps,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final usedStore =
      store ?? (repository == null ? await WorkerTestStore.create() : null);
  final orders = repository ?? usedStore!.repository;
  // Shares the driver's position into the same in-memory database the
  // orders live in.
  final phoneGps = gps ?? FakeLocationService();
  final tracking = DriverTrackingRepository(
    phoneGps,
    usedStore?.service ?? OrderService(FakeFirebaseFirestore()),
  );

  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository()..signedIn = true,
      ),
      workerOrdersRepositoryProvider.overrideWithValue(orders),
      // No real GPS in tests; a test that cares passes its own.
      driverTrackingRepositoryProvider.overrideWithValue(tracking),
      trackingTimerProvider.overrideWithValue((every, tick) => null),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  container.read(workerSessionProvider.notifier).open(testWorker(workerName));

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const GrocerlyApp()),
  );
  await tester.pumpAndSettle();
  container.read(appRouterProvider).go(location);
  await tester.pumpAndSettle();
  return (container, orders);
}

/// The base location the router is at. Pages opened with push() sit on
/// top of it and are not included.
String routerLocation(ProviderContainer container) {
  final router = container.read(appRouterProvider);
  return router.routerDelegate.currentConfiguration.uri.path;
}

/// The button (filled, outlined or text) that shows [text].
ButtonStyleButton buttonWithText(WidgetTester tester, String text) {
  return tester.widget<ButtonStyleButton>(
    find
        .ancestor(
          of: find.text(text),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        )
        .first,
  );
}

/// Scrolls the screen's main list until [finder] is built, then brings it
/// fully into view so a tap cannot land on the bottom navigation.
Future<void> scrollIntoView(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}
