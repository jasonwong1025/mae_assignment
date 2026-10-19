import 'package:latlong2/latlong.dart';

/// Decides when a driver's position is worth saving, so a delivery makes a
/// few writes a minute and not one per GPS fix.
///
/// Plain code with no Flutter or Firebase, so it is easy to test.
class PositionThrottle {
  PositionThrottle({
    this.minDistanceMeters = 30,
    this.minInterval = const Duration(seconds: 10),
    this.heartbeat = const Duration(seconds: 30),
  });

  /// A fix closer than this to the last saved one is not news.
  final double minDistanceMeters;

  /// Never save more often than this.
  final Duration minInterval;

  /// Save at least this often even if the driver has not moved (stuck in
  /// traffic), so the customer can tell the phone is still sharing.
  final Duration heartbeat;

  LatLng? _lastPosition;
  DateTime? _lastSavedAt;

  /// True if [position], seen at [now], should be saved. Call [saved]
  /// afterwards.
  bool shouldSave(LatLng position, DateTime now) {
    final lastPosition = _lastPosition;
    final lastSavedAt = _lastSavedAt;
    if (lastPosition == null || lastSavedAt == null) return true;
    final waited = now.difference(lastSavedAt);
    if (waited >= heartbeat) return true;
    if (waited < minInterval) return false;
    final moved = const Distance().as(LengthUnit.Meter, lastPosition, position);
    return moved >= minDistanceMeters;
  }

  /// Remembers that [position] was saved at [now].
  void saved(LatLng position, DateTime now) {
    _lastPosition = position;
    _lastSavedAt = now;
  }
}
