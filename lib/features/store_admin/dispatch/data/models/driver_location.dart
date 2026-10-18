import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'driver_location.freezed.dart';

/// Where a driver is now and the stops still ahead of them.
@freezed
abstract class DriverLocation with _$DriverLocation {
  const factory DriverLocation({
    required LatLng position,

    /// Places still to visit, in order. Empty if the driver has no trip.
    @Default(<LatLng>[]) List<LatLng> stops,
  }) = _DriverLocation;

  const DriverLocation._();
}
