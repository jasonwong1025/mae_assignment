import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Why the phone cannot give a position.
enum LocationProblem {
  /// Location is switched off on the phone.
  serviceOff,

  /// The driver said no to the permission prompt.
  denied,

  /// The driver said no and chose "don't ask again"; only Settings can fix it.
  deniedForever,
}

/// Thrown by [LocationService] when it cannot get a position. A repository
/// turns it into a message for the screen.
class LocationException implements Exception {
  const LocationException(this.problem);

  final LocationProblem problem;

  @override
  String toString() => 'LocationException($problem)';
}

/// Wrapper around the geolocator package: the phone's GPS.
class LocationService {
  /// Stream of the phone's position while someone listens. Asks for the
  /// location permission first. Fails with a [LocationException] when the
  /// phone cannot share a position.
  ///
  /// A new position is sent after the phone has moved about 25 metres, to
  /// save battery and writes.
  Stream<LatLng> watchPosition() async* {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationProblem.serviceOff);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        throw const LocationException(LocationProblem.denied);
      case LocationPermission.deniedForever:
        throw const LocationException(LocationProblem.deniedForever);
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        break;
    }
    // The first fix straight away, so the customer sees the driver without
    // waiting for the phone to move.
    final first = await Geolocator.getCurrentPosition();
    yield LatLng(first.latitude, first.longitude);
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 25),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }
}
