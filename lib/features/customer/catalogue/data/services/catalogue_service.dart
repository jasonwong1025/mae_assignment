import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';

final catalogueServiceProvider = Provider<CatalogueService>((ref) {
  return CatalogueService(ref.watch(firebaseFirestoreProvider));
});

/// Reads the catalogue from Firestore: the shared `products` collection,
/// the `categories` collection, and a branch's `inventory` subcollection
/// (price and stock per branch).
///
/// Only reads; the catalogue is written by the Store Admin side. The
/// documents are returned raw so the repository can join and map them.
///
/// Every read has a timeout: Firestore's `get()` retries forever when it
/// cannot reach the backend (no connection, or an emulator that is not
/// running), so without a limit the Home screen would load indefinitely.
/// On timeout the repository turns this into a retryable error.
class CatalogueService {
  CatalogueService(FirebaseFirestore firestore)
    : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// Every catalogue product, keyed by id.
  Future<Map<String, Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await _refs.products.get().timeout(
      FirestoreConfig.readTimeout,
    );
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  /// A branch's inventory (price, stock, isHidden), keyed by product id.
  Future<Map<String, Map<String, dynamic>>> fetchInventory(
    String branchId,
  ) async {
    final snapshot = await _refs
        .inventory(branchId)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  /// Every category, keyed by id.
  Future<Map<String, Map<String, dynamic>>> fetchCategories() async {
    final snapshot = await _refs.categories.get().timeout(
      FirestoreConfig.readTimeout,
    );
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }
}
