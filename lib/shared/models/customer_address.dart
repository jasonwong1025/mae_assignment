import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'customer_address.freezed.dart';

/// A customer's saved delivery address, stored at
/// users/{uid}/addresses/{addressId}. Carries both the readable [line]
/// (what shows on the order and the map search) and the [location] pin, so
/// the delivery fee can be worked out by distance and a driver can navigate.
@freezed
abstract class CustomerAddress with _$CustomerAddress {
  const factory CustomerAddress({
    required String id,

    /// Short name, e.g. "Home" or "Office".
    required String label,

    /// Full address as readable text.
    required String line,

    /// Where to deliver.
    required LatLng location,
    @Default('') String note,

    /// The one address pre-selected at checkout.
    @Default(false) bool isDefault,

    /// Null until Firestore has saved the server time.
    DateTime? createdAt,
  }) = _CustomerAddress;

  const CustomerAddress._();

  /// Reads users/{uid}/addresses/{id}. Returns null when required fields are
  /// missing, so a malformed document is skipped rather than crashing a list.
  static CustomerAddress? fromFirestore(String id, Map<String, dynamic> map) {
    final label = map[AddressFields.label] as String?;
    final line = map[AddressFields.line] as String?;
    final location = map[AddressFields.location];
    if (label == null || line == null || location is! GeoPoint) return null;

    return CustomerAddress(
      id: id,
      label: label,
      line: line,
      location: LatLng(location.latitude, location.longitude),
      note: map[AddressFields.note] as String? ?? '',
      isDefault: map[AddressFields.isDefault] as bool? ?? false,
      createdAt: switch (map[AddressFields.createdAt]) {
        final Timestamp t => t.toDate(),
        _ => null,
      },
    );
  }

  /// Fields for a new or updated address document. The id is the document
  /// id, so it is not stored as a field; createdAt is set by the service.
  Map<String, dynamic> toMap() {
    return {
      AddressFields.label: label,
      AddressFields.line: line,
      AddressFields.location: GeoPoint(location.latitude, location.longitude),
      AddressFields.note: note,
      AddressFields.isDefault: isDefault,
    };
  }
}
