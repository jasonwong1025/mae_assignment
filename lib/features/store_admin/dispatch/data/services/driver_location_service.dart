import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';

final Provider<DriverLocationService> driverLocationServiceProvider =
    Provider<DriverLocationService>(
      (ref) => DriverLocationService(ref.watch(firebaseFirestoreProvider)),
    );

/// Reads where drivers are, from driverLocations/{driverId}. Each driver's
/// own app writes its document; Dispatch only reads them.
class DriverLocationService {
  DriverLocationService(FirebaseFirestore firestore)
    : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// Every driver's last known position, by driver id. Sends again whenever
  /// any driver moves. A driver with no document shares no location.
  Stream<Map<String, DriverLocation>> watchLocations() {
    return _refs.driverLocations.snapshots().map((snapshot) {
      return {
        for (final doc in snapshot.docs)
          if (doc.data().latLng(DriverLocationFields.position)
              case final position?)
            doc.id: DriverLocation(position: position),
      };
    });
  }

  /// Records a driver's position. Used by the driver's own app.
  Future<void> setLocation(String driverId, DriverLocation location) {
    return _refs
        .driverLocation(driverId)
        .set({
          DriverLocationFields.position: toGeoPoint(location.position),
          DriverLocationFields.updatedAt: FieldValue.serverTimestamp(),
        })
        .timeout(FirestoreConfig.readTimeout);
  }
}
