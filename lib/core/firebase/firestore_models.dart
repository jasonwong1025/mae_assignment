import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Builds a model from a document's id and its fields.
typedef FromFirestore<T> = T Function(String id, Map<String, dynamic> data);

/// Turns raw Firestore documents into typed models, the one standard way.
///
/// A model that is a document has `fromFirestore(id, data)` and
/// `toFirestore()` (the pattern in Firebase's own documentation). The id is
/// not a field of the document, so it is passed in on read and never written.
///
/// A malformed document (one whose `fromFirestore` throws, usually a
/// `FormatException` from a `required...` field reader) is logged and
/// skipped rather than failing a whole list, which is how the app has always
/// treated bad data. These helpers are used instead of `withConverter` so that
/// skipping behaves the same on the real SDK and on the in-memory fake used in
/// tests.
extension ModelDocumentSnapshot on DocumentSnapshot<Map<String, dynamic>> {
  /// The parsed model, or null when the document is missing or malformed.
  T? toModel<T>({required FromFirestore<T> fromFirestore}) {
    final data = this.data();
    if (!exists || data == null) return null;
    try {
      return fromFirestore(id, data);
    } on Object catch (error) {
      debugPrint('Skipping malformed document ${reference.path}: $error');
      return null;
    }
  }
}

extension ModelQuerySnapshot on QuerySnapshot<Map<String, dynamic>> {
  /// Every document that parses, in order. Malformed ones are skipped.
  List<T> toModels<T>({required FromFirestore<T> fromFirestore}) {
    return [for (final doc in docs) ?doc.toModel(fromFirestore: fromFirestore)];
  }
}
