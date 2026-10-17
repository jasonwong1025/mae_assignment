import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/orders/data/mock_worker_orders.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_item_tile.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/view_models/packing_order_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';

import '../../helpers/worker_test_app.dart';

/// The app on a phone as [workerName], opened at [location] (My Tasks by
/// default).
Future<(ProviderContainer, WorkerOrdersRepository)> _pumpAs(
  WidgetTester tester,
  String workerName, {
  String location = AppRoutes.workerPacking,
}) {
  return pumpWorkerApp(tester, workerName, location: location);
}

/// Scrolls to the product called [name] and taps it.
Future<void> _tapProduct(WidgetTester tester, String name) async {
  // Tapping the row opens the product's details; the checkbox ticks it.
  final checkbox = find.descendant(
    of: find.ancestor(
      of: find.text(name),
      matching: find.byType(PackingItemTile),
    ),
    matching: find.byType(Checkbox),
  );
  await scrollIntoView(tester, checkbox);
  await tester.tap(checkbox);
  await tester.pumpAndSettle();
}

/// Scrolls back up to the "To pack" heading and checks its packed count,
/// e.g. "3/5". (The heading leaves the built area when the list scrolls.)
Future<void> _expectCount(WidgetTester tester, String count) async {
  await tester.scrollUntilVisible(
    find.text(count),
    -200,
    scrollable: find.byType(Scrollable).first,
  );
  expect(find.text(count), findsOneWidget);
}

void main() {
  group('My Tasks', () {
    testWidgets('lists only my orders, with the next one first', (
      tester,
    ) async {
      await _pumpAs(tester, 'Daniel Lee');

      // Due soonest first: 2301 (25m), 2303 (40m), 2302 (55m).
      expect(find.textContaining('Deliver by'), findsWidgets);
      expect(
        tester.getTopLeft(find.text('#2301')).dy,
        lessThan(tester.getTopLeft(find.text('#2303')).dy),
      );
      await scrollIntoView(tester, find.text('#2302'));
      expect(find.text('2 of 5 packed'), findsOneWidget);
      expect(find.textContaining('Pickup by'), findsOneWidget);

      // Hakim's order and other branches' orders are not listed.
      expect(find.text('#2304'), findsNothing);
      expect(find.text('#1182'), findsNothing);
    });

    testWidgets('shows the empty state when nothing is left', (tester) async {
      final (_, repository) = await _pumpAs(tester, 'Hakim Roslan');
      expect(find.text('#2304'), findsOneWidget);

      final hakim = mockWorker('Hakim Roslan');
      await repository.startPacking(hakim, 'ord-2304');
      await repository.setItemPacked(hakim, 'ord-2304', 'L1', packed: true);
      await repository.setItemPacked(hakim, 'ord-2304', 'L2', packed: true);
      await repository.markReady(hakim, 'ord-2304');
      await tester.pumpAndSettle();

      expect(find.text('No packing tasks'), findsOneWidget);
    });

    testWidgets('Start packing starts the order and opens it', (tester) async {
      await _pumpAs(tester, 'Daniel Lee');

      // The last card's button sits just above the bottom navigation, so
      // bring it fully into view before tapping.
      await scrollIntoView(tester, find.text('Start'));
      await tester.ensureVisible(find.text('Start'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Opened (pushed) on top of My Tasks, already being packed.
      expect(find.text('Order #2301'), findsOneWidget);
      expect(find.text('Review & mark ready'), findsOneWidget);
      await _expectCount(tester, '0/3');
    });

    testWidgets('tapping an order opens its packing screen', (tester) async {
      await _pumpAs(tester, 'Daniel Lee');

      await scrollIntoView(tester, find.text('Wong Kar Yee'));
      await tester.tap(find.text('Wong Kar Yee'));
      await tester.pumpAndSettle();

      expect(find.text('Order #2302'), findsOneWidget);
      await _expectCount(tester, '2/5');

      // Back returns to My Tasks.
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('#2301'), findsOneWidget);
    });
  });

  group('Packing order', () {
    testWidgets('pack every product, review, and mark ready', (tester) async {
      final (container, _) = await _pumpAs(tester, 'Daniel Lee');
      await scrollIntoView(tester, find.text('Wong Kar Yee'));
      await tester.tap(find.text('Wong Kar Yee'));
      await tester.pumpAndSettle();

      await _expectCount(tester, '2/5');
      expect(buttonWithText(tester, 'Review & mark ready').enabled, isFalse);

      // Brand, pack size and quantity are shown for each product.
      expect(find.text('Farm Fresh · 1L'), findsOneWidget);
      expect(find.text('Oatside · 1L'), findsOneWidget);
      expect(find.text('×2'), findsOneWidget);

      await _tapProduct(tester, 'Fresh milk');
      await _expectCount(tester, '3/5');
      await _tapProduct(tester, 'Oat milk');
      await _tapProduct(tester, 'Sugar');

      expect(find.textContaining('TO PACK'), findsNothing);
      expect(buttonWithText(tester, 'Review & mark ready').enabled, isTrue);

      await tester.tap(find.text('Review & mark ready'));
      await tester.pumpAndSettle();
      expect(find.text('Review order #2302'), findsOneWidget);
      expect(buttonWithText(tester, 'Mark as ready').enabled, isTrue);

      await tester.tap(find.text('Mark as ready'));
      await tester.pumpAndSettle();

      expect(find.text('Order #2302 is ready'), findsOneWidget);

      await tester.tap(find.text('Back to My Tasks'));
      await tester.pumpAndSettle();
      expect(routerLocation(container), AppRoutes.workerPacking);
      expect(find.text('#2302'), findsNothing);
    });

    testWidgets('closing the review keeps the order being packed', (
      tester,
    ) async {
      final (_, repository) = await _pumpAs(tester, 'Daniel Lee');
      final daniel = mockWorker('Daniel Lee');
      await repository.setItemPacked(daniel, 'ord-2303', 'L4', packed: true);
      await tester.pumpAndSettle();

      await scrollIntoView(tester, find.text('Mei Ling Tan'));
      await tester.tap(find.text('Mei Ling Tan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Review & mark ready'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Order #2303 is ready'), findsNothing);
      expect(find.text('Review & mark ready'), findsOneWidget);
    });

    testWidgets('products cannot be ticked before Start packing', (
      tester,
    ) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2301'),
      );

      // The checkbox is disabled, so the tap opens the details instead.
      await _tapProduct(tester, 'Wholemeal bread');
      expect(find.text('Mark as packed'), findsNothing);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await _expectCount(tester, '0/3');

      await tester.tap(find.text('Start packing'));
      await tester.pumpAndSettle();
      await _tapProduct(tester, 'Wholemeal bread');
      await _expectCount(tester, '1/3');
    });

    testWidgets('tapping a packed product unticks it', (tester) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2302'),
      );

      await _tapProduct(tester, 'Jasmine rice');
      await _expectCount(tester, '1/5');
    });

    testWidgets('tapping a product shows its details and can tick it', (
      tester,
    ) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2302'),
      );

      await scrollIntoView(tester, find.text('Sugar'));
      await tester.tap(find.text('Sugar'));
      await tester.pumpAndSettle();
      expect(find.text('CSR'), findsOneWidget);
      expect(find.text('RM 2.85 each'), findsOneWidget);

      await tester.tap(find.text('Mark as packed'));
      await tester.pumpAndSettle();
      await _expectCount(tester, '3/5');
    });

    testWidgets('changes made elsewhere show up live', (tester) async {
      final (_, repository) = await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2302'),
      );

      await repository.setItemPacked(
        mockWorker('Daniel Lee'),
        'ord-2302',
        'L5',
        packed: true,
      );
      await tester.pumpAndSettle();

      await _expectCount(tester, '3/5');
    });

    testWidgets('a cancelled order is read-only', (tester) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2311'),
      );

      expect(
        find.text('This order was cancelled. Do not pack it.'),
        findsOneWidget,
      );
      expect(find.text('Start packing'), findsNothing);
      // Read-only: no action bar, only the app bar Back button, and the
      // checklist stays unpacked (nothing can be ticked).
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.text('Chocolate bar'), findsOneWidget);
      expect(find.text('0/1'), findsOneWidget);
    });

    testWidgets('the packer sees when the driver collected the bag', (
      tester,
    ) async {
      final (_, repository) = await _pumpAs(
        tester,
        'Hakim Roslan',
        location: AppRoutes.workerPackingOrder('ord-2308'),
      );
      expect(find.text('Waiting for the driver to collect.'), findsOneWidget);

      // Manual verification matches the bag's collection code.
      final code = seedWorkerOrders(
        DateTime(2026, 10, 15, 12),
      ).firstWhere((order) => order.id == 'ord-2308').collectionCode;
      await repository.verifyCollection(
        mockWorker('Amir Hamzah'),
        'ord-2308',
        method: VerificationMethod.manual,
        code: code,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Collected on'), findsOneWidget);
    });

    testWidgets('a ready order is read-only', (tester) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2305'),
      );

      expect(
        find.text('Waiting on the pickup shelf for the customer.'),
        findsOneWidget,
      );
      expect(find.text('Review & mark ready'), findsNothing);
    });

    testWidgets("another packer's order is not available", (tester) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2304'),
      );

      expect(find.text('Order not available'), findsOneWidget);
    });

    testWidgets("a colleague's ready pickup is not shown as a packing "
        'task', (tester) async {
      // Daniel can see 2306 in Ready for Pickup, but Hakim packed it, so it
      // must not open on Daniel's packing screen.
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2306'),
      );

      expect(find.text('Order not available'), findsOneWidget);
    });

    testWidgets('a driver cannot open a packing screen', (tester) async {
      final (container, _) = await _pumpAs(
        tester,
        'Amir Hamzah',
        location: AppRoutes.workerPackingOrder('ord-2301'),
      );

      expect(routerLocation(container), AppRoutes.workerDelivery);
    });
  });

  group('PackingOrderViewModel', () {
    test('returns the reason when an action is refused', () async {
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
          .select(mockWorker('Daniel Lee'));

      final provider = packingOrderViewModelProvider('ord-2302');
      container.listen(provider, (previous, next) {});
      final viewModel = container.read(provider.notifier);

      expect(await viewModel.markReady(), '3 items still need to be packed.');
      expect(await viewModel.setItemPacked('L3', packed: true), isNull);
    });
  });
}
