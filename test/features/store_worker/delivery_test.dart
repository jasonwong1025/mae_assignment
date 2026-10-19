import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/camera_service.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/launcher_service.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/view_models/delivery_detail_view_model.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

import '../../helpers/worker_profiles.dart';
import '../../helpers/worker_test_app.dart';
import '../../helpers/worker_test_orders.dart';
import '../../helpers/worker_test_store.dart';

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

/// A valid 1x1 transparent PNG, so widgets that decode the proof photo
/// (ExpandablePhoto) can render it in a test.
final Uint8List _onePixelPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, //
  0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4,
  0x89, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9c, 0x62, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae,
  0x42, 0x60, 0x82,
]);

/// Returns a fixed photo instead of opening the real camera, so the
/// proof-of-delivery flow can be exercised in a widget test.
class _FakeCamera extends CameraService {
  _FakeCamera() : super(ImagePicker());

  @override
  Future<Uint8List?> takePhoto() async => _onePixelPng;
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
    overrides: [
      launcherServiceProvider.overrideWithValue(launcher),
      cameraServiceProvider.overrideWithValue(_FakeCamera()),
    ],
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

      expect(find.text('Out for delivery (1)'), findsOneWidget);
      expect(find.text('#2309'), findsOneWidget);
      // Drivers now work across branches, so Amir's Bukit Jalil order
      // (#1184) joins his SS15 order (#2308) in Ready to collect.
      expect(find.text('Ready to collect (2)'), findsOneWidget);
      expect(find.text('#2308'), findsOneWidget);
      expect(find.text('#1184'), findsOneWidget);

      await scrollIntoView(tester, find.text('Being packed (1)'));
      await scrollIntoView(tester, find.text('#2303'));

      // Pickup orders and other drivers' deliveries are not listed.
      // Completed orders move to My history, not this list.
      expect(find.text('#2305'), findsNothing);
      expect(find.text('#2310'), findsNothing);
    });

    testWidgets('a driver sees only the deliveries assigned to them', (
      tester,
    ) async {
      await pumpWorkerApp(
        tester,
        'Tan Wei Jie',
        location: AppRoutes.workerDelivery,
      );

      // Wei Jie's own deliveries.
      expect(find.text('#1185'), findsOneWidget);
      // Amir's deliveries (including the Bukit Jalil #1184) are not his.
      expect(find.text('#1184'), findsNothing);
      expect(find.text('#2308'), findsNothing);
      expect(find.text('#2309'), findsNothing);
    });

    testWidgets('a packer marking an order ready moves it to Ready to '
        'collect', (tester) async {
      final (_, repository, _) = await _pumpAmir(tester);
      final daniel = testWorker('Daniel Lee');

      await repository.setItemPacked(daniel, 'ord-2303', 'L4', packed: true);
      await repository.markReady(daniel, 'ord-2303');
      await tester.pumpAndSettle();

      // #2303 joins #2308 and #1184 in Ready to collect; nothing is left
      // being packed for Amir, so that section disappears.
      expect(find.text('Ready to collect (3)'), findsOneWidget);
      expect(find.textContaining('Being packed'), findsNothing);
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
      // The next step is explained but locked until the order is ready.
      expect(
        find.textContaining('You can verify the order once it is ready'),
        findsOneWidget,
      );
      expect(buttonWithText(tester, 'Verify order').enabled, isFalse);
      expect(find.text('Start delivery'), findsNothing);
    });

    testWidgets('verify, start, and complete a delivery', (tester) async {
      final (container, repository, _) = await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2308'),
      );

      // The bag's collection code, read from the seed order (computed from
      // the order id, so it is stable).
      final seedOrder = workerTestOrders(
        DateTime(2026, 10, 15, 12),
      ).firstWhere((order) => order.id == 'ord-2308');
      final collectionCode = seedOrder.collectionCode;

      // Customer details are on the screen.
      expect(find.text('David Wong'), findsOneWidget);
      expect(find.text('012-777 3344'), findsOneWidget);
      expect(find.textContaining('Leave with the guard'), findsOneWidget);
      expect(find.text('Start delivery'), findsNothing);

      // A wrong collection code is rejected with a reason.
      await tester.tap(find.text('Verify order'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'WRONGXX');
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      expect(find.textContaining('does not match order #2308'), findsOneWidget);

      // The right code verifies it, closes the sheet, and unlocks Start.
      await tester.enterText(find.byType(TextField), collectionCode);
      await tester.tap(find.text('Verify'));
      await tester.pumpAndSettle();
      expect(find.text('Verify the order'), findsNothing); // sheet closed
      expect(find.text('Start delivery'), findsOneWidget);

      await tester.tap(find.text('Start delivery'));
      await tester.pumpAndSettle();
      expect(find.text('Mark as delivered'), findsOneWidget);

      // Completing opens the proof-of-delivery sheet; the fake camera
      // supplies the photo, then Mark delivered finishes the order.
      await tester.tap(find.text('Mark as delivered'));
      await tester.pumpAndSettle();
      expect(find.text('Proof of delivery'), findsOneWidget);
      await tester.tap(find.text('Take photo'));
      // pump (not pumpAndSettle) so the busy spinner does not stall settle.
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Mark delivered'));
      await tester.pumpAndSettle();

      // Back on My Deliveries with a success message. The completed order
      // leaves the list (it moves to My history).
      expect(routerLocation(container), AppRoutes.workerDelivery);
      expect(find.text('Order #2308 delivered to David Wong.'), findsOneWidget);
      expect(find.text('#2308'), findsNothing);
    });

    testWidgets('cancelling the confirmation keeps it on the way', (
      tester,
    ) async {
      await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-2309'),
      );

      // Opens the proof-of-delivery sheet, then closes it without a photo.
      await tester.tap(find.text('Mark as delivered'));
      await tester.pumpAndSettle();
      expect(find.text('Proof of delivery'), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      // Sheet gone, still out for delivery.
      expect(find.text('Proof of delivery'), findsNothing);
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

      expect(find.textContaining('Delivered on'), findsOneWidget);
      expect(find.text('Mark as delivered'), findsNothing);
      expect(find.text('Back to My Deliveries'), findsOneWidget);
    });

    testWidgets('a cancelled delivery is read-only and leaves the list', (
      tester,
    ) async {
      final store = await WorkerTestStore.create(
        seed: (now) => [
          for (final order in workerTestOrders(now))
            if (order.id == 'ord-2308')
              order.copyWith(status: OrderStatus.cancelled)
            else
              order,
        ],
      );
      final (container, _, _) = await _pumpAmir(
        tester,
        repository: store.repository,
      );
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
      // ord-1185 is assigned to another driver (Tan Wei Jie), so Amir
      // cannot open it even though drivers now work across branches.
      await _pumpAmir(
        tester,
        location: AppRoutes.workerDeliveryOrder('ord-1185'),
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
      final repository = (await WorkerTestStore.create()).repository;
      final container = ProviderContainer(
        overrides: [
          workerOrdersRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(workerSessionProvider.notifier)
          .open(testWorker('Amir Hamzah'));

      final provider = deliveryDetailViewModelProvider('ord-2308');
      container.listen(provider, (previous, next) {});
      final viewModel = container.read(provider.notifier);

      // The bag's collection code, read from the order itself.
      final order = await repository
          .watchOrder(testWorker('Amir Hamzah'), 'ord-2308')
          .first;
      final photo = Uint8List.fromList([1, 2, 3]);

      expect(
        await viewModel.startDelivery(),
        'Verify the order before starting the delivery.',
      );
      expect(await viewModel.verifyByCode('WRONGXX'), isNotNull);
      expect(await viewModel.verifyByCode(order!.collectionCode), isNull);
      expect(await viewModel.startDelivery(), isNull);
      expect(await viewModel.completeDelivery(photo: photo), isNull);
      expect(
        await viewModel.completeDelivery(photo: photo),
        'This delivery is already completed.',
      );
    });
  });
}
