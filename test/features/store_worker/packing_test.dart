import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
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
  await scrollIntoView(tester, find.text(name));
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

void main() {
  group('My Tasks', () {
    testWidgets('lists only my orders, with the next one first', (
      tester,
    ) async {
      await _pumpAs(tester, 'Daniel Lee');

      expect(find.text('UP NEXT'), findsOneWidget);
      expect(find.text('#2302'), findsOneWidget);
      expect(find.text('Continue packing'), findsOneWidget);
      expect(find.text('2 of 5 packed'), findsOneWidget);
      expect(find.text('2 being packed · 1 to start'), findsOneWidget);

      await scrollIntoView(tester, find.text('#2301'));
      expect(find.text('#2301'), findsOneWidget);

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
      expect(find.text('0 of 3 products packed'), findsOneWidget);
    });

    testWidgets('tapping an order opens its packing screen', (tester) async {
      await _pumpAs(tester, 'Daniel Lee');

      await tester.tap(find.text('Wong Kar Yee'));
      await tester.pumpAndSettle();

      expect(find.text('Order #2302'), findsOneWidget);
      expect(find.text('2 of 5 products packed'), findsOneWidget);

      // Back returns to My Tasks.
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('UP NEXT'), findsOneWidget);
    });
  });

  group('Packing order', () {
    testWidgets('pack every product, review, and mark ready', (tester) async {
      final (container, _) = await _pumpAs(tester, 'Daniel Lee');
      await tester.tap(find.text('Continue packing'));
      await tester.pumpAndSettle();

      expect(find.text('2 of 5 products packed'), findsOneWidget);
      expect(find.text('3 products left to pack'), findsOneWidget);
      expect(buttonWithText(tester, 'Review & mark ready').enabled, isFalse);

      // Brand, pack size and quantity are shown for each product.
      expect(find.text('Farm Fresh · 1L'), findsNWidgets(2));
      expect(find.text('×2'), findsOneWidget);

      await _tapProduct(tester, 'Fresh milk, full cream');
      expect(find.text('3 of 5 products packed'), findsOneWidget);
      await _tapProduct(tester, 'Fresh milk, low fat');
      await _tapProduct(tester, 'Fine sugar');

      expect(find.text('5 of 5 products packed'), findsOneWidget);
      expect(buttonWithText(tester, 'Review & mark ready').enabled, isTrue);

      await tester.tap(find.text('Review & mark ready'));
      await tester.pumpAndSettle();
      expect(find.text('Review order #2302'), findsOneWidget);
      expect(buttonWithText(tester, 'Mark as ready').enabled, isFalse);

      await tester.tap(find.text("I've checked all products and quantities"));
      await tester.pumpAndSettle();
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
      await tester.tap(find.text('Keep packing'));
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

      await _tapProduct(tester, 'Wholemeal bread');
      expect(find.text('0 of 3 products packed'), findsOneWidget);

      await tester.tap(find.text('Start packing'));
      await tester.pumpAndSettle();
      await _tapProduct(tester, 'Wholemeal bread');
      expect(find.text('1 of 3 products packed'), findsOneWidget);
    });

    testWidgets('tapping a packed product unticks it', (tester) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2302'),
      );

      await _tapProduct(tester, 'Jasmine rice');
      expect(find.text('1 of 5 products packed'), findsOneWidget);
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

      expect(find.text('3 of 5 products packed'), findsOneWidget);
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
      expect(find.text('Back to My Tasks'), findsOneWidget);

      await _tapProduct(tester, 'Milk chocolate');
      expect(find.text('0 of 1 products packed'), findsOneWidget);
    });

    testWidgets('a ready order is read-only', (tester) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2305'),
      );

      expect(
        find.text('Packed and waiting on the pickup shelf.'),
        findsOneWidget,
      );
      expect(find.text('Review & mark ready'), findsNothing);
    });

    testWidgets('another packer\'s order is not available', (tester) async {
      await _pumpAs(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerPackingOrder('ord-2304'),
      );

      expect(find.text('Order not available'), findsOneWidget);
    });

    testWidgets('a colleague\'s ready pickup is not shown as a packing '
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
        overrides: [workerOrdersRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      container.read(workerSessionProvider.notifier).select(
        mockWorker('Daniel Lee'),
      );

      final provider = packingOrderViewModelProvider('ord-2302');
      container.listen(provider, (previous, next) {});
      final viewModel = container.read(provider.notifier);

      expect(await viewModel.markReady(), '3 items still need to be packed.');
      expect(await viewModel.setItemPacked('L3', packed: true), isNull);
    });
  });
}
