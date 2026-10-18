// Reference patterns for the kinds of class every contributor writes, kept as
// a copyable example. The README ("Code conventions") explains when to use
// each one.
//
// Freezed generates immutable data classes (with ==, hashCode, copyWith,
// toString) and sealed unions (with pattern-matching via `switch`).
//
// After editing any annotated file, regenerate with:
//   fvm dart run build_runner build
// The generated `*.freezed.dart` files ARE committed, so the app builds
// straight after a checkout, and CI fails if they are stale. The analyzer
// ignores them (see analysis_options.yaml).
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';

part 'freezed_example.freezed.dart';

/// Pattern 1 — an immutable data model.
///
/// Use for in-memory domain/data objects that are not stored as a Firestore
/// document (for example a cart line). Freezed provides value equality,
/// copyWith and toString for free.
@freezed
abstract class ExampleCartLine with _$ExampleCartLine {
  const factory ExampleCartLine({
    required String productId,
    required String name,
    required double unitPrice,
    @Default(1) int quantity,
  }) = _ExampleCartLine;
}

/// Pattern 2 — a sealed union for view-model state.
///
/// Use for the discrete states a screen can be in. `switch` over the union is
/// exhaustive, so adding a case the UI forgot to handle is a compile error.
@freezed
sealed class ExampleCheckoutState with _$ExampleCheckoutState {
  const factory ExampleCheckoutState.idle() = ExampleCheckoutIdle;
  const factory ExampleCheckoutState.submitting() = ExampleCheckoutSubmitting;
  const factory ExampleCheckoutState.success(String orderId) =
      ExampleCheckoutSuccess;
  const factory ExampleCheckoutState.failure(String message) =
      ExampleCheckoutFailure;
}

/// Pattern 3 — a model stored in Firestore, at `examples/{id}`.
///
/// Mapping is written by hand, the way Firebase's own documentation shows
/// it, so the field names come from `firestore_paths.dart` (the single
/// schema) instead of being implied by property names. Rules:
/// - A document with an id has `fromFirestore(id, data)` and
///   `toFirestore()`. A nested value (an array entry) or a document with no
///   id of its own has `fromMap(map)` and `toMap()`.
/// - Read with the `FieldReaders` extension (`data.string(...)`). Plain
///   readers fall back to a default so an older document still loads;
///   `required...` readers throw so a broken document is skipped, not shown
///   half empty.
/// - The document id is never written as a field.
/// - Server times (createdAt, updatedAt...) are read with `dateTime` and are
///   NOT in `toFirestore`; the service writes `FieldValue.serverTimestamp()`.
/// - Locations are `LatLng` in Dart and `GeoPoint` in Firestore
///   (`latLng` / `toGeoPoint`).
/// - Leave an optional value out of the map when it has no value.
/// - Add a round-trip test (`fromFirestore(id, toFirestore())` equals the
///   original) next to the model.
@freezed
abstract class ExampleDocument with _$ExampleDocument {
  const factory ExampleDocument({
    required String id,
    required String title,
    required int count,
    String? note,
    DateTime? createdAt,
  }) = _ExampleDocument;

  const ExampleDocument._();

  /// Reads examples/{id}. A missing title throws, so the document is skipped.
  factory ExampleDocument.fromFirestore(String id, Map<String, dynamic> data) {
    return ExampleDocument(
      id: id,
      title: data.requiredString('title'),
      count: data.integer('count'),
      note: data.stringOrNull('note'),
      createdAt: data.dateTime('createdAt'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'title': title, 'count': count, if (note != null) 'note': note};
  }
}
