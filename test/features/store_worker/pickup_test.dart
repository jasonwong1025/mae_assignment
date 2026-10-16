import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/view_models/pickup_handover_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/ui/slide_to_confirm.dart';

import '../../helpers/worker_test_app.dart';

/// Far enough to reach the end of the slider on any phone width.
const _fullSlide = Offset(500, 0);

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

      expect(find.text('Waiting for pickup (2)'), findsOneWidget);
      // 2305 was packed by Daniel; 2306 by Hakim and is still listed.
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('Kelvin Lim'), findsOneWidget);
      expect(find.textContaining('Packed by you'), findsOneWidget);
      expect(find.textContaining('Packed by Hakim Roslan'), findsWidgets);
      expect(
        tester.getTopLeft(find.text('#2305')).dy,
        lessThan(tester.getTopLeft(find.text('#2306')).dy),
      );

      // A ready delivery is not a pickup: it is listed under Waiting for
      // drivers instead. Another branch's pickup is not listed at all.
      expect(find.text('Driver: Amir Hamzah'), findsOneWidget);
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

      // Only the icon shows until it is tapped.
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
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

      // Closing hides the field and shows every order again.
      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
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
  });

  group('Waiting for drivers', () {
    testWidgets('lists ready delivery bags until the driver verifies', (
      tester,
    ) async {
      final (_, repository) = await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickup,
      );

      // 2308 (Hakim packed it, Amir delivers) waits for its driver.
      await scrollIntoView(tester, find.text('Waiting for drivers (1)'));
      await scrollIntoView(tester, find.text('David Wong'));
      expect(find.text('#2308'), findsOneWidget);
      expect(find.text('Driver: Amir Hamzah'), findsOneWidget);

      // Once Amir verifies the bag, it is collected and leaves the list.
      await repository.verifyCollection(
        mockWorker('Amir Hamzah'),
        'ord-2308',
        method: VerificationMethod.manual,
        code: '2308',
      );
      await tester.pumpAndSettle();
      // The section hides when nothing is waiting.
      expect(find.textContaining('Waiting for drivers'), findsNothing);
      expect(find.text('David Wong'), findsNothing);
    });

    testWidgets('shows only my branch', (tester) async {
      await pumpWorkerApp(
        tester,
        'Hafiz Zainal',
        location: AppRoutes.workerPickup,
      );

      await scrollIntoView(tester, find.text('Waiting for drivers (1)'));
      await scrollIntoView(tester, find.text('Lim Kok Wai'));
      expect(find.text('#1184'), findsOneWidget);
      expect(find.text('David Wong'), findsNothing);
    });
  });

  group('Pickup handover', () {
    testWidgets('verify, confirm, and hand over an order someone else '
        'packed', (tester) async {
      final (container, _) = await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickup,
      );

      await tester.tap(find.text('Kelvin Lim'));
      await tester.pumpAndSettle();
      expect(find.text('Pickup #2306'), findsOneWidget);
      expect(find.textContaining('Packed by Hakim Roslan'), findsOneWidget);

      expect(find.textContaining('Pickup by'), findsOneWidget);

      // Items are listed read-only, without checkboxes; tapping one shows
      // its details.
      expect(find.byType(Checkbox), findsNothing);
      await scrollIntoView(tester, find.text('Potato chips'));
      await tester.tap(find.text('Potato chips'));
      await tester.pumpAndSettle();
      expect(find.text('Mister Potato'), findsWidgets);
      expect(find.text('Mark as packed'), findsNothing);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      // Slide all the way to hand over.
      await tester.drag(find.byKey(SlideToConfirm.handleKey), _fullSlide);
      await tester.pumpAndSettle();

      // Back on the list: success message, 2306 gone, now in my handovers.
      expect(
        find.text('Order #2306 handed over to Kelvin Lim.'),
        findsOneWidget,
      );
      expect(find.text('Waiting for pickup (1)'), findsOneWidget);
      expect(find.text('Kelvin Lim'), findsNothing);

      // The record shows who handed it over and how it was checked.
      container
          .read(appRouterProvider)
          .go(AppRoutes.workerPickupOrder('ord-2306'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Handed over by you at'), findsOneWidget);
      expect(find.textContaining('(manual check)'), findsOneWidget);
    });

    testWidgets('a short slide does not hand over', (tester) async {
      await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPickupOrder('ord-2305'),
      );

      await tester.drag(
        find.byKey(SlideToConfirm.handleKey),
        const Offset(60, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pickup #2305'), findsOneWidget);
      expect(find.text('Slide to hand over'), findsOneWidget);
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

      await repository.completePickup(
        mockWorker('Hakim Roslan'),
        'ord-2306',
        method: VerificationMethod.manual,
      );
      await tester.pumpAndSettle();

      expect(find.text('Order not available'), findsOneWidget);
      expect(find.text('Slide to hand over'), findsNothing);
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
      expect(find.text('Slide to hand over'), findsNothing);
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
      expect(find.text('Slide to hand over'), findsNothing);
    });

    testWidgets("another branch's pickup is not available", (tester) async {
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

      container
          .read(appRouterProvider)
          .go(AppRoutes.workerPickupOrder('ord-2306'));
      await tester.pumpAndSettle();
      expect(routerLocation(container), AppRoutes.workerDelivery);
    });
  });

  group('PickupHandoverViewModel', () {
    test('a second completion returns who already did it', () async {
      final repository = WorkerOrdersRepository();
      addTearDown(repository.dispose);
      final container = ProviderContainer(
        overrides: [
          workerOrdersRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(workerSessionProvider.notifier)
          .select(mockWorker('Hakim Roslan'));

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
