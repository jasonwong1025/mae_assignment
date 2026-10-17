import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final catalogueServiceProvider = Provider<CatalogueService>((ref) {
  return CatalogueService(FirebaseFirestore.instance);
});

/// Reads the catalogue from Firestore: the shared `products` collection,
/// the `categories` collection, and a branch's `inventory` subcollection
/// (price and stock per branch).
///
/// Only reads; the catalogue is written by the Store Admin side. The
/// documents are returned raw so the repository can join and map them.
class CatalogueService {
  CatalogueService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> _inventory(String branchId) =>
      _firestore.collection('branches').doc(branchId).collection('inventory');

  /// Every catalogue product, keyed by id.
  Future<Map<String, Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await _products.get();
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  /// A branch's inventory (price, stock, isHidden), keyed by product id.
  Future<Map<String, Map<String, dynamic>>> fetchInventory(
    String branchId,
  ) async {
    final snapshot = await _inventory(branchId).get();
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }

  /// Every category, keyed by id.
  Future<Map<String, Map<String, dynamic>>> fetchCategories() async {
    final snapshot = await _categories.get();
    return {for (final doc in snapshot.docs) doc.id: doc.data()};
  }
}
