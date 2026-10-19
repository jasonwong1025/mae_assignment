import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/location_service.dart';

/// A phone GPS that tests drive by hand: call [move] to send a position, or
/// set [problem] before listening to make the phone refuse.
class FakeLocationService implements LocationService {
  FakeLocationService({this.problem});

  /// When set, listening fails with this problem.
  LocationProblem? problem;

  final StreamController<LatLng> _positions = StreamController<LatLng>();

  /// Sends a new GPS fix.
  void move(LatLng position) => _positions.add(position);

  @override
  Stream<LatLng> watchPosition() async* {
    final reason = problem;
    if (reason != null) throw LocationException(reason);
    yield* _positions.stream;
  }
}
