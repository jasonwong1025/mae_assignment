import 'package:latlong2/latlong.dart';

import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';

/// Sample positions of the on-duty drivers, by worker id.
/// Off-duty drivers share no location.
// TODO(team): delete once drivers send their GPS position.
Map<String, DriverLocation> sampleDriverLocations() {
  return {
    // Heading to #2290 (SS19).
    'w7': const DriverLocation(
      position: LatLng(3.0752, 101.5800),
      stops: [LatLng(3.0745, 101.5745)],
    ),
    // Heading to #2285 (USJ 21).
    'w8': const DriverLocation(
      position: LatLng(3.0400, 101.5860),
      stops: [LatLng(3.0310, 101.5840)],
    ),
    // Heading to #1178 (Bukit Jalil).
    'w9': const DriverLocation(
      position: LatLng(3.0600, 101.6810),
      stops: [LatLng(3.0620, 101.6730)],
    ),

    // Free drivers.
    'w10': const DriverLocation(position: LatLng(3.0690, 101.5990)),
    'w25': const DriverLocation(position: LatLng(3.0820, 101.6050)),
    'w26': const DriverLocation(position: LatLng(3.0550, 101.6350)),
    'w27': const DriverLocation(position: LatLng(3.0450, 101.6150)),
    'w28': const DriverLocation(position: LatLng(3.0650, 101.6600)),
    'w29': const DriverLocation(position: LatLng(3.0300, 101.6050)),
    'w30': const DriverLocation(position: LatLng(3.0880, 101.5750)),
    'w31': const DriverLocation(position: LatLng(3.0500, 101.7000)),
    'w32': const DriverLocation(position: LatLng(3.0150, 101.6250)),
  };
}
