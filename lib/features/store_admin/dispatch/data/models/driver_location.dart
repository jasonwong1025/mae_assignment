import 'package:latlong2/latlong.dart';

/// Where a driver is now and the stops still ahead of them.
class DriverLocation {
  const DriverLocation({required this.position, this.stops = const []});

  final LatLng position;

  /// Places still to visit, in order. Empty if the driver has no trip.
  final List<LatLng> stops;
}
