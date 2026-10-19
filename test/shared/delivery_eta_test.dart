import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/shared/models/delivery_eta.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../helpers/worker_test_store.dart';

void main() {
  final now = DateTime(2026, 10, 16, 15);
  const shop = LatLng(3, 101.5);

  // 0.045 degrees of latitude is about 5 km.
  const fiveKmNorth = LatLng(3.045, 101.5);

  group('DeliveryEta.estimate', () {
    test('stretches the straight line for roads and divides by speed', () {
      final eta = DeliveryEta.estimate(
        from: shop,
        to: fiveKmNorth,
        reportedAt: now,
        now: now,
      );

      // About 5 km straight, 6.5 km by road, at 25 km/h is 15.6 minutes.
      expect(eta.distanceKm, closeTo(6.5, 0.1));
      expect(eta.remaining, const Duration(minutes: 16));
      expect(eta.arrivalAt, now.add(const Duration(minutes: 16)));
    });

    test('never promises less than a minute', () {
      final eta = DeliveryEta.estimate(
        from: shop,
        to: shop,
        reportedAt: now,
        now: now,
      );

      expect(eta.remaining, const Duration(minutes: 1));
    });

    test('counts the arrival from now, not from the old fix', () {
      final eta = DeliveryEta.estimate(
        from: shop,
        to: fiveKmNorth,
        reportedAt: now.subtract(const Duration(minutes: 10)),
        now: now,
      );

      expect(eta.arrivalAt.isAfter(now), isTrue);
      expect(eta.positionAge, const Duration(minutes: 10));
    });

    test('an old position is stale, a fresh one is not', () {
      DeliveryEta at(Duration age) => DeliveryEta.estimate(
        from: shop,
        to: fiveKmNorth,
        reportedAt: now.subtract(age),
        now: now,
      );

      expect(at(const Duration(seconds: 30)).isStale, isFalse);
      expect(at(const Duration(minutes: 2)).isStale, isFalse);
      expect(at(const Duration(minutes: 3)).isStale, isTrue);
    });

    test('a position from the future (clock skew) counts as just now', () {
      final eta = DeliveryEta.estimate(
        from: shop,
        to: fiveKmNorth,
        reportedAt: now.add(const Duration(seconds: 20)),
        now: now,
      );

      expect(eta.positionAge, Duration.zero);
    });
  });

  group('Order.etaAt', () {
    Order onTheRoad({
      OrderStatus status = OrderStatus.outForDelivery,
      bool isDelivery = true,
      LatLng? driverPosition = shop,
      DateTime? driverPositionAt,
      LatLng? addressLocation = fiveKmNorth,
    }) {
      return Order(
        id: 'o1',
        number: 1,
        customerId: 'c',
        customerName: 'C',
        customerPhone: '1',
        branchId: 'b',
        branchName: 'B',
        isDelivery: isDelivery,
        items: const [],
        subtotal: 0,
        deliveryFee: 0,
        discount: 0,
        total: 0,
        status: status,
        driverPosition: driverPosition,
        driverPositionAt: driverPositionAt ?? now,
        addressLocation: addressLocation,
      );
    }

    test('is worked out for a delivery on the road', () {
      expect(onTheRoad().etaAt(now)!.remaining, const Duration(minutes: 16));
    });

    test('is null when something is missing', () {
      expect(onTheRoad(driverPosition: null).etaAt(now), isNull);
      expect(onTheRoad(addressLocation: null).etaAt(now), isNull);
      expect(onTheRoad(isDelivery: false).etaAt(now), isNull);
      expect(onTheRoad(status: OrderStatus.ready).etaAt(now), isNull);
      expect(onTheRoad(status: OrderStatus.completed).etaAt(now), isNull);
    });

    test('is null before the driver has reported a time', () {
      final order = onTheRoad().copyWith(driverPositionAt: null);

      expect(order.etaAt(now), isNull);
    });
  });

  group('OrderService.updateDriverPosition', () {
    late FakeFirebaseFirestore firestore;
    late OrderService service;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      service = OrderService(firestore);
      await putOrders(firestore, [
        Order(
          id: 'o1',
          number: 1,
          customerId: 'c',
          customerName: 'C',
          customerPhone: '1',
          branchId: 'b',
          branchName: 'B',
          isDelivery: true,
          items: const [],
          subtotal: 0,
          deliveryFee: 0,
          discount: 0,
          total: 0,
          status: OrderStatus.outForDelivery,
          driverId: 'd1',
          addressLocation: fiveKmNorth,
          placedAt: now,
          statusSince: now,
        ),
      ]);
    });

    test('saves the position on the order and the driver document', () async {
      await service.updateDriverPosition('o1', 'd1', shop);

      final order = (await service.getOrder('o1'))!;
      expect(order.driverPosition, shop);
      expect(order.driverPositionAt, isNotNull);
      expect(order.etaAt(DateTime.now()), isNotNull);

      final driver = await firestore
          .collection('driverLocations')
          .doc('d1')
          .get();
      expect((driver.data()!['position'] as GeoPoint).latitude, 3);
      expect(driver.data()!['updatedAt'], isNotNull);
    });

    test('a later position replaces the earlier one', () async {
      await service.updateDriverPosition('o1', 'd1', shop);
      await service.updateDriverPosition('o1', 'd1', fiveKmNorth);

      expect((await service.getOrder('o1'))!.driverPosition, fiveKmNorth);
    });

    test('does not touch anything else on the order', () async {
      final before = (await service.getOrder('o1'))!;

      await service.updateDriverPosition('o1', 'd1', shop);

      final after = (await service.getOrder('o1'))!;
      expect(
        after.copyWith(driverPosition: null, driverPositionAt: null),
        before,
      );
    });
  });
}
