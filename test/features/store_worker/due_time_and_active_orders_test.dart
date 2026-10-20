import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/delivery_map_preview.dart';
import 'package:mae_assignment/features/store_worker/orders/data/order_due_time.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../../helpers/fake_branch_service.dart';
import '../../helpers/worker_profiles.dart';
import '../../helpers/worker_test_store.dart';

Order _order(
  String id, {
  OrderStatus status = OrderStatus.pending,
  bool isDelivery = false,
  DateTime? placedAt,
  DateTime? dueAt,
  String branchId = 'ss15',
  String? packerId = 'mock-daniel',
  LatLng? addressLocation,
}) {
  return Order(
    id: id,
    number: int.parse(id.replaceAll(RegExp('[^0-9]'), '')),
    customerId: 'c',
    customerName: 'Customer',
    customerPhone: '012',
    branchId: branchId,
    branchName: branchId,
    isDelivery: isDelivery,
    items: const [],
    subtotal: 0,
    deliveryFee: 0,
    discount: 0,
    total: 0,
    status: status,
    packerId: packerId,
    packerName: 'Daniel Lee',
    placedAt: placedAt,
    dueAt: dueAt,
    statusSince: placedAt,
    addressLocation: addressLocation,
  );
}

void main() {
  final placed = DateTime(2026, 10, 16, 12);

  group('Order.promisedAt', () {
    test('uses the due time HQ saved', () {
      final due = DateTime(2026, 10, 16, 18);

      expect(_order('o1', placedAt: placed, dueAt: due).promisedAt, due);
    });

    test('a pickup is promised 25 minutes after it was placed', () {
      expect(
        _order('o1', placedAt: placed).promisedAt,
        placed.add(const Duration(minutes: 25)),
      );
    });

    test('a delivery is promised 60 minutes after it was placed', () {
      expect(
        _order('o1', placedAt: placed, isDelivery: true).promisedAt,
        placed.add(const Duration(hours: 1)),
      );
    });

    test('is unknown when there is neither a due nor a placed time', () {
      expect(_order('o1').promisedAt, isNull);
    });
  });

  group('unfinished orders are never dropped', () {
    late FakeFirebaseFirestore firestore;
    late OrderService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = OrderService(firestore);
    });

    Future<void> put(List<Order> orders) => putOrders(firestore, orders);

    test('the branch stream has every unfinished order, old or new', () async {
      await put([
        _order('o1', placedAt: DateTime(2026, 8)),
        _order('o2', status: OrderStatus.packing, placedAt: placed),
        _order('o3', status: OrderStatus.ready, placedAt: placed),
        _order('o4', status: OrderStatus.outForDelivery, placedAt: placed),
        _order('o5', status: OrderStatus.completed, placedAt: placed),
        _order('o6', status: OrderStatus.cancelled, placedAt: placed),
        _order('o7', branchId: 'other', placedAt: placed),
      ]);

      final orders = await service.watchActiveBranchOrders('ss15').first;

      expect(orders.map((o) => o.id).toSet(), {'o1', 'o2', 'o3', 'o4'});
    });

    test(
      "the driver stream has only that driver's unfinished orders",
      () async {
        await put([
          _order('o1', placedAt: DateTime(2026, 8)).copyWith(driverId: 'd1'),
          _order('o2', placedAt: placed).copyWith(driverId: 'd2'),
          _order(
            'o3',
            status: OrderStatus.completed,
            placedAt: placed,
          ).copyWith(driverId: 'd1'),
        ]);

        final orders = await service.watchActiveDriverOrders('d1').first;

        expect(orders.map((o) => o.id), ['o1']);
      },
    );
  });

  group('WorkerOrdersRepository with many orders', () {
    test(
      'an old unfinished task shows even when 200 newer orders exist',
      () async {
        final firestore = FakeFirebaseFirestore();
        final daniel = testWorker('Daniel Lee');
        await putOrders(firestore, [
          // Far older than anything in the "recent" window.
          _order('o1', placedAt: DateTime(2026, 6)),
          for (var i = 0; i < 205; i++)
            _order(
              'o${1000 + i}',
              status: OrderStatus.completed,
              placedAt: placed.add(Duration(minutes: i)),
              packerId: 'someone-else',
            ),
        ]);
        final repository = WorkerOrdersRepository(
          OrderService(firestore),
          FakeDeliveryProofService(),
        );

        final tasks = await repository
            .watchMyPackingTasks(daniel.copyWith(id: 'mock-daniel'))
            .first;

        expect(tasks.map((o) => o.id), ['o1']);
      },
    );

    test('an order that finishes leaves the task list', () async {
      final firestore = FakeFirebaseFirestore();
      await putOrders(firestore, [_order('o1', placedAt: placed)]);
      final repository = WorkerOrdersRepository(
        OrderService(firestore),
        FakeDeliveryProofService(),
      );
      final daniel = testWorker('Daniel Lee').copyWith(id: 'mock-daniel');
      final lists = <List<String>>[];
      final subscription = repository
          .watchMyPackingTasks(daniel)
          .listen((orders) => lists.add([for (final o in orders) o.id]));
      addTearDown(subscription.cancel);
      await Future<void>.delayed(Duration.zero);

      await firestore.collection('orders').doc('o1').update({
        'status': 'completed',
      });
      await Future<void>.delayed(Duration.zero);

      expect(lists.first, ['o1']);
      expect(lists.last, isEmpty);
    });
  });

  group('DeliveryMapPreview', () {
    Future<void> pump(WidgetTester tester, Order order) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            branchServiceProvider.overrideWithValue(FakeBranchService()),
          ],
          child: MaterialApp(
            home: Scaffold(body: DeliveryMapPreview(order: order)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the straight-line distance from store to customer', (
      tester,
    ) async {
      await pump(
        tester,
        _order(
          'o1',
          isDelivery: true,
          addressLocation: const LatLng(3.08, 101.6),
        ),
      );

      expect(
        find.textContaining('from store to customer (straight line)'),
        findsOneWidget,
      );
    });

    testWidgets('shows nothing when neither place is known', (tester) async {
      await pump(tester, _order('o1', isDelivery: true, branchId: 'unknown'));

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('shows only the map when the customer pin is missing', (
      tester,
    ) async {
      await pump(tester, _order('o1', isDelivery: true));

      expect(find.byType(Card), findsOneWidget);
      expect(find.textContaining('straight line'), findsNothing);
    });
  });
}
