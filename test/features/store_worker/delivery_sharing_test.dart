import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/location_service.dart';

import '../../helpers/fake_location_service.dart';
import '../../helpers/worker_test_app.dart';
import '../../helpers/worker_test_store.dart';

/// The delivery screen shares the driver's position while the order is on
/// the road. Order #2309 is out for delivery, assigned to Amir.
void main() {
  // About 5 km south of the customer's pin (3.045, 101.5).
  const driver = LatLng(3, 101.5);

  Future<WorkerTestStore> storeWithCustomerPin() async {
    final store = await WorkerTestStore.create();
    await store.firestore.collection('orders').doc('ord-2309').update({
      'addressLocation': const GeoPoint(3.045, 101.5),
    });
    return store;
  }

  testWidgets('shows that the location is being shared', (tester) async {
    final store = await storeWithCustomerPin();
    await pumpWorkerApp(
      tester,
      'Amir Hamzah',
      location: AppRoutes.workerDeliveryOrder('ord-2309'),
      store: store,
    );

    expect(
      find.text('Sharing your location with the customer.'),
      findsOneWidget,
    );
  });

  testWidgets('a GPS fix is saved and gives the driver an arrival time', (
    tester,
  ) async {
    final store = await storeWithCustomerPin();
    final gps = FakeLocationService();
    await pumpWorkerApp(
      tester,
      'Amir Hamzah',
      location: AppRoutes.workerDeliveryOrder('ord-2309'),
      store: store,
      gps: gps,
    );

    gps.move(driver);
    await tester.pumpAndSettle();

    final saved = (await store.read('ord-2309'))!;
    expect(saved.driverPosition, driver);
    expect(find.textContaining('About 16m to the customer'), findsOneWidget);
  });

  testWidgets('explains what to switch on when location is refused', (
    tester,
  ) async {
    await pumpWorkerApp(
      tester,
      'Amir Hamzah',
      location: AppRoutes.workerDeliveryOrder('ord-2309'),
      gps: FakeLocationService(problem: LocationProblem.serviceOff),
    );

    expect(
      find.text('Turn on location so the customer can follow the delivery.'),
      findsOneWidget,
    );
  });

  testWidgets('nothing is shared before the delivery starts', (tester) async {
    final gps = FakeLocationService();
    await pumpWorkerApp(
      tester,
      'Amir Hamzah',
      // #1182 is still being packed, assigned to Amir.
      location: AppRoutes.workerDeliveryOrder('ord-1182'),
      gps: gps,
    );

    expect(find.textContaining('Sharing your location'), findsNothing);
  });
}
