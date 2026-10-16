import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/launcher_service.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/view_models/delivery_detail_view_model.dart';
import 'package:mae_assignment/features/store_worker/orders/data/mock_worker_orders.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

import '../../helpers/worker_test_app.dart';

/// Records what would have been opened instead of leaving the app.
class _FakeLauncher extends LauncherService {
  /// False imitates a phone with no maps or phone app.
  bool succeed = true;
  final opened = <String>[];

  @override
  Future<bool> openDirections(String address) async {
    opened.add('maps:$address');
    return succeed;
  }

  @override
  Future<bool> call(String phone) async {
    opened.add('tel:$phone');
    return succeed;
  }
}

/// Opens the app as Amir (SS15 driver) at [location], with a fake
/// launcher.
Future<(ProviderContainer, WorkerOrdersRepository, _FakeLauncher)> _pumpAmir(
  WidgetTester tester, {
  String location = AppRoutes.workerDelivery,
  WorkerOrdersRepository? repository,
}) async {
  final launcher = _FakeLauncher();
  final (container, orders) = await pumpWorkerApp(
    tester,
    'Amir Hamzah',
    location: location,
    repository: repository,
    overrides: [launcherServiceProvider.overrideWithValue(launcher)],
  );
  return (container, orders, launcher);
}

Future<void> _tap(WidgetTester tester, String text) async {
  await scrollIntoView(tester, find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  group('My Deliveries', () {
    testWidgets('groups my deliveries by stage', (tester) async {
      await _pumpAmir(tester);

      expect(find.text('OUT FOR DELIVERY (1)'), findsOneWidget);
      expect(find.text('#2309'), findsOneWidget);
      expect(find.text('READY TO COLLECT (1)'), findsOneWidget);
      expect(find.text('#2308'), findsOneWidget);

      await scrollIntoView(tester, find.text('BEING PACKED (2)'));
      await scrollIntoView(tester, find.text('#2303'));
      expect(find.text('3 of 4 packed'), findsOneWidget);
      await scrollIntoView(tester, find.text('COMPLETED TODAY (1)'));
      await scrollIntoView(tester, find.text('#2310'));

      // Pickup orders and another branch's deliveries are not listed.
      expect(find.text('#2305'), findsNothing);
      expect(find.text('#1184'), findsNothing);
    });

    testWidgets("another branch's driver sees only their own", (tester) async {
      await pumpWorkerApp(
        tester,
        'Tan Wei Jie',
        location: AppRoutes.workerDelivery,
      );

      expect(find.text('#1185'), findsOneWidget);
      expect(find.text('#1184'), findsOneWidget);
      expect(find.text('#2308'), findsNothing);
      expect(find.text('#2309'), findsNothing);
    });

    testWidgets('a packer marking an order ready moves it to Ready to '
        'collect', (tester) async {
      final (_, repository, _) = await _pumpAmir(tester);
      final daniel = mockWorker('Daniel Lee');

      await repository.setItemPacked(daniel, 'ord-2303', 'L4', packed: true);
      await repository.markReady(daniel, 'ord-2303');
      await tester.pumpAndSettle();

      expect(find.text('READY TO COLLECT (2)'), findsOneWidget);
      expect(find.text('BEING PACKED (1)'), findsOneWidget);
    });
  });

  group('Delivery details', () {
    testWidgets('an order being packed can be viewed but not collected', (
      tester,
    ) async {
      await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2303'),
      );

      expect(find.text('Delivery #2303'), findsOneWidget);
      expect(find.text('3 of 4 packed'), findsOneWidget);
      expect(find.textContaining('Still being packed'), findsOneWidget);
      expect(buttonWithText(tester, 'Verify order').enabled, isFalse);
      expect(find.text('Start delivery'), findsNothing);
    });

    testWidgets('verify, start, and complete a delivery', (tester) async {
      final (container, _, _) = await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2308'),
      );

      // Customer details are on the screen.
      expect(find.text('David Wong'), findsOneWidget);
      expect(find.text('012-777 3344'), findsOneWidget);
      expect(find.textContaining('Leave with the guard'), findsOneWidget);
      expect(find.text('Start delivery'), findsNothing);

      // A wrong number is rejected with a reason.
      await tester.tap(find.text('Verify order'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '2309');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'That number does not match order #2308. Check the bag and try '
          'again.',
        ),
        findsOneWidget,
      );

      // The right number verifies it and unlocks Start delivery.
      await tester.enterText(find.byType(TextField), '2308');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Order verified'), findsOneWidget);

      await tester.tap(find.text('Start delivery'));
      await tester.pumpAndSettle();
      // ("On the way" alone is also a stepper label.)
      expect(find.textContaining('On the way. Mark it'), findsOneWidget);

      await tester.tap(find.text('Mark as delivered'));
      await tester.pumpAndSettle();
      expect(find.text('Mark order #2308 delivered?'), findsOneWidget);
      await tester.tap(find.text('Mark delivered'));
      await tester.pumpAndSettle();

      // Back on My Deliveries with a success message.
      expect(routerLocation(container), AppRoutes.workerDelivery);
      expect(find.text('Order #2308 delivered to David Wong.'), findsOneWidget);
      expect(find.text('READY TO COLLECT (1)'), findsNothing);
      await scrollIntoView(tester, find.text('COMPLETED TODAY (2)'));
    });

    testWidgets('cancelling the confirmation keeps it on the way', (
      tester,
    ) async {
      await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2309'),
      );

      await tester.tap(find.text('Mark as delivered'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Mark as delivered'), findsOneWidget);
    });

    testWidgets('Navigate and Call open the maps and phone apps', (
      tester,
    ) async {
      final (_, _, launcher) = await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2309'),
      );

      await _tap(tester, 'Navigate');
      await _tap(tester, 'Call');

      expect(launcher.opened, [
        'maps:8, Jalan SS15/2A, 47500 Subang Jaya',
        'tel:011-2345 6780',
      ]);
    });

    testWidgets('a device that cannot open maps shows a message', (
      tester,
    ) async {
      final (_, _, launcher) = await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2309'),
      );
      launcher.succeed = false;

      await _tap(tester, 'Navigate');
      expect(
        find.text('Google Maps could not be opened on this device.'),
        findsOneWidget,
      );
    });

    testWidgets('a completed delivery is read-only', (tester) async {
      await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2310'),
      );

      expect(find.textContaining('Delivered at'), findsOneWidget);
      expect(find.text('Mark as delivered'), findsNothing);
      expect(find.text('Back to My Deliveries'), findsOneWidget);
    });

    testWidgets('a cancelled delivery is read-only and leaves the list', (
      tester,
    ) async {
      final repository = WorkerOrdersRepository(
        seed: (now) => [
          for (final order in seedWorkerOrders(now))
            if (order.id == 'ord-2308')
              order.copyWith(status: OrderStatus.cancelled)
            else
              order,
        ],
      );
      final (container, _, _) = await _pumpAmir(tester, repository: repository);
      expect(find.text('#2308'), findsNothing);

      container
          .read(appRouterProvider)
          .go(AppRoutes.workerDeliveryOrder('ord-2308'));
      await tester.pumpAndSettle();
      expect(
        find.text('This order was cancelled. Do not deliver it.'),
        findsOneWidget,
      );
      expect(find.text('Verify order'), findsNothing);
    });

    testWidgets("someone else's delivery is not available", (tester) async {
      await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-1184'),
      );
      expect(find.text('Delivery not available'), findsOneWidget);
    });

    testWidgets('a pickup order cannot be opened as a delivery', (
      tester,
    ) async {
      await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2305'),
      );
      expect(find.text('Delivery not available'), findsOneWidget);
    });

    testWidgets('packers cannot open delivery screens', (tester) async {
      final (container, _) = await pumpWorkerApp(
        tester,
        'Daniel Lee',
        location: AppRoutes.workerDelivery,
      );
      expect(routerLocation(container), AppRoutes.workerPacking);

      container
          .read(appRouterProvider)
          .go(AppRoutes.workerDeliveryOrder('ord-2308'));
      await tester.pumpAndSettle();
      expect(routerLocation(container), AppRoutes.workerPacking);
    });
  });

  group('DeliveryDetailViewModel', () {
    test('returns the reason for a wrong number or early start', () async {
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
          .select(mockWorker('Amir Hamzah'));

      final provider = deliveryDetailViewModelProvider('ord-2308');
      container.listen(provider, (previous, next) {});
      final viewModel = container.read(provider.notifier);

      expect(
        await viewModel.startDelivery(),
        'Verify the order before starting the delivery.',
      );
      expect(await viewModel.verifyByNumber('1234'), isNotNull);
      expect(await viewModel.verifyByNumber('#2308'), isNull);
      expect(await viewModel.startDelivery(), isNull);
      expect(await viewModel.completeDelivery(), isNull);
      expect(
        await viewModel.completeDelivery(),
        'This delivery is already completed.',
      );
    });
  });
}
