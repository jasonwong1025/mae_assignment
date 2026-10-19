import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_worker/orders/data/worker_order_policy.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';

import '../../helpers/worker_profiles.dart';
import '../../helpers/worker_test_orders.dart';

WorkerProfile _worker(String name) {
  return testWorkers.firstWhere((worker) => worker.name == name);
}

final WorkerProfile _daniel = _worker('Daniel Lee');
final WorkerProfile _hakim = _worker('Hakim Roslan');
final WorkerProfile _amir = _worker('Amir Hamzah');
final WorkerProfile _nadia = _worker('Nadia Yusof');
final WorkerProfile _hafiz = _worker('Hafiz Zainal');
final WorkerProfile _weiJie = _worker('Tan Wei Jie');

final List<Order> _orders = workerTestOrders(DateTime(2026, 10, 15, 12));

Order _order(String id) {
  return _orders.firstWhere((order) => order.id == id);
}

/// Ids of the seed orders [worker] may see under [canView].
Set<String> _visible(
  WorkerProfile worker,
  bool Function(WorkerProfile, Order) canView,
) {
  return {
    for (final order in _orders)
      if (canView(worker, order)) order.id,
  };
}

void main() {
  group('seed orders', () {
    test('order ids are unique and line ids are unique within an order', () {
      final ids = _orders.map((order) => order.id).toList();
      expect(ids.toSet().length, ids.length);

      for (final order in _orders) {
        final lineIds = order.items.map((item) => item.lineId).toList();
        expect(lineIds.toSet().length, lineIds.length, reason: order.id);
      }
    });

    test('assignments match real workers in the same branch', () {
      for (final order in _orders) {
        final packer = testWorkers.firstWhere(
          (worker) => worker.id == order.packerId,
        );
        expect(packer.isPackingStaff, isTrue, reason: order.id);
        expect(packer.branchId, order.branchId, reason: order.id);
        expect(packer.name, order.packerName, reason: order.id);

        if (order.isPickup) {
          expect(order.driverId, isNull, reason: order.id);
          expect(order.address, isNull, reason: order.id);
        } else {
          final driver = testWorkers.firstWhere(
            (worker) => worker.id == order.driverId,
          );
          expect(driver.isDeliveryDriver, isTrue, reason: order.id);
          // Drivers now work across branches, so the driver's branch need
          // not match the order's.
          expect(order.address, isNotNull, reason: order.id);
        }
      }
    });

    test('checklists and statuses are consistent', () {
      for (final order in _orders) {
        for (final lineId in order.packedLineIds) {
          expect(order.hasLine(lineId), isTrue, reason: order.id);
        }
        final shouldBeFullyPacked = [
          OrderStatus.ready,
          OrderStatus.outForDelivery,
          OrderStatus.completed,
        ].contains(order.status);
        if (shouldBeFullyPacked) {
          expect(order.isFullyPacked, isTrue, reason: order.id);
        }
        if (order.status == OrderStatus.pending) {
          expect(order.packedLineIds, isEmpty, reason: order.id);
        }
        if (order.status == OrderStatus.completed) {
          expect(order.completedAt, isNotNull, reason: order.id);
          if (order.isPickup) {
            expect(order.pickupCompletedBy, isNotNull, reason: order.id);
          } else {
            expect(order.deliveredBy, order.driverId, reason: order.id);
          }
        }
        if (order.status == OrderStatus.outForDelivery) {
          expect(order.collectionVerifiedBy, order.driverId, reason: order.id);
        }
      }
    });

    test('completed samples stay "today" just after midnight', () {
      // At 00:10, "35 minutes ago" would be yesterday. Only today's
      // completed samples must stay on today's date; the mock also seeds
      // older orders (yesterday, three days ago) for My history, which are
      // expected to be on earlier days.
      final now = DateTime(2026, 10, 15, 0, 10);
      final startOfDay = DateTime(now.year, now.month, now.day);
      final completedToday = workerTestOrders(now).where(
        (order) =>
            order.status == OrderStatus.completed &&
            !order.completedAt!.isBefore(startOfDay),
      );

      expect(completedToday, isNotEmpty);
      for (final order in completedToday) {
        final at = order.completedAt!;
        expect(at.day, now.day, reason: order.id);
        expect(at.isAfter(now), isFalse, reason: order.id);
      }
    });

    test('nobody is assigned to the inactive worker', () {
      expect(_orders.where((order) => order.packerId == _nadia.id), isEmpty);
    });
  });

  group('Order', () {
    test('packing progress comes from the checklist', () {
      final order = _order('ord-2302');
      expect(order.packedLineCount, 2);
      expect(order.lineCount, 5);
      expect(order.packingProgress, closeTo(0.4, 0.001));
      expect(order.isFullyPacked, isFalse);

      final done = order.copyWith(
        packedLineIds: {'L1', 'L2', 'L3', 'L4', 'L5'},
      );
      expect(done.isFullyPacked, isTrue);
      expect(done.packingProgress, 1);
    });

    test('lists cannot be changed from outside', () {
      final order = _order('ord-2302');
      expect(() => order.packedLineIds.add('L3'), throwsUnsupportedError);
      expect(order.items.clear, throwsUnsupportedError);
    });
  });

  group('visibility', () {
    test('packers see only their own packing tasks', () {
      expect(
        _visible(_daniel, WorkerOrderPolicy.canViewPackingTask),
        containsAll(['ord-2301', 'ord-2302', 'ord-2303']),
      );
      expect(
        _visible(_daniel, WorkerOrderPolicy.canViewPackingTask),
        isNot(contains('ord-2304')),
      );
      expect(
        _visible(_hakim, WorkerOrderPolicy.canViewPackingTask),
        isNot(contains('ord-2302')),
      );
    });

    test('packers see no packing tasks from another branch', () {
      final hafizTasks = _visible(_hafiz, WorkerOrderPolicy.canViewPackingTask);
      expect(hafizTasks, isNotEmpty);
      // Every task Hafiz can see is at his own branch.
      for (final id in hafizTasks) {
        expect(_order(id).branchId, _hafiz.branchId, reason: id);
      }
    });

    test('every packer in the branch sees all ready pickup orders', () {
      final expected = {'ord-2305', 'ord-2306'};
      expect(_visible(_daniel, WorkerOrderPolicy.canViewPickupOrder), expected);
      expect(_visible(_hakim, WorkerOrderPolicy.canViewPickupOrder), expected);
      expect(_visible(_hafiz, WorkerOrderPolicy.canViewPickupOrder), {
        'ord-1183',
      });
    });

    test('drivers never see the pickup queue', () {
      expect(_visible(_amir, WorkerOrderPolicy.canViewPickupOrder), isEmpty);
    });

    test('drivers see only their own deliveries, including being packed', () {
      // Drivers work across branches, so each sees the orders assigned to
      // them regardless of branch (Amir's include Bukit Jalil's #1184).
      expect(_visible(_amir, WorkerOrderPolicy.canViewDelivery), {
        'ord-2303',
        'ord-2308',
        'ord-2309',
        'ord-2310',
        'ord-1184',
        // Completed deliveries Amir made, kept for My history.
        'ord-2281',
        'ord-2275',
      });
      expect(_visible(_weiJie, WorkerOrderPolicy.canViewDelivery), {
        'ord-2301',
        'ord-1181',
        'ord-1185',
        // Completed delivery Wei Jie made, kept for My history.
        'ord-1170',
      });
      expect(_visible(_daniel, WorkerOrderPolicy.canViewDelivery), isEmpty);
    });

    test('an inactive worker sees nothing', () {
      expect(_visible(_nadia, WorkerOrderPolicy.canViewOrder), isEmpty);
    });
  });

  group('packing rules', () {
    test('only the assigned packer can start a pending order', () {
      final order = _order('ord-2301');
      expect(WorkerOrderPolicy.checkStartPacking(_daniel, order), isNull);
      expect(
        WorkerOrderPolicy.checkStartPacking(_hakim, order),
        'This order is assigned to Daniel Lee.',
      );
      expect(
        WorkerOrderPolicy.checkStartPacking(_amir, order),
        'Only Packing Staff can pack orders.',
      );
      expect(
        WorkerOrderPolicy.checkStartPacking(_hafiz, order),
        'This order belongs to another branch.',
      );
    });

    test('packing cannot start twice or on a cancelled order', () {
      expect(
        WorkerOrderPolicy.checkStartPacking(_daniel, _order('ord-2302')),
        isNotNull,
      );
      expect(
        WorkerOrderPolicy.checkStartPacking(_daniel, _order('ord-2311')),
        'This order was cancelled.',
      );
    });

    test('the checklist can only change while packing', () {
      expect(
        WorkerOrderPolicy.checkEditChecklist(_daniel, _order('ord-2301'), 'L1'),
        'Start packing before ticking items.',
      );
      expect(
        WorkerOrderPolicy.checkEditChecklist(_daniel, _order('ord-2302'), 'L3'),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkEditChecklist(_daniel, _order('ord-2302'), 'L9'),
        'This item is not part of the order.',
      );
      expect(
        WorkerOrderPolicy.checkEditChecklist(_daniel, _order('ord-2305'), 'L1'),
        'This order is no longer being packed.',
      );
    });

    test('another packer cannot edit the checklist', () {
      expect(
        WorkerOrderPolicy.checkEditChecklist(_hakim, _order('ord-2302'), 'L3'),
        isNotNull,
      );
    });

    test('ready needs every line packed', () {
      final order = _order('ord-2302');
      expect(
        WorkerOrderPolicy.checkMarkReady(_daniel, order),
        '3 items still need to be packed.',
      );

      final done = order.copyWith(
        packedLineIds: {'L1', 'L2', 'L3', 'L4', 'L5'},
      );
      expect(WorkerOrderPolicy.checkMarkReady(_daniel, done), isNull);
      expect(WorkerOrderPolicy.checkMarkReady(_hakim, done), isNotNull);
    });
  });

  group('shortage rules', () {
    const proposed = LineShortage(
      status: ShortageStatus.proposed,
      replacement: OrderItem(
        lineId: 'L3',
        productId: 'p9',
        name: 'Other',
        brand: 'Brand',
        packSize: '1L',
        quantity: 1,
        unitPrice: 5,
      ),
    );
    const removed = LineShortage(status: ShortageStatus.removed);

    test('an unticked line of a packing order can be reported', () {
      expect(
        WorkerOrderPolicy.checkFlagUnavailable(
          _daniel,
          _order('ord-2302'),
          'L3',
        ),
        isNull,
      );
    });

    test('only the assigned packer, and only while packing', () {
      expect(
        WorkerOrderPolicy.checkFlagUnavailable(
          _hakim,
          _order('ord-2302'),
          'L3',
        ),
        isNotNull,
      );
      expect(
        WorkerOrderPolicy.checkFlagUnavailable(
          _daniel,
          _order('ord-2301'),
          'L1',
        ),
        'Start packing before reporting an item unavailable.',
      );
      expect(
        WorkerOrderPolicy.checkFlagUnavailable(
          _daniel,
          _order('ord-2305'),
          'L1',
        ),
        'This order is no longer being packed.',
      );
    });

    test('a ticked, unknown or already reported line is refused', () {
      final order = _order('ord-2302');
      expect(
        WorkerOrderPolicy.checkFlagUnavailable(_daniel, order, 'L1'),
        'Untick this item before reporting it unavailable.',
      );
      expect(
        WorkerOrderPolicy.checkFlagUnavailable(_daniel, order, 'L9'),
        'This item is not part of the order.',
      );
      expect(
        WorkerOrderPolicy.checkFlagUnavailable(
          _daniel,
          order.copyWith(shortages: {'L3': proposed}),
          'L3',
        ),
        'This item has already been reported unavailable.',
      );
    });

    test('a removed or waiting line cannot be ticked', () {
      final order = _order('ord-2302');
      expect(
        WorkerOrderPolicy.checkEditChecklist(
          _daniel,
          order.copyWith(shortages: {'L3': removed}),
          'L3',
        ),
        'This item was removed from the order.',
      );
      expect(
        WorkerOrderPolicy.checkEditChecklist(
          _daniel,
          order.copyWith(shortages: {'L3': proposed}),
          'L3',
        ),
        'Waiting for the customer to reply about this item.',
      );
    });

    test('ready waits for the customer, but not for removed lines', () {
      final order = _order(
        'ord-2302',
      ).copyWith(packedLineIds: {'L1', 'L2', 'L4', 'L5'});
      expect(
        WorkerOrderPolicy.checkMarkReady(
          _daniel,
          order.copyWith(shortages: {'L3': proposed}),
        ),
        'Waiting for the customer to reply about 1 unavailable item.',
      );
      expect(
        WorkerOrderPolicy.checkMarkReady(
          _daniel,
          order.copyWith(shortages: {'L3': removed}),
        ),
        isNull,
      );
    });

    test('an order with every line removed cannot be marked ready', () {
      final order = _order('ord-2302');
      final all = order.copyWith(
        packedLineIds: <String>{},
        shortages: {for (final item in order.items) item.lineId: removed},
      );
      expect(
        WorkerOrderPolicy.checkMarkReady(_daniel, all),
        'Every item was removed. Ask HQ to cancel this order.',
      );
    });
  });

  group('pickup rules', () {
    test('any packer in the branch can hand over a ready pickup', () {
      final packedByHakim = _order('ord-2306');
      expect(
        WorkerOrderPolicy.checkCompletePickup(_daniel, packedByHakim),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkCompletePickup(_hakim, packedByHakim),
        isNull,
      );
    });

    test('pickup handover is refused in every other case', () {
      final pickup = _order('ord-2306');
      expect(
        WorkerOrderPolicy.checkCompletePickup(_hafiz, pickup),
        'This order belongs to another branch.',
      );
      expect(
        WorkerOrderPolicy.checkCompletePickup(_amir, pickup),
        'Only Packing Staff can hand over pickup orders.',
      );
      expect(WorkerOrderPolicy.checkCompletePickup(_nadia, pickup), isNotNull);
      expect(
        WorkerOrderPolicy.checkCompletePickup(_daniel, _order('ord-2308')),
        'This is a delivery order. Its driver completes it.',
      );
      expect(
        WorkerOrderPolicy.checkCompletePickup(_daniel, _order('ord-2304')),
        'This order is not ready for pickup yet.',
      );
      expect(
        WorkerOrderPolicy.checkCompletePickup(_hakim, _order('ord-2307')),
        'This order has already been handed over by Daniel Lee.',
      );
    });
  });

  group('pickup QR code', () {
    final pickup = _order('ord-2306');

    test("accepts the order's own handover code", () {
      expect(
        WorkerOrderPolicy.checkPickupQr(pickup, pickup.handoverQrPayload),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkPickupQr(
          pickup,
          ' ${pickup.handoverQrPayload}\n',
        ),
        isNull,
      );
    });

    test("refuses another order's code or anything else", () {
      final other = _order('ord-2305');
      expect(
        WorkerOrderPolicy.checkPickupQr(pickup, other.handoverQrPayload),
        'This QR code is not for order #2306.',
      );
      expect(
        WorkerOrderPolicy.checkPickupQr(pickup, 'https://example.com'),
        'This QR code is not for order #2306.',
      );
      expect(WorkerOrderPolicy.checkPickupQr(pickup, ''), isNotNull);
    });

    test('a bag label is recognised and explained', () {
      expect(
        WorkerOrderPolicy.checkPickupQr(pickup, pickup.qrPayload),
        "That is a bag label. Scan the QR code on the customer's phone.",
      );
    });
  });

  group('delivery rules', () {
    test('verification waits until the order is ready', () {
      expect(
        WorkerOrderPolicy.checkVerifyCollection(_amir, _order('ord-2303')),
        'This order is still being packed.',
      );
      expect(
        WorkerOrderPolicy.checkVerifyCollection(_amir, _order('ord-2308')),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkVerifyCollection(_amir, _order('ord-2309')),
        'This order has already been collected.',
      );
    });

    test('only the assigned driver can verify', () {
      final order = _order('ord-2308');
      // Branch no longer matters for drivers; assignment does.
      expect(
        WorkerOrderPolicy.checkVerifyCollection(_weiJie, order),
        'This delivery is not assigned to you.',
      );
      expect(
        WorkerOrderPolicy.checkVerifyCollection(_daniel, order),
        'Only Delivery Drivers can deliver orders.',
      );
      expect(
        WorkerOrderPolicy.checkVerifyCollection(_amir, _order('ord-2305')),
        'This is a self-pickup order. It is handed over at the store.',
      );
    });

    test('the code must match the order', () {
      final order = _order('ord-2308');
      const manual = VerificationMethod.manual;
      const qr = VerificationMethod.qr;
      // Manual verification matches the bag's collection code (spaces and
      // letter case ignored), not the order number.
      final code = order.collectionCode;
      expect(
        WorkerOrderPolicy.checkCollectionCode(order, manual, code),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkCollectionCode(
          order,
          manual,
          ' ${code.toLowerCase()} ',
        ),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkCollectionCode(order, manual, 'WRONGXX'),
        isNotNull,
      );
      expect(
        WorkerOrderPolicy.checkCollectionCode(order, qr, order.qrPayload),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkCollectionCode(order, qr, 'grocerly:order:x'),
        isNotNull,
      );
    });

    test('start needs verification by the current driver', () {
      final order = _order('ord-2308');
      expect(
        WorkerOrderPolicy.checkStartDelivery(_amir, order),
        'Verify the order before starting the delivery.',
      );
      final verified = order.copyWith(
        collectionVerification: VerificationMethod.manual,
        collectionVerifiedBy: _amir.id,
      );
      expect(WorkerOrderPolicy.checkStartDelivery(_amir, verified), isNull);

      // Verified by someone else (e.g. a driver who was replaced).
      final verifiedByOther = order.copyWith(collectionVerifiedBy: 'other');
      expect(
        WorkerOrderPolicy.checkStartDelivery(_amir, verifiedByOther),
        isNotNull,
      );
    });

    test('completion needs the delivery to be on its way', () {
      expect(
        WorkerOrderPolicy.checkCompleteDelivery(_amir, _order('ord-2308')),
        'Start the delivery before marking it delivered.',
      );
      expect(
        WorkerOrderPolicy.checkCompleteDelivery(_amir, _order('ord-2309')),
        isNull,
      );
      expect(
        WorkerOrderPolicy.checkCompleteDelivery(_amir, _order('ord-2310')),
        'This delivery is already completed.',
      );
      expect(
        WorkerOrderPolicy.checkCompleteDelivery(_weiJie, _order('ord-2309')),
        isNotNull,
      );
    });
  });
}
