import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/location_service.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final driverTrackingRepositoryProvider = Provider<DriverTrackingRepository>((
  ref,
) {
  return DriverTrackingRepository(
    ref.watch(locationServiceProvider),
    ref.watch(orderServiceProvider),
  );
});

/// Error with a message that is safe to show on screen.
class TrackingException extends AppException {
  const TrackingException(super.message);
}

/// Shares the driver's position while a delivery is on the road: reads the
/// phone's GPS and saves the fixes on the order, where its customer and the
/// admin's Dispatch map can see them.
class DriverTrackingRepository {
  DriverTrackingRepository(this._location, this._orders);

  final LocationService _location;
  final OrderService _orders;

  /// The phone's position as it changes. Fails with a [TrackingException]
  /// whose message tells the driver what to switch on.
  Stream<LatLng> watchPosition() {
    return _location.watchPosition().handleError((Object error) {
      if (error is LocationException) {
        throw TrackingException(switch (error.problem) {
          LocationProblem.serviceOff =>
            'Turn on location so the customer can follow the delivery.',
          LocationProblem.denied =>
            'Allow location access so the customer can follow the delivery.',
          LocationProblem.deniedForever =>
            'Location access is blocked. Allow it for Grocerly in Settings.',
        });
      }
      throw const TrackingException(
        'Your location could not be read. Please try again.',
      );
    });
  }

  /// Saves the driver's [position] on [orderId].
  Future<void> publish(String orderId, String driverId, LatLng position) {
    return guard(
      () => _orders.updateDriverPosition(orderId, driverId, position),
      label: 'share position (orders/$orderId)',
      onError: () => const TrackingException(
        'Could not share your location. Check your connection.',
      ),
    );
  }
}
