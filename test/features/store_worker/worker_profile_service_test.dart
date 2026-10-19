import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/services/driver_location_service.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/data/services/worker_profile_service.dart';
import 'package:mae_assignment/shared/models/worker_role.dart';

void main() {
  group('WorkerProfile.fromFirestore', () {
    test('reads a packer', () {
      final profile = WorkerProfile.fromFirestore('w1', {
        'name': 'Daniel Lee',
        'email': 'daniel@example.com',
        'phone': '012',
        'role': 'storeWorker',
        'workerRole': 'packingStaff',
        'branchId': 'ss15',
        'isActive': true,
      }, branchName: 'SS15 Subang');

      expect(profile.id, 'w1');
      expect(profile.role, WorkerRole.packingStaff);
      expect(profile.branchId, 'ss15');
      expect(profile.branchName, 'SS15 Subang');
      expect(profile.isActive, isTrue);
    });

    test('a driver has no branch, and an unknown role is a packer', () {
      final driver = WorkerProfile.fromFirestore('w2', {
        'name': 'Amir',
        'workerRole': 'deliveryDriver',
        'branchId': null,
      });
      final unknown = WorkerProfile.fromFirestore('w3', {
        'name': 'X',
        'workerRole': 'boss',
      });

      expect(driver.isDeliveryDriver, isTrue);
      expect(driver.branchId, isNull);
      expect(driver.coverageLabel, 'Cross-branch delivery');
      expect(unknown.role, WorkerRole.packingStaff);
      // A missing flag counts as active, like the staff list does.
      expect(unknown.isActive, isTrue);
    });
  });

  group('WorkerProfileService', () {
    late FakeFirebaseFirestore firestore;
    late WorkerProfileService service;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      service = WorkerProfileService(firestore);
      await firestore.collection('branches').doc('ss15').set({
        'name': 'SS15 Subang',
      });
      await firestore.collection('users').doc('w1').set({
        'name': 'Daniel Lee',
        'role': 'storeWorker',
        'workerRole': 'packingStaff',
        'branchId': 'ss15',
        'isActive': true,
      });
      await firestore.collection('users').doc('w2').set({
        'name': 'Amir Hamzah',
        'role': 'storeWorker',
        'workerRole': 'deliveryDriver',
        'branchId': null,
        'isActive': true,
      });
    });

    test('loads a packer with their branch name', () async {
      final profile = (await service.getProfile('w1'))!;

      expect(profile.name, 'Daniel Lee');
      expect(profile.branchName, 'SS15 Subang');
    });

    test('loads a driver without looking up a branch', () async {
      final profile = (await service.getProfile('w2'))!;

      expect(profile.isDeliveryDriver, isTrue);
      expect(profile.branchName, isNull);
    });

    test('a missing profile is null', () async {
      expect(await service.getProfile('nobody'), isNull);
    });
  });

  group('DriverLocationService', () {
    late FakeFirebaseFirestore firestore;
    late DriverLocationService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = DriverLocationService(firestore);
    });

    test("reads every driver's position by id", () async {
      await firestore.collection('driverLocations').doc('d1').set({
        'position': const GeoPoint(3.07, 101.58),
        'updatedAt': Timestamp.now(),
      });
      // A document without a usable position is left out.
      await firestore.collection('driverLocations').doc('d2').set({
        'updatedAt': Timestamp.now(),
      });

      final locations = await service.watchLocations().first;

      expect(locations.keys, ['d1']);
      expect(locations['d1']!.position, const LatLng(3.07, 101.58));
    });

    test('a driver records their position', () async {
      await service.setLocation(
        'd1',
        const DriverLocation(position: LatLng(3.1, 101.6)),
      );

      final locations = await service.watchLocations().first;
      expect(locations['d1']!.position, const LatLng(3.1, 101.6));
    });
  });
}
