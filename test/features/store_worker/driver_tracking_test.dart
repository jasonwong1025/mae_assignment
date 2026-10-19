import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/repositories/driver_tracking_repository.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/location_service.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/view_models/driver_tracking_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';

import '../../helpers/fake_location_service.dart';
import '../../helpers/worker_profiles.dart';
import '../../helpers/worker_test_store.dart';

/// Sharing the driver's position: the repository, and the view model that
/// decides which GPS fixes are saved.
void main() {
  // ord-2309 is out for delivery and assigned to Amir.
  const orderId = 'ord-2309';
  const start = LatLng(3, 101.5);
  // About 55 m from [start].
  const moved = LatLng(3.0005, 101.5);

  late WorkerTestStore store;
  late FakeLocationService gps;
  late DateTime now;
  late void Function() tickHeartbeat;
  late ProviderContainer container;

  Future<LatLng?> savedPosition() async =>
      (await store.read(orderId))!.driverPosition;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// Starts sharing, as the delivery screen does while the order is on the
  /// road.
  Future<void> startSharing() async {
    container.listen(driverTrackingViewModelProvider(orderId), (_, _) {});
    await settle();
  }

  setUp(() async {
    store = await WorkerTestStore.create();
    gps = FakeLocationService();
    now = DateTime(2026, 10, 16, 15);
    tickHeartbeat = () {};
    container = ProviderContainer(
      overrides: [
        driverTrackingRepositoryProvider.overrideWithValue(
          DriverTrackingRepository(gps, store.service),
        ),
        trackingClockProvider.overrideWithValue(() => now),
        trackingTimerProvider.overrideWithValue((every, tick) {
          tickHeartbeat = tick;
          return null;
        }),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(workerSessionProvider.notifier)
        .open(testWorker('Amir Hamzah'));
  });

  group('driver tracking', () {
    test('the first fix is saved on the order', () async {
      await startSharing();

      gps.move(start);
      await settle();

      expect(await savedPosition(), start);
      expect(
        container.read(driverTrackingViewModelProvider(orderId)).isSharing,
        isTrue,
      );
    });

    test('a quick second fix is not saved, a later one is', () async {
      await startSharing();
      gps.move(start);
      await settle();

      now = now.add(const Duration(seconds: 3));
      gps.move(moved);
      await settle();
      expect(await savedPosition(), start);

      now = now.add(const Duration(seconds: 15));
      gps.move(moved);
      await settle();
      expect(await savedPosition(), moved);
    });

    test('a driver who is standing still is saved at the heartbeat', () async {
      await startSharing();
      gps.move(start);
      await settle();
      // Wipe the saved position, so a new save is easy to spot.
      await store.firestore.collection('orders').doc(orderId).update({
        'driverPosition': FieldValue.delete(),
      });
      expect(await savedPosition(), isNull);

      now = now.add(const Duration(seconds: 10));
      tickHeartbeat();
      await settle();
      expect(await savedPosition(), isNull, reason: 'too soon to repeat');

      now = now.add(const Duration(seconds: 25));
      tickHeartbeat();
      await settle();
      expect(await savedPosition(), start);
    });

    test('also updates the driver document used by Dispatch', () async {
      await startSharing();

      gps.move(start);
      await settle();

      final driver = await store.firestore
          .collection('driverLocations')
          .doc('mock-amir')
          .get();
      expect(driver.exists, isTrue);
    });

    test('a refused permission is reported with what to do', () async {
      gps.problem = LocationProblem.denied;

      await startSharing();

      expect(
        container.read(driverTrackingViewModelProvider(orderId)).error,
        'Allow location access so the customer can follow the delivery.',
      );
      expect(await savedPosition(), isNull);
    });

    test('location switched off and blocked permission have their own '
        'messages', () async {
      final repository = DriverTrackingRepository(
        FakeLocationService(problem: LocationProblem.serviceOff),
        store.service,
      );
      final blocked = DriverTrackingRepository(
        FakeLocationService(problem: LocationProblem.deniedForever),
        store.service,
      );

      expect(
        repository.watchPosition().first,
        throwsA(
          isA<TrackingException>().having(
            (e) => e.message,
            'message',
            'Turn on location so the customer can follow the delivery.',
          ),
        ),
      );
      expect(
        blocked.watchPosition().first,
        throwsA(
          isA<TrackingException>().having(
            (e) => e.message,
            'message',
            'Location access is blocked. Allow it for Grocerly in Settings.',
          ),
        ),
      );
    });

    test('a failed save gives a friendly message', () async {
      final repository = DriverTrackingRepository(gps, store.service);
      // The order does not exist, so saving the position fails.
      expect(
        repository.publish('missing-order', 'mock-amir', start),
        throwsA(
          isA<TrackingException>().having(
            (e) => e.message,
            'message',
            'Could not share your location. Check your connection.',
          ),
        ),
      );
    });

    test('nothing is shared when no worker is signed in', () async {
      container.read(workerSessionProvider.notifier).exit();

      await startSharing();
      gps.move(start);
      await settle();

      expect(await savedPosition(), isNull);
    });
  });
}
