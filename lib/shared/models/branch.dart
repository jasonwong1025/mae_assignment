import 'package:latlong2/latlong.dart';

/// Opening hours for one day. Times are minutes after midnight,
/// e.g. 8:30am is 510.
class DayHours {
  const DayHours({required this.opensAt, required this.closesAt})
    : isClosed = false;

  const DayHours.closed() : opensAt = 0, closesAt = 0, isClosed = true;

  final int opensAt;
  final int closesAt;

  /// True if the branch does not open on this day.
  final bool isClosed;
}

/// One store location of the retailer.
class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.location,
    required this.weeklyHours,
    required this.maxDeliveryKm,
    required this.baseDeliveryFee,
    required this.feePerKm,
    this.isTemporarilyClosed = false,
  });

  final String id;
  final String name;
  final String address;
  final String phone;

  /// Where the store is on the map.
  final LatLng location;

  /// Hours for Monday to Sunday (7 items, Monday first).
  final List<DayHours> weeklyHours;

  /// Furthest road distance the branch delivers to.
  final double maxDeliveryKm;

  /// Delivery fee = base fee + fee per km (road distance), in ringgit.
  final double baseDeliveryFee;
  final double feePerKm;

  /// True if customers cannot place new orders here for now.
  final bool isTemporarilyClosed;

  /// Hours on the day of [date].
  DayHours hoursOn(DateTime date) => weeklyHours[date.weekday - 1];

  /// Fee for a road distance of [km], rounded up to whole km.
  /// Null if the branch does not deliver that far.
  double? deliveryFee(double km) {
    if (km > maxDeliveryKm) return null;
    return baseDeliveryFee + km.ceil() * feePerKm;
  }

  /// Copy that is temporarily closed or open again.
  Branch withTemporarilyClosed(bool closed) {
    return Branch(
      id: id,
      name: name,
      address: address,
      phone: phone,
      location: location,
      weeklyHours: weeklyHours,
      maxDeliveryKm: maxDeliveryKm,
      baseDeliveryFee: baseDeliveryFee,
      feePerKm: feePerKm,
      isTemporarilyClosed: closed,
    );
  }
}
