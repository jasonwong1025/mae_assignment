import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/mock_workers.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/worker_preview.dart';

import 'fake_auth_repository.dart';

/// A mock worker by name, e.g. "Daniel Lee".
WorkerProfile mockWorker(String name) {
  return mockWorkerProfiles.firstWhere((worker) => worker.name == name);
}

/// The whole app on a phone-sized screen, previewing as [workerName] and
/// opened at [location]. Uses its own zero-delay order store, returned so
/// tests can make changes "from another device".
///
/// [repository] replaces the default store (e.g. one with different
/// sample orders); [overrides] adds more provider overrides (e.g. a fake
/// launcher).
Future<(ProviderContainer, WorkerOrdersRepository)> pumpWorkerApp(
  WidgetTester tester,
  String workerName, {
  required String location,
  WorkerOrdersRepository? repository,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final orders = repository ?? WorkerOrdersRepository();
  addTearDown(orders.dispose);

  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      workerPreviewEnabledProvider.overrideWithValue(true),
      workerOrdersRepositoryProvider.overrideWithValue(orders),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  container.read(workerSessionProvider.notifier).select(mockWorker(workerName));

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
