import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Typed reading of one Firestore document (or nested map), used by every
/// model's `fromFirestore` / `fromMap`.
///
/// Firestore hands back `Map<String, dynamic>` holding SDK types
/// (`Timestamp`, `GeoPoint`), so each field needs a safe cast. These readers
/// keep that in one place:
///
/// - Plain readers (`string`, `integer`, ...) fall back to a default when the
///   field is missing or has the wrong type, so an older document still loads.
/// - `required...` readers throw a [FormatException] instead, so a document
///   that cannot be used is skipped by `toModel`/`toModels` rather than shown
///   half empty.
///
/// Always pass the constants from `firestore_paths.dart` as keys.
extension FieldReaders on Map<String, dynamic> {
  String string(String key, {String fallback = ''}) {
    final value = this[key];
    return value is String ? value : fallback;
  }

  String? stringOrNull(String key) {
    final value = this[key];
    return value is String ? value : null;
  }

  String requiredString(String key) {
    final value = this[key];
    if (value is String) return value;
    throw FormatException('Missing text field "$key"');
  }

  int integer(String key, {int fallback = 0}) {
    final value = this[key];
    return value is num ? value.toInt() : fallback;
  }

  int requiredInteger(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    throw FormatException('Missing number field "$key"');
  }

  double decimal(String key, {double fallback = 0}) {
    final value = this[key];
    return value is num ? value.toDouble() : fallback;
  }

  double requiredDecimal(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    throw FormatException('Missing number field "$key"');
  }

  bool boolean(String key, {required bool fallback}) {
    final value = this[key];
    return value is bool ? value : fallback;
  }

  /// A `Timestamp` as a `DateTime`, or null (for example while the server
  /// time is still being saved).
  DateTime? dateTime(String key) {
    final value = this[key];
    return value is Timestamp ? value.toDate() : null;
  }

  /// A `GeoPoint` as a `LatLng`, or null.
  LatLng? latLng(String key) {
    final value = this[key];
    return value is GeoPoint ? LatLng(value.latitude, value.longitude) : null;
  }

  LatLng requiredLatLng(String key) {
    return latLng(key) ?? (throw FormatException('Missing location "$key"'));
  }

  /// An enum saved by name. An unknown or missing value reads as [fallback],
  /// so choose the safest case (for example the role with the fewest
  /// permissions).
  E enumValue<E extends Enum>(
    String key,
    List<E> values, {
    required E fallback,
  }) {
    final value = this[key];
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    return fallback;
  }

  /// An array of maps (for example order items). Entries that are not maps
  /// are skipped.
  List<Map<String, dynamic>> maps(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  /// An array of non-empty strings (for example image URLs).
  List<String> strings(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is String && item.isNotEmpty) item,
    ];
  }
}

/// A `LatLng` as the `GeoPoint` Firestore stores.
GeoPoint toGeoPoint(LatLng location) {
  return GeoPoint(location.latitude, location.longitude);
}
