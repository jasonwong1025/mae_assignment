import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/product.dart';
import '../../data/repositories/inventory_repository.dart';

final inventoryViewModelProvider =
    AsyncNotifierProvider.autoDispose<InventoryViewModel, InventoryState>(
      InventoryViewModel.new,
    );

/// What the Inventory tab shows.
class InventoryState {
  const InventoryState({required this.items, required this.categories});

  /// Products of the selected branch.
  final List<InventoryItem> items;
  final List<ProductCategory> categories;

  String categoryName(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'No category';
  }
}

/// State for the Inventory tab.
/// Methods that change data return an error message, or null if it
/// worked.
class InventoryViewModel extends AsyncNotifier<InventoryState> {
  @override
  Future<InventoryState> build() async {
    // Runs again when the branch changes.
    final branchState = await ref.watch(branchViewModelProvider.future);
    final repository = ref.watch(inventoryRepositoryProvider);

    return InventoryState(
      items: await repository.getItems(branchState.selected.id),
      categories: await repository.getCategories(),
    );
  }

  /// Adds a product. Price and stock are for the selected branch.
  Future<String?> addProduct({
    required String name,
    required String brand,
    required String categoryId,
    required String packSize,
    required String description,
    required int lowStockLevel,
    required List<Uint8List> photos,
    required double price,
    required int stock,
  }) async {
    final branch = ref.read(branchViewModelProvider).value?.selected;
    if (branch == null) return 'Please choose a branch first.';

    try {
      await ref
          .read(inventoryRepositoryProvider)
          .addProduct(
            name: name.trim(),
            brand: brand.trim(),
            categoryId: categoryId,
            packSize: packSize.trim(),
            description: description.trim(),
            lowStockLevel: lowStockLevel,
            photos: photos,
            branchId: branch.id,
            price: price,
            stock: stock,
          );
    } on InventoryException catch (e) {
      return e.message;
    }
    await _reload();
    return null;
  }

  /// Saves product details and this branch's price.
  Future<String?> saveDetails(
    InventoryItem item, {
    required String name,
    required String brand,
    required String categoryId,
    required String packSize,
    required String description,
    required int lowStockLevel,
    required List<Uint8List> photos,
    required double price,
  }) {
    final product = Product(
      id: item.product.id,
      name: name.trim(),
      brand: brand.trim(),
      categoryId: categoryId,
      packSize: packSize.trim(),
      description: description.trim(),
      lowStockLevel: lowStockLevel,
      photos: photos,
    );
    return _save(item.copyWith(product: product, price: price));
  }

  /// Picks up to [limit] photos. Null if the picker failed.
  Future<List<Uint8List>?> pickPhotos(int limit) async {
    try {
      return await ref.read(inventoryRepositoryProvider).pickPhotos(limit);
    } on InventoryException {
      return null;
    }
  }

  Future<String?> setStock(InventoryItem item, int stock) {
    return _save(item.copyWith(stock: stock));
  }

  /// Hides or unhides the product at this branch.
  Future<String?> setHidden(InventoryItem item, {required bool hidden}) {
    return _save(item.copyWith(isHidden: hidden));
  }

  /// Returns the new category, or null if the name is taken.
  Future<ProductCategory?> addCategory(String name) async {
    final ProductCategory category;
    try {
      category = await ref
          .read(inventoryRepositoryProvider)
          .addCategory(name.trim());
    } on InventoryException {
      return null;
    }
    await _reload();
    return category;
  }

  Future<String?> _save(InventoryItem item) async {
    try {
      await ref.read(inventoryRepositoryProvider).updateItem(item);
    } on InventoryException catch (e) {
      return e.message;
    }
    await _reload();
    return null;
  }

  /// Reloads the list.
  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }
}
