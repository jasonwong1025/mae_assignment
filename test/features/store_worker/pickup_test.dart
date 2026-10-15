import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/view_models/pickup_handover_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';

import '../../helpers/worker_test_app.dart';

/// Ticks both manual checks on the handover screen of [number]/[customer].
Future<void> _verify(WidgetTester tester, int number, String customer) async {
  await tester.tap(find.text('Customer gave order number #$number'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Name matches $customer'));
  await tester.pumpAndSettle();
}

void main() {
  group('Ready for Pickup list', () {
    testWidgets('shows every ready pickup in my branch, oldest first', (
      tester,
    ) async {
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickup,
      );

      expect(find.text('2 orders waiting · oldest first'), findsOneWidget);
      // 2305 was packed by Daniel; 2306 by Hakim and is still listed.
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('Kelvin Lim'), findsOneWidget);
      expect(find.textContaining('Packed by you'), findsOneWidget);
      expect(find.textContaining('Packed by Hakim Roslan'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('#2305')).dy,
        lessThan(tester.getTopLeft(find.text('#2306')).dy),
      );

      // Not listed: a ready delivery and another branch's pickup.
      expect(find.text('#2308'), findsNothing);
      expect(find.text('#1183'), findsNothing);
    });

    testWidgets('another branch sees only its own pickups', (tester) async {
      await pumpWorkerApp(
        tester,
        'Hafiz Zainal',
        location: AppRoutes.workerPickup,
      );

      expect(find.text('#1183'), findsOneWidget);
      expect(find.text('#2305'), findsNothing);
      expect(find.text('#2306'), findsNothing);
    });

    testWidgets('search filters by order number or customer name', (
      tester,
    ) async {
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickup,
      );

      await tester.enterText(find.byType(TextField), '#2306');
      await tester.pumpAndSettle();
      expect(find.text('Kelvin Lim'), findsOneWidget);
      expect(find.text('Siti Aminah'), findsNothing);

      await tester.enterText(find.byType(TextField), 'siti');
      await tester.pumpAndSettle();
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('Kelvin Lim'), findsNothing);

      await tester.enterText(find.byType(TextField), 'nobody');
      await tester.pumpAndSettle();
      expect(find.text('No matching orders'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('Kelvin Lim'), findsOneWidget);
    });

    testWidgets('shows the empty state when nothing is waiting', (
      tester,
    ) async {
      final (_, repository) = await pumpWorkerApp(
        tester,
        'Hafiz Zainal',
        location: AppRoutes.workerPickup,
      );

      await repository.completePickup(
        mockWorker('Hafiz Zainal'),
        'ord-1183',
        method: VerificationMethod.manual,
      );
      await tester.pumpAndSettle();

      expect(find.text('No orders waiting for pickup'), findsOneWidget);
    });

    testWidgets('"Handed over by you today" opens to list my handovers', (
      tester,
    ) async {
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickup,
      );

      // Collapsed at first: the seed handover #2307 is not shown.
      expect(find.text('Handed over by you today (1)'), findsOneWidget);
      expect(find.text('#2307 · Raj Kumar'), findsNothing);

      await scrollIntoView(tester, find.text('Handed over by you today (1)'));
      await tester.tap(find.text('Handed over by you today (1)'));
      await tester.pumpAndSettle();
      expect(find.text('#2307 · Raj Kumar'), findsOneWidget);
    });
  });

  group('Pickup handover', () {
    testWidgets('verify, confirm, and hand over an order someone else '
        'packed', (tester) async {
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickup,
      );

      await tester.tap(find.text('Kelvin Lim'));
      await tester.pumpAndSettle();
      expect(find.text('Pickup #2306'), findsOneWidget);
      expect(find.textContaining('Packed by Hakim Roslan'), findsOneWidget);

      // Items are listed (read-only) below the checks.
      await scrollIntoView(tester, find.text('Cream crackers'));
      expect(find.text('Cream crackers'), findsOneWidget);
      await scrollIntoView(
        tester,
        find.text('Customer gave order number #2306'),
      );

      // Complete pickup needs both checks.
      expect(buttonWithText(tester, 'Complete pickup').enabled, isFalse);
      await tester.tap(find.text('Customer gave order number #2306'));
      await tester.pumpAndSettle();
      expect(buttonWithText(tester, 'Complete pickup').enabled, isFalse);
      await tester.tap(find.text('Name matches Kelvin Lim'));
      await tester.pumpAndSettle();
      expect(find.text('Verified by manual check'), findsOneWidget);
      expect(buttonWithText(tester, 'Complete pickup').enabled, isTrue);

      await tester.tap(find.text('Complete pickup'));
      await tester.pumpAndSettle();
      expect(find.text('Hand over order #2306?'), findsOneWidget);
      await tester.tap(find.text('Hand over'));
      await tester.pumpAndSettle();

      // Back on the list: success message, 2306 gone, now in my handovers.
      expect(
        find.text('Order #2306 handed over to Kelvin Lim.'),
        findsOneWidget,
      );
      expect(find.text('Kelvin Lim'), findsNothing);
      expect(find.text('Handed over by you today (2)'), findsOneWidget);

      await scrollIntoView(tester, find.text('Handed over by you today (2)'));
      await tester.tap(find.text('Handed over by you today (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('#2306 · Kelvin Lim'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Handed over by you at'), findsOneWidget);
      expect(find.textContaining('(manual check)'), findsOneWidget);
    });

    testWidgets('cancelling the confirmation keeps the order waiting', (
      tester,
    ) async {
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickupOrder('ord-2305'),
      );

      await _verify(tester, 2305, 'Siti Aminah');
      await tester.tap(find.text('Complete pickup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Pickup #2305'), findsOneWidget);
      expect(buttonWithText(tester, 'Complete pickup').enabled, isTrue);
    });

    testWidgets('if another packer hands it over first, the screen says so', (
      tester,
    ) async {
      // Daniel did not pack 2306, so once Hakim hands it over it leaves
      // Daniel's scope entirely.
      final (_, repository) = await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickupOrder('ord-2306'),
      );
      await _verify(tester, 2306, 'Kelvin Lim');

      await repository.completePickup(
        mockWorker('Hakim Roslan'),
        'ord-2306',
        method: VerificationMethod.manual,
      );
      await tester.pumpAndSettle();

      expect(find.text('Order not available'), findsOneWidget);
      expect(find.text('Complete pickup'), findsNothing);
    });

    testWidgets('the packer who packed it sees who handed it over', (
      tester,
    ) async {
      final (_, repository) = await pumpWorkerApp(
        tester,
        'Hakim Roslan',
        location: AppRoutes.workerPickupOrder('ord-2306'),
      );

      await repository.completePickup(
        mockWorker('Daniel Lee'),
        'ord-2306',
        method: VerificationMethod.manual,
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Handed over by Daniel Lee at'),
        findsOneWidget,
      );
      expect(find.text('Complete pickup'), findsNothing);
      expect(find.text('Back to Ready for Pickup'), findsOneWidget);
    });

    testWidgets('a pickup still being packed cannot be handed over', (
      tester,
    ) async {
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickupOrder('ord-2302'),
      );

      expect(
        find.text(
          'This order is not ready for pickup yet. It is still being packed.',
        ),
        findsOneWidget,
      );
      expect(find.text('Complete pickup'), findsNothing);
    });

    testWidgets('another branch\'s pickup is not available', (tester) async {
      await pumpWorkerApp(
        tester,
        'Hafiz Zainal',
        location: AppRoutes.workerPickupOrder('ord-2306'),
      );

      expect(find.text('Order not available'), findsOneWidget);
    });

    testWidgets('a delivery order cannot be handed over as a pickup', (
      tester,
    ) async {
      // Daniel packed delivery 2309, so he may open it, but not hand it
      // over at the counter.
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickupOrder('ord-2309'),
      );

      expect(find.text('Order not available'), findsOneWidget);
      expect(find.textContaining('This is a delivery order'), findsOneWidget);
    });

    testWidgets('drivers cannot open pickup screens', (tester) async {
      final (container, _) = await pumpWorkerApp(
        tester,
        'Amir Hamzah',
        location: AppRoutes.workerPickup,
      );
      expect(routerLocation(container), AppRoutes.workerDelivery);

      container.read(appRouterProvider).go(
        AppRoutes.workerPickupOrder('ord-2306'),
      );
      await tester.pumpAndSettle();
      expect(routerLocation(container), AppRoutes.workerDelivery);
    });
  });

  group('PickupHandoverViewModel', () {
    test('a second completion returns who already did it', () async {
      final repository = WorkerOrdersRepository();
      addTearDown(repository.dispose);
      final container = ProviderContainer(
        overrides: [workerOrdersRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      container.read(workerSessionProvider.notifier).select(
        mockWorker('Hakim Roslan'),
      );

      await repository.completePickup(
        mockWorker('Daniel Lee'),
        'ord-2306',
        method: VerificationMethod.manual,
      );

      final provider = pickupHandoverViewModelProvider('ord-2306');
      container.listen(provider, (previous, next) {});
      final error = await container
          .read(provider.notifier)
          .completePickup(method: VerificationMethod.manual);

      expect(error, 'This order has already been handed over by Daniel Lee.');
    });
  });
}
