import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Opening hours for one day. Times are minutes after midnight,
/// e.g. 8:30am is 510.
class DayHours {
  const DayHours({required this.opensAt, required this.closesAt})
    : isClosed = false;

  const DayHours.closed() : opensAt = 0, closesAt = 0, isClosed = true;

  factory DayHours.fromMap(Map<String, dynamic> map) {
    if (map['isClosed'] == true) return const DayHours.closed();
    return DayHours(
      opensAt: map['opensAt'] as int? ?? 0,
      closesAt: map['closesAt'] as int? ?? 0,
    );
  }

  final int opensAt;
  final int closesAt;

  /// True if the branch does not open on this day.
  final bool isClosed;

  Map<String, dynamic> toMap() {
    return {'opensAt': opensAt, 'closesAt': closesAt, 'isClosed': isClosed};
  }
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

  /// Reads branches/{id}.
  factory Branch.fromMap(String id, Map<String, dynamic> map) {
    final location = map['location'];
    final hours = (map['weeklyHours'] as List<dynamic>?) ?? const [];
    return Branch(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      location: location is GeoPoint
          ? LatLng(location.latitude, location.longitude)
          : const LatLng(0, 0),
      weeklyHours: [
        for (final day in hours) DayHours.fromMap(day as Map<String, dynamic>),
      ],
      maxDeliveryKm: (map['maxDeliveryKm'] as num?)?.toDouble() ?? 0,
      baseDeliveryFee: (map['baseDeliveryFee'] as num?)?.toDouble() ?? 0,
      feePerKm: (map['feePerKm'] as num?)?.toDouble() ?? 0,
      isTemporarilyClosed: map['isTemporarilyClosed'] as bool? ?? false,
    );
  }

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

  /// Fields saved in branches/{id}. The id is the document id.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'location': GeoPoint(location.latitude, location.longitude),
      'weeklyHours': [for (final day in weeklyHours) day.toMap()],
      'maxDeliveryKm': maxDeliveryKm,
      'baseDeliveryFee': baseDeliveryFee,
      'feePerKm': feePerKm,
      'isTemporarilyClosed': isTemporarilyClosed,
    };
  }

  /// Hours on the day of [date].
  DayHours hoursOn(DateTime date) => weeklyHours[date.weekday - 1];

  /// Fee for a road distance of [km], rounded up to whole km.
  /// Null if the branch does not deliver that far.
  double? deliveryFee(double km) {
    if (km > maxDeliveryKm) return null;
    return baseDeliveryFee + km.ceil() * feePerKm;
  }

  /// Copy that is temporarily closed or open again.
  Branch withTemporarilyClosed({required bool closed}) {
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
