import 'package:latlong2/latlong.dart';

/// One store location. A store admin can look after several branches.
class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.openingHour,
    required this.closingHour,
    required this.location,
  });

  final String id;
  final String name;

  /// Hours on a 24-hour clock, e.g. 8 for 8am and 22 for 10pm.
  final int openingHour;
  final int closingHour;

  /// Where the store is on the map.
  final LatLng location;
}
