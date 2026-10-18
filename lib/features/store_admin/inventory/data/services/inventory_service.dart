import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';

final Provider<InventoryService> inventoryServiceProvider =
    Provider<InventoryService>(
      (ref) => InventoryService(ref.watch(firebaseFirestoreProvider)),
    );

/// Reads and writes the catalogue the Inventory tab manages: categories,
/// products and each branch's price and stock. The customer app reads the
/// same documents, so what the admin saves here is what customers see.
/// Admin only; see `firestore.rules`.
class InventoryService {
  InventoryService(FirebaseFirestore firestore)
    : _firestore = firestore,
      _refs = FirestoreRefs(firestore);

  /// Firestore allows 500 writes in one batch; stay well under it.
  static const int _batchLimit = 400;

  final FirebaseFirestore _firestore;
  final FirestoreRefs _refs;

  Future<List<ProductCategory>> getCategories() async {
    final snapshot = await _refs.categories.get().timeout(
      FirestoreConfig.readTimeout,
    );
    return snapshot.toModels(fromFirestore: ProductCategory.fromFirestore);
  }

  /// Saves a new category with a fresh id and returns it.
  Future<ProductCategory> createCategory(String name, int sortOrder) async {
    final doc = _refs.categories.doc();
    final category = ProductCategory(
      id: doc.id,
      name: name,
      sortOrder: sortOrder,
    );
    await doc.set(category.toFirestore());
    return category;
  }

  Future<List<Product>> getProducts() async {
    final snapshot = await _refs.products.get().timeout(
      FirestoreConfig.readTimeout,
    );
    return snapshot.toModels(fromFirestore: Product.fromFirestore);
  }

  /// One product, or null if it does not exist.
  Future<Product?> getProduct(String productId) async {
    final doc = await _refs
        .product(productId)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return doc.toModel(fromFirestore: Product.fromFirestore);
  }

  /// A fresh product id, so photos can be uploaded under it before the
  /// product is saved.
  String newProductId() => _refs.products.doc().id;

  /// The price and stock rows of one branch, by product id.
  Future<Map<String, BranchStock>> getBranchStock(String branchId) async {
    final snapshot = await _refs
        .inventory(branchId)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    final stock = <String, BranchStock>{};
    for (final doc in snapshot.docs) {
      final row = doc.toModel(
        fromFirestore: (_, data) => BranchStock.fromMap(data),
      );
      if (row != null) stock[doc.id] = row;
    }
    return stock;
  }

  /// Saves a new product and its row at each branch in one batch, so a
  /// product is never half created.
  Future<void> createProduct(
    Product product,
    Map<String, BranchStock> stockByBranch,
  ) {
    final batch = _firestore.batch()
      ..set(_refs.product(product.id), product.toFirestore());
    for (final entry in stockByBranch.entries) {
      batch.set(
        _refs.inventory(entry.key).doc(product.id),
        entry.value.toMap(),
      );
    }
    return batch.commit();
  }

  /// Replaces the product's details (shared by every branch).
  Future<void> updateProduct(Product product) {
    return _refs.product(product.id).set(product.toFirestore());
  }

  /// Saves one product's row at one branch.
  Future<void> saveBranchStock(
    String branchId,
    String productId,
    BranchStock stock,
  ) {
    return _refs.inventory(branchId).doc(productId).set(stock.toMap());
  }

  /// Gives [toBranchId] a row for every product [fromBranchId] sells, at the
  /// same price with no stock. Returns how many rows it wrote. Rows the new
  /// branch already has are left alone.
  Future<int> copyBranchStock({
    required String fromBranchId,
    required String toBranchId,
  }) async {
    final source = await getBranchStock(fromBranchId);
    final existing = await getBranchStock(toBranchId);
    final toWrite = [
      for (final entry in source.entries)
        if (!existing.containsKey(entry.key)) entry,
    ];

    for (var start = 0; start < toWrite.length; start += _batchLimit) {
      final batch = _firestore.batch();
      for (final entry in toWrite.skip(start).take(_batchLimit)) {
        batch.set(
          _refs.inventory(toBranchId).doc(entry.key),
          entry.value.copyWith(stock: 0, isHidden: false).toMap(),
        );
      }
      await batch.commit();
    }
    return toWrite.length;
  }
}
