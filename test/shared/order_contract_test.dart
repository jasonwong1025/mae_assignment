import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';

/// The one order contract shared by the customer, admin and worker apps.
void main() {
  final placed = DateTime(2026, 1, 1, 12);
  DateTime at(int minutes) => placed.add(Duration(minutes: minutes));

  const lines = [
    OrderItem(
      lineId: 'L1',
      productId: 'p1',
      name: 'Milk',
      brand: 'Farm',
      packSize: '1L',
      quantity: 2,
      unitPrice: 8,
      categoryId: 'dairy',
      category: 'Dairy & Eggs',
      description: 'Fresh',
    ),
    OrderItem(
      lineId: 'L2',
      productId: 'p2',
      name: 'Eggs',
      brand: 'Farm',
      packSize: '10',
      quantity: 1,
      unitPrice: 7,
    ),
  ];

  Order base({
    bool isDelivery = true,
    OrderStatus status = OrderStatus.pending,
  }) {
    return Order(
      id: 'o1',
      number: 2301,
      customerId: 'u1',
      customerName: 'Aisha',
      customerPhone: '012',
      branchId: 'ss15',
      branchName: 'SS15',
      branchAddress: '18 Jalan SS15',
      isDelivery: isDelivery,
      items: lines,
      subtotal: 23,
      deliveryFee: 3,
      discount: 0,
      total: 26,
      status: status,
      placedAt: placed,
      statusSince: placed,
    );
  }

  group('persistence', () {
    test('a fresh checkout document holds only checkout fields', () {
      final map = base().toFirestore();
      expect(
        map.keys.toSet().difference({
          ...OrderFields.checkoutKeys,
          OrderFields.status,
        }),
        isEmpty,
      );
    });

    test('a fully fulfilled order round-trips through Firestore', () {
      final full = base().copyWith(
        status: OrderStatus.completed,
        addressLocation: const LatLng(3, 101),
        dueAt: at(60),
        packerId: 'w1',
        packerName: 'Daniel Lee',
        packerAssignedAt: at(1),
        driverId: 'w2',
        driverName: 'Amir Hamzah',
        driverAssignedAt: at(2),
        packedLineIds: {'L1', 'L2'},
        packingStartedAt: at(3),
        readyAt: at(10),
        readyBy: 'w1',
        pickupVerification: VerificationMethod.manual,
        pickupCompletedBy: 'w1',
        pickupCompletedByName: 'Daniel Lee',
        collectionVerification: VerificationMethod.qr,
        collectionVerifiedBy: 'w2',
        collectionVerifiedAt: at(12),
        outForDeliveryAt: at(13),
        deliveredBy: 'w2',
        deliveredByName: 'Amir Hamzah',
        proofPhotoUrl: 'https://img/proof.jpg',
        completedAt: at(30),
      );
      final map = full.toFirestore();
      expect(map[OrderFields.completedAt], isA<Timestamp>());

      // placedAt / statusSince are written by the service, so add them as
      // the server would.
      map[OrderFields.placedAt] = Timestamp.fromDate(placed);
      map[OrderFields.statusSince] = Timestamp.fromDate(placed);
      expect(Order.fromFirestore('o1', map), full);
    });

    test('every key belongs to exactly one write group', () {
      final groups = [
        OrderFields.checkoutKeys,
        OrderFields.assignmentKeys,
        OrderFields.fulfilmentKeys,
      ];
      final all = groups.expand((keys) => keys).toList();
      expect(all.toSet(), hasLength(all.length));
    });

    test('order lines keep category and description', () {
      final item = OrderItem.fromMap(lines.first.toMap());
      expect(item, lines.first);
      expect(lines.last.toMap().containsKey(OrderItemFields.category), isFalse);
    });
  });

  group('derived values', () {
    test('packing progress follows the checklist', () {
      final order = base().copyWith(packedLineIds: {'L1'});
      expect(order.packedLineCount, 1);
      expect(order.packingProgress, 0.5);
      expect(order.isFullyPacked, isFalse);
      expect(order.itemCount, 3);
    });

    test('collection code is stable and six characters', () {
      expect(base().collectionCode, base().collectionCode);
      expect(base().collectionCode, hasLength(6));
      expect(base().qrPayload, 'grocerly:order:o1:${base().collectionCode}');
    });

    test('minutesInStatus falls back when server times are missing', () {
      final now = at(30);
      expect(base().minutesInStatus(now), 30);
      expect(base().copyWith(statusSince: null).minutesInStatus(now), 30);
      expect(
        base().copyWith(statusSince: null, placedAt: null).minutesInStatus(now),
        0,
      );
    });

    test('handledBy is the packer, then the driver once assigned', () {
      final packed = base().copyWith(packerName: 'Daniel Lee');
      expect(packed.handledBy, 'Daniel');
      expect(base().handledBy, isNull);
      final withDriver = packed.withDriver(
        driverId: 'w9',
        driverName: 'Kumar',
        now: at(5),
      );
      expect(withDriver.handledBy, 'Kumar');
      expect(withDriver.driverAssignedAt, at(5));
    });

    test('timeline is worked out from the timestamps, oldest first', () {
      final order = base()
          .copyWith(
            status: OrderStatus.ready,
            packerName: 'Daniel Lee',
            packingStartedAt: at(3),
            readyAt: at(10),
          )
          .withDriver(driverId: 'w9', driverName: 'Kumar', now: at(12));
      expect(
        [for (final event in order.timeline) event.title],
        [
          'Order placed',
          'Packing started',
          'Ready for delivery',
          'Driver Kumar assigned',
        ],
      );
      expect(order.timeline.last.by, 'Admin');
      expect(order.timeline[1].by, 'Daniel Lee');
    });

    test('a cancelled order ends with Cancelled', () {
      final order = base().copyWith(
        status: OrderStatus.cancelled,
        statusSince: at(4),
      );
      expect(order.timeline.last.title, 'Cancelled');
    });
  });
}
