import 'dart:async';

import 'package:latlong2/latlong.dart';

import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/sample_driver_locations.dart';

/// Live driver positions.
/// No GPS yet: every 2 seconds each driver moves a little toward their
/// next stop, so the map looks live.
// TODO(team): read the positions the driver app writes to Firestore.
class DriverLocationService {
  DriverLocationService() {
    // Only move drivers while someone is watching.
    _changes = StreamController.broadcast(onListen: _start, onCancel: _stop);
  }

  static const _tick = Duration(seconds: 2);

  /// About 54 km/h.
  static const _metresPerTick = 30.0;

  static const _distance = Distance();

  final Map<String, DriverLocation> _locations = sampleDriverLocations();
  late final StreamController<Map<String, DriverLocation>> _changes;
  Timer? _timer;

  /// Every driver's location, by worker id. Sends again on every move.
  Stream<Map<String, DriverLocation>> watchLocations() async* {
    yield Map.unmodifiable(_locations);
    yield* _changes.stream;
  }

  /// Gives a driver new stops. An empty list ends their trip.
  // TODO(team): ask a routing service (e.g. OpenRouteService) for the road
  // route.
  void setStops(String driverId, List<LatLng> stops) {
    final location = _locations[driverId];
    if (location == null) return;

    _locations[driverId] = DriverLocation(
      position: location.position,
      stops: stops,
    );
    _send();
  }

  void _start() {
    _timer ??= Timer.periodic(_tick, (_) => _moveDrivers());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _moveDrivers() {
    var moved = false;

    _locations.updateAll((driverId, location) {
      if (location.stops.isEmpty) return location;
      moved = true;

      final next = location.stops.first;
      final metresLeft = _distance(location.position, next);

      // Close enough: arrive at the stop.
      if (metresLeft <= _metresPerTick) {
        return DriverLocation(
          position: next,
          stops: location.stops.skip(1).toList(),
        );
      }

      final bearing = _distance.bearing(location.position, next);
      return DriverLocation(
        position: _distance.offset(location.position, _metresPerTick, bearing),
        stops: location.stops,
      );
    });

    if (moved) _send();
  }

  void _send() {
    if (!_changes.isClosed) _changes.add(Map.unmodifiable(_locations));
  }

  void dispose() {
    _stop();
    unawaited(_changes.close());
  }
}
