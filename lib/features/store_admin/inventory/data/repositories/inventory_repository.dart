import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/sample_inventory.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/image_picker_service.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(imagePickerServiceProvider));
});

/// Error with a message to show on screen.
class InventoryException extends AppException {
  const InventoryException(super.message);
}

/// Data for the Inventory tab.
/// No backend yet: kept in memory and reset on restart.
class InventoryRepository {
  InventoryRepository(this._imagePicker);

  final ImagePickerService _imagePicker;

  // A copy, so categories can be added.
  final List<ProductCategory> _categories = [...sampleCategories()];

  /// Every product at every branch.
  final List<InventoryItem> _items = sampleInventory();
  // A copy, so branches can be added.
  final List<String> _branchIds = [...sampleBranchIds];
  int _nextId = 100;

  Future<List<ProductCategory>> getCategories() async => [..._categories];

  /// Opens the device's photos. Returns up to [limit].
  Future<List<Uint8List>> pickPhotos(int limit) async {
    try {
      return await _imagePicker.pickPhotos(limit);
    } on Object catch (error) {
      // Show the real error in the debug console.
      debugPrint('Picking photos failed: $error');
      throw const InventoryException('Could not open your photos.');
    }
  }

  /// Adds a category. Names must be unique.
  Future<ProductCategory> addCategory(String name) async {
    final isTaken = _categories.any((category) {
      return category.name.toLowerCase() == name.toLowerCase();
    });
    if (isTaken) {
      throw const InventoryException('This category already exists.');
    }

    final category = ProductCategory(id: 'c${_nextId++}', name: name);
    _categories.add(category);
    return category;
  }

  /// One page of a branch's products, sorted by name.
  /// A filter that is null is not applied.
  Future<PageResult<InventoryItem>> getItems(
    String branchId, {
    String searchText = '',
    String? categoryId,
    StockStatus? stockStatus,
    bool? isHidden,
    int page = 1,
  }) async {
    final search = searchText.trim().toLowerCase();

    final matching =
        _items.where((item) {
          final product = item.product;
          if (item.branchId != branchId) return false;
          if (categoryId != null && product.categoryId != categoryId) {
            return false;
          }
          if (stockStatus != null && item.stockStatus != stockStatus) {
            return false;
          }
          if (isHidden != null && item.isHidden != isHidden) return false;

          // Search by product name or brand.
          return search.isEmpty ||
              product.name.toLowerCase().contains(search) ||
              product.brand.toLowerCase().contains(search);
        }).toList()..sort((a, b) {
          return a.product.name.toLowerCase().compareTo(
            b.product.name.toLowerCase(),
          );
        });

    return PageResult.fromList(matching, page: page);
  }

  /// Adds a product to every branch. [branchId] gets [stock];
  /// the others get 0. All get [price].
  Future<void> addProduct({
    required String name,
    required String brand,
    required String categoryId,
    required String packSize,
    required String description,
    required int lowStockLevel,
    required List<Uint8List> photos,
    required String branchId,
    required double price,
    required int stock,
  }) async {
    final exists = _items.any((item) {
      final product = item.product;
      return product.name.toLowerCase() == name.toLowerCase() &&
          product.brand.toLowerCase() == brand.toLowerCase() &&
          product.packSize.toLowerCase() == packSize.toLowerCase();
    });
    if (exists) {
      throw const InventoryException('This product already exists.');
    }

    final product = Product(
      id: 'p${_nextId++}',
      name: name,
      brand: brand,
      categoryId: categoryId,
      packSize: packSize,
      description: description,
      lowStockLevel: lowStockLevel,
      photos: photos,
    );

    for (final id in _branchIds) {
      _items.add(
        InventoryItem(
          product: product,
          branchId: id,
          price: price,
          stock: id == branchId ? stock : 0,
          isHidden: false,
        ),
      );
    }
  }

  /// Gives a new branch every product, at the first branch's price and
  /// with 0 stock.
  Future<void> addBranch(String branchId) async {
    final firstBranch = _branchIds.first;
    final templates = _items.where((item) => item.branchId == firstBranch);

    _items.addAll([
      for (final item in templates)
        InventoryItem(
          product: item.product,
          branchId: branchId,
          price: item.price,
          stock: 0,
          isHidden: false,
        ),
    ]);
    _branchIds.add(branchId);
  }

  /// Saves an item. Price, stock and hidden change at its branch only.
  /// Product details change at every branch.
  Future<void> updateItem(InventoryItem changed) async {
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.product.id != changed.product.id) continue;

      _items[i] = item.branchId == changed.branchId
          ? changed
          : item.copyWith(product: changed.product);
    }
  }
}
