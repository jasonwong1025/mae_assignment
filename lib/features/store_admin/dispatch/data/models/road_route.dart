import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'road_route.freezed.dart';

/// A route along the roads, from the routing service.
@freezed
abstract class RoadRoute with _$RoadRoute {
  const factory RoadRoute({
    /// The line to draw on the map.
    required List<LatLng> points,

    /// Distance along the roads.
    required double metres,

    /// Driving time, without traffic.
    required double seconds,
  }) = _RoadRoute;

  const RoadRoute._();

  int get minutes => (seconds / 60).ceil();
}
