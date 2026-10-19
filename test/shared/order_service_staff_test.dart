import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../helpers/worker_test_store.dart';

/// The staff side of OrderService: watching a branch or a driver's orders,
/// changing an order in a transaction, and assigning people.
void main() {
  final placed = DateTime(2026, 10, 16, 12);

  Order order(
    String id, {
    String branch = 'ss15',
    OrderStatus status = OrderStatus.pending,
    String? driverId,
    bool isDelivery = true,
    DateTime? placedAt,
  }) {
    return Order(
      id: id,
      number: int.parse(id.replaceAll(RegExp('[^0-9]'), '')),
      customerId: 'customer',
      customerName: 'Customer',
      customerPhone: '012',
      branchId: branch,
      branchName: branch,
      isDelivery: isDelivery,
      items: const [
        OrderItem(
          lineId: 'L1',
          productId: 'p1',
          name: 'Milk',
          brand: 'Farm',
          packSize: '1L',
          quantity: 1,
          unitPrice: 5,
        ),
      ],
      subtotal: 5,
      deliveryFee: 0,
      discount: 0,
      total: 5,
      status: status,
      driverId: driverId,
      placedAt: placedAt ?? placed,
      statusSince: placedAt ?? placed,
    );
  }

  late FakeFirebaseFirestore firestore;
  late OrderService service;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    service = OrderService(firestore);
    await putOrders(firestore, [
      order('o1', placedAt: placed),
      order('o2', placedAt: placed.add(const Duration(hours: 1))),
      order('o3', branch: 'bukit-jalil', driverId: 'd1'),
      order(
        'o4',
        status: OrderStatus.ready,
        driverId: 'd1',
        placedAt: placed.subtract(const Duration(days: 2)),
      ),
      order('o5', status: OrderStatus.outForDelivery, driverId: 'd2'),
      order('o6', status: OrderStatus.ready, isDelivery: false),
      order('o7', status: OrderStatus.completed),
    ]);
  });

  group('watching', () {
    test("a branch's orders, newest first", () async {
      final orders = await service.watchBranchOrders('ss15').first;

      expect(orders.map((o) => o.id).toSet(), {
        'o1',
        'o2',
        'o4',
        'o5',
        'o6',
        'o7',
      });
      expect(orders.every((o) => o.branchId == 'ss15'), isTrue);
      final times = [for (final o in orders) o.placedAt!];
      expect(times, [...times]..sort((a, b) => b.compareTo(a)));
    });

    test("a driver's own orders only", () async {
      final orders = await service.watchDriverOrders('d1').first;

      expect(orders.map((o) => o.id).toSet(), {'o3', 'o4'});
    });

    test(
      'deliveries that are ready or on the road, for all branches',
      () async {
        final orders = await service.watchActiveDeliveries().first;

        // Pickup (o6), pending and completed orders are not deliveries on
        // the move.
        expect(orders.map((o) => o.id).toSet(), {'o4', 'o5'});
      },
    );

    test('unfinished orders of a branch, whenever they were placed', () async {
      final orders = await service.getActiveBranchOrders('ss15');

      expect(orders.map((o) => o.id).toSet(), {'o1', 'o2', 'o4', 'o5', 'o6'});
    });

    test('orders between two times', () async {
      final orders = await service.getBranchOrdersBetween(
        'ss15',
        DateTime(2026, 10, 16),
        DateTime(2026, 10, 17),
      );

      expect(orders.map((o) => o.id).toSet(), {'o1', 'o2', 'o5', 'o6', 'o7'});
    });
  });

  group('updateOrder', () {
    test('saves only what changed', () async {
      final saved = await service.updateOrder(
        'o1',
        (current) => current.copyWith(
          status: OrderStatus.packing,
          statusSince: DateTime(2026, 10, 16, 12, 30),
          packingStartedAt: DateTime(2026, 10, 16, 12, 30),
          packedLineIds: {'L1'},
        ),
      );

      expect(saved!.status, OrderStatus.packing);
      final data = (await firestore.collection('orders').doc('o1').get())
          .data()!;
      expect(data['status'], 'packing');
      expect(data['packedLineIds'], ['L1']);
      // Times are saved as the server time, not the time the change chose.
      for (final key in ['statusSince', 'packingStartedAt']) {
        final saved = (data[key] as Timestamp).toDate();
        expect(DateTime.now().difference(saved).inMinutes.abs(), lessThan(5));
        expect(saved, isNot(DateTime(2026, 10, 16, 12, 30)));
      }
      // Checkout fields are untouched.
      expect(data['total'], 5);
      expect(data['customerName'], 'Customer');
    });

    test(
      'a status change always stamps statusSince with the server time',
      () async {
        await service.updateOrder(
          'o1',
          (current) => current.copyWith(status: OrderStatus.packing),
        );

        final data = (await firestore.collection('orders').doc('o1').get())
            .data()!;
        final saved = (data['statusSince'] as Timestamp).toDate();
        expect(DateTime.now().difference(saved).inMinutes.abs(), lessThan(5));
      },
    );

    test('a missing order gives null', () async {
      final saved = await service.updateOrder('nope', (o) => o);

      expect(saved, isNull);
    });

    test('an error from the change stops the write', () async {
      await expectLater(
        service.updateOrder('o1', (current) => throw StateError('refused')),
        throwsStateError,
      );

      final data = (await firestore.collection('orders').doc('o1').get())
          .data()!;
      expect(data['status'], 'pending');
    });
  });

  group('assigning', () {
    test('a packer', () async {
      await service.assignPacker('o1', packerId: 'p1', packerName: 'Daniel');

      final saved = (await service.getOrder('o1'))!;
      expect(saved.packerId, 'p1');
      expect(saved.packerName, 'Daniel');
      expect(saved.packerAssignedAt, isNotNull);
    });

    test('a driver', () async {
      await service.assignDriver('o1', driverId: 'd9', driverName: 'Kumar');

      final saved = (await service.getOrder('o1'))!;
      expect(saved.driverId, 'd9');
      expect(saved.driverName, 'Kumar');
      expect(saved.driverAssignedAt, isNotNull);
    });
  });
}
