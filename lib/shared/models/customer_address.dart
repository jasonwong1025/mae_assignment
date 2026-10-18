import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
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

  /// Reads users/{uid}/addresses/{id}. A document missing its label, line or
  /// location is malformed and throws, so it is skipped when reading a list.
  factory CustomerAddress.fromFirestore(String id, Map<String, dynamic> data) {
    return CustomerAddress(
      id: id,
      label: data.requiredString(AddressFields.label),
      line: data.requiredString(AddressFields.line),
      location: data.requiredLatLng(AddressFields.location),
      note: data.string(AddressFields.note),
      isDefault: data.boolean(AddressFields.isDefault, fallback: false),
      createdAt: data.dateTime(AddressFields.createdAt),
    );
  }

  /// Fields for a new or updated address document. The id is the document
  /// id, so it is not stored as a field; createdAt is set by the service.
  Map<String, dynamic> toFirestore() {
    return {
      AddressFields.label: label,
      AddressFields.line: line,
      AddressFields.location: toGeoPoint(location),
      AddressFields.note: note,
      AddressFields.isDefault: isDefault,
    };
  }
}
