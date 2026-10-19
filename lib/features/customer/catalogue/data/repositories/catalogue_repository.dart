import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/services/catalogue_service.dart';

part 'catalogue_repository.freezed.dart';

final catalogueRepositoryProvider = Provider<CatalogueRepository>((ref) {
  return CatalogueRepository(ref.watch(catalogueServiceProvider));
});

/// Error with a message that is safe to show on screen.
class CatalogueException extends AppException {
  const CatalogueException(super.message);
}

/// The whole catalogue for one branch: its categories and the products a
/// customer can buy there, already joined with the branch's price and stock.
@freezed
abstract class CatalogueData with _$CatalogueData {
  const factory CatalogueData({
    required List<CatalogueCategory> categories,
    required List<CatalogueProduct> products,
  }) = _CatalogueData;

  const CatalogueData._();

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

  /// Whether [branchId] has anything on its shelves: at least one visible
  /// inventory entry in stock. One cheap read of the branch's inventory, used
  /// to avoid defaulting a customer to an empty store. Throws
  /// [CatalogueException] if Firestore cannot be reached.
  Future<bool> hasProducts(String branchId) {
    return _run(() async {
      final inventory = await _service.fetchInventory(branchId);
      return inventory.values.any((item) {
        final stock = (item[InventoryFields.stock] as num?)?.toInt() ?? 0;
        return item[InventoryFields.isHidden] != true && stock > 0;
      });
    });
  }

  /// Loads the catalogue for [branchId]. Throws [CatalogueException] with a
  /// friendly message if Firestore cannot be reached.
  Future<CatalogueData> loadCatalogue(String branchId) async {
    final (products, inventory, categories) = await _run(() async {
      return (
        await _service.fetchProducts(),
        await _service.fetchInventory(branchId),
        await _service.fetchCategories(),
      );
    });

    final sortedCategories =
        <CatalogueCategory>[
          for (final entry in categories.entries)
            ?CatalogueCategory.fromFirestore(entry.key, entry.value),
        ]..sort((a, b) {
          final byOrder = a.sortOrder.compareTo(b.sortOrder);
          return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
        });

    final categoryNames = {
      for (final category in sortedCategories) category.id: category.name,
    };

    final items = <CatalogueProduct>[
      for (final entry in products.entries)
        if (inventory[entry.key] case final branchInventory?)
          ?CatalogueProduct.fromFirestore(
            id: entry.key,
            product: entry.value,
            inventory: branchInventory,
            categoryName:
                categoryNames[entry.value[ProductFields.categoryId]] ?? '',
          ),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return CatalogueData(categories: sortedCategories, products: items);
  }

  /// Runs a Firestore read through the shared [guard].
  Future<T> _run<T>(Future<T> Function() call) {
    return guard(
      call,
      label: 'catalogue',
      onError: () => const CatalogueException(
        'Could not load the store. Please check your connection and try '
        'again.',
      ),
    );
  }
}
