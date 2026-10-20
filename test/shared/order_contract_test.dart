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

    test('new orders use the server-issued collection code', () {
      final order = base().copyWith(collectionToken: 'ACDE3479');
      expect(order.collectionCode, 'ACDE3479');
      expect(order.toFirestore()[OrderFields.collectionCode], 'ACDE3479');
      expect(order.qrPayload, 'grocerly:order:o1:ACDE3479');
    });

    test("the customer's pickup QR differs from the bag label's", () {
      final order = base(isDelivery: false);

      expect(
        order.handoverQrPayload,
        'grocerly:handover:o1:${order.collectionCode}',
      );
      expect(order.handoverQrPayload, isNot(order.qrPayload));
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

  group('shortages', () {
    const milkReplacement = OrderItem(
      lineId: 'L1',
      productId: 'p-oat',
      name: 'Oat milk',
      brand: 'Oatside',
      packSize: '1L',
      quantity: 2,
      unitPrice: 9,
      category: 'Dairy & Eggs',
    );

    Order withShortages(Map<String, LineShortage> shortages) {
      return base().copyWith(shortages: shortages);
    }

    test('an order without shortages is unchanged', () {
      final order = base();

      expect(order.effectiveItems, lines);
      expect(order.adjustedTotal, order.total);
      expect(order.adjustment, 0);
      expect(order.hasOpenShortage, isFalse);
      expect(order.lineCount, 2);
    });

    test('a proposal changes nothing until the customer decides', () {
      final order = withShortages({
        'L1': LineShortage(
          status: ShortageStatus.proposed,
          replacement: milkReplacement,
          flaggedAt: at(5),
        ),
      });

      expect(order.openShortageCount, 1);
      expect(order.hasOpenShortage, isTrue);
      expect(order.effectiveItems, lines);
      expect(order.adjustedTotal, 26);
      // It also stops the order counting as fully packed.
      expect(
        order.copyWith(packedLineIds: {'L1', 'L2'}).isFullyPacked,
        isFalse,
      );
    });

    test('an accepted replacement stands in for the line', () {
      final order = withShortages({
        'L1': LineShortage(
          status: ShortageStatus.accepted,
          replacement: milkReplacement,
          flaggedAt: at(5),
          decidedAt: at(8),
        ),
      });

      expect(order.effectiveItems.first, milkReplacement);
      // 2 x 9 + 1 x 7 + 3 delivery = 28 instead of 26.
      expect(order.adjustedSubtotal, 25);
      expect(order.adjustedTotal, 28);
      expect(order.adjustment, 2);
      expect(order.hasOpenShortage, isFalse);
    });

    test('a removed line leaves the order and the total is refunded', () {
      final order = withShortages({
        'L1': LineShortage(
          status: ShortageStatus.removed,
          flaggedAt: at(5),
          decidedAt: at(8),
        ),
      });

      expect(order.effectiveItems.map((item) => item.lineId), ['L2']);
      expect(order.adjustedSubtotal, 7);
      expect(order.adjustedTotal, 10);
      expect(order.adjustment, -16);
      expect(order.removedLineIds, {'L1'});
      expect(order.lineCount, 1);
      expect(order.itemCount, 1);
    });

    test('a removed line is not packed, and the rest decide if packed', () {
      final order = withShortages({
        'L1': const LineShortage(status: ShortageStatus.removed),
      }).copyWith(packedLineIds: {'L1', 'L2'});

      expect(order.isPacked('L1'), isFalse);
      expect(order.isPacked('L2'), isTrue);
      expect(order.packedLineCount, 1);
      expect(order.isFullyPacked, isTrue);
      expect(order.packingProgress, 1);
    });

    test('the discount never exceeds the new subtotal', () {
      final order = base()
          .copyWith(discount: 10, total: 16)
          .copyWith(
            shortages: {
              'L1': const LineShortage(status: ShortageStatus.removed),
            },
          );

      // Subtotal falls to 7, so only 7 of the 10 discount applies.
      expect(order.adjustedTotal, 3);
    });

    test('everything removed leaves just the delivery fee', () {
      final order = withShortages({
        'L1': const LineShortage(status: ShortageStatus.removed),
        'L2': const LineShortage(status: ShortageStatus.removed),
      });

      expect(order.adjustedSubtotal, 0);
      expect(order.adjustedTotal, 3);
      expect(order.lineCount, 0);
    });

    test('round-trips through Firestore with the replacement', () {
      final order = withShortages({
        'L1': LineShortage(
          status: ShortageStatus.proposed,
          replacement: milkReplacement,
          flaggedAt: at(5),
        ),
        'L2': LineShortage(
          status: ShortageStatus.removed,
          flaggedAt: at(6),
          decidedAt: at(9),
        ),
      });
      final map = order.toFirestore();
      map[OrderFields.placedAt] = Timestamp.fromDate(placed);
      map[OrderFields.statusSince] = Timestamp.fromDate(placed);

      expect(Order.fromFirestore('o1', map), order);
      expect(
        (map[OrderFields.shortages]! as Map).keys,
        containsAll(['L1', 'L2']),
      );
    });

    test('an order without shortages does not write the field', () {
      expect(base().toFirestore().containsKey(OrderFields.shortages), isFalse);
    });

    test('an unknown status reads as proposed, not removed', () {
      final shortage = LineShortage.fromMap({ShortageFields.status: 'weird'});

      expect(shortage.status, ShortageStatus.proposed);
    });

    test("the timeline notes the shortage and the customer's decision", () {
      final order = withShortages({
        'L1': LineShortage(
          status: ShortageStatus.accepted,
          replacement: milkReplacement,
          flaggedAt: at(5),
          decidedAt: at(8),
        ),
      }).copyWith(packerName: 'Daniel Lee');

      final titles = [for (final event in order.timeline) event.title];
      expect(titles, [
        'Order placed',
        'Milk unavailable',
        'Replacement for Milk accepted',
      ]);
      expect(order.timeline[1].by, 'Daniel Lee');
      expect(order.timeline[2].by, isNull);
    });
  });
}
