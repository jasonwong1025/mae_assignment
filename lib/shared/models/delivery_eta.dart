import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'delivery_eta.freezed.dart';

/// How far a delivery has left to go and when it should arrive, worked out
/// from the driver's last reported position.
///
/// This is an estimate, not a route: straight-line distance, stretched by
/// [detourFactor] because roads are longer than the crow flies, at an average
/// urban [speedKmh] for a motorbike or small van. It needs no routing
/// service (those are third-party and rate-limited), at the cost of being
/// rough. The wording on screen says "about" for that reason.
@freezed
abstract class DeliveryEta with _$DeliveryEta {
  const factory DeliveryEta({
    /// Estimated distance still to drive, in kilometres.
    required double distanceKm,

    /// Estimated time still to drive. Never below one minute.
    required Duration remaining,

    /// When the driver is expected at the door.
    required DateTime arrivalAt,

    /// How long ago the driver's position was reported.
    required Duration positionAge,
  }) = _DeliveryEta;

  const DeliveryEta._();

  /// The estimate for a driver at [from] heading to [to], whose position was
  /// reported at [reportedAt], seen at [now].
  ///
  /// The arrival time counts from [now], not from [reportedAt], so an old
  /// position does not promise an arrival that has already passed.
  factory DeliveryEta.estimate({
    required LatLng from,
    required LatLng to,
    required DateTime reportedAt,
    required DateTime now,
  }) {
    final straightKm = const Distance().as(LengthUnit.Kilometer, from, to);
    final distanceKm = straightKm * detourFactor;
    final minutes = (distanceKm / speedKmh * 60).ceil();
    final remaining = Duration(minutes: minutes < 1 ? 1 : minutes);
    final age = now.difference(reportedAt);
    return DeliveryEta(
      distanceKm: distanceKm,
      remaining: remaining,
      arrivalAt: now.add(remaining),
      positionAge: age.isNegative ? Duration.zero : age,
    );
  }

  /// Roads are longer than a straight line.
  static const double detourFactor = 1.3;

  /// Average speed through town, including junctions and traffic.
  static const double speedKmh = 25;

  /// A position older than this is shown as out of date.
  static const Duration staleAfter = Duration(minutes: 2);

  /// True when the last position is old enough that the driver may have
  /// moved on (phone off, no signal).
  bool get isStale => positionAge > staleAfter;
}
