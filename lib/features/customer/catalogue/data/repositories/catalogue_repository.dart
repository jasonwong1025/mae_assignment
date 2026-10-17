import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/services/catalogue_service.dart';

final catalogueRepositoryProvider = Provider<CatalogueRepository>((ref) {
  return CatalogueRepository(ref.watch(catalogueServiceProvider));
});

/// Error with a message that is safe to show on screen.
class CatalogueException implements Exception {
  const CatalogueException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The whole catalogue for one branch: its categories and the products a
/// customer can buy there, already joined with the branch's price and stock.
class CatalogueData {
  const CatalogueData({required this.categories, required this.products});

  final List<CatalogueCategory> categories;
  final List<CatalogueProduct> products;

  /// Products in [categoryId], or every product when it is null.
  List<CatalogueProduct> productsIn(String? categoryId) {
    if (categoryId == null) return products;
    return [
      for (final product in products)
        if (product.categoryId == categoryId) product,
    ];
  }
}

/// The customer catalogue, read from Firestore. Joins the shared product
/// documents with the selected branch's inventory, so each product carries
/// the branch's price and stock. Hidden and malformed products are left
/// out. Read-only: the Store Admin side writes the catalogue.
class CatalogueRepository {
  CatalogueRepository(this._service);

  final CatalogueService _service;

  /// Loads the catalogue for [branchId]. Throws [CatalogueException] with a
  /// friendly message if Firestore cannot be reached.
  Future<CatalogueData> loadCatalogue(String branchId) async {
    final Map<String, Map<String, dynamic>> products;
    final Map<String, Map<String, dynamic>> inventory;
    final Map<String, Map<String, dynamic>> categories;
    try {
      products = await _service.fetchProducts();
      inventory = await _service.fetchInventory(branchId);
      categories = await _service.fetchCategories();
    } on Object {
      throw const CatalogueException(
        'Could not load the store. Please check your connection and try '
        'again.',
      );
    }

    final items = <CatalogueProduct>[
      for (final entry in products.entries)
        if (inventory[entry.key] case final branchInventory?)
          ?CatalogueProduct.fromFirestore(
            id: entry.key,
            product: entry.value,
            inventory: branchInventory,
          ),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final sortedCategories =
        <CatalogueCategory>[
          for (final entry in categories.entries)
            ?CatalogueCategory.fromFirestore(entry.key, entry.value),
        ]..sort((a, b) {
          final byOrder = a.sortOrder.compareTo(b.sortOrder);
          return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
        });

    return CatalogueData(categories: sortedCategories, products: items);
  }
}
