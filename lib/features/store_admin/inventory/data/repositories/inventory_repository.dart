import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_item.dart';
import '../models/product.dart';
import '../sample_inventory.dart';
import '../services/image_picker_service.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(imagePickerServiceProvider));
});

/// Error with a message to show on screen.
class InventoryException implements Exception {
  const InventoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Products, categories and per-branch stock for the Inventory tab.
/// No backend yet: everything is kept in memory and resets on restart.
class InventoryRepository {
  InventoryRepository(this._imagePicker);

  final ImagePickerService _imagePicker;

  // Copied so new categories can be added to it.
  final List<ProductCategory> _categories = [...sampleCategories()];

  /// Every product at every branch.
  final List<InventoryItem> _items = sampleInventory();
  final List<String> _branchIds = sampleBranchIds;
  int _nextId = 100;

  Future<List<ProductCategory>> getCategories() async => [..._categories];

  /// Lets the admin choose up to [limit] photos from the device.
  Future<List<Uint8List>> pickPhotos(int limit) async {
    try {
      return await _imagePicker.pickPhotos(limit);
    } catch (error) {
      // Printed so the real cause shows in the debug console.
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

  /// Products of one branch.
  Future<List<InventoryItem>> getItems(String branchId) async {
    return _items.where((item) => item.branchId == branchId).toList();
  }

  /// Adds a product to the catalogue. [branchId] gets [price] and
  /// [stock]. Other branches get the same price and 0 stock.
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

  /// Saves one branch's item: its price, stock and visibility there,
  /// and the product details, which change at every branch.
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
