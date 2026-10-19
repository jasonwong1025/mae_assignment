import 'dart:typed_data';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/repositories/inventory_repository.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/inventory_service.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/product_photo_service.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import 'fake_branch_service.dart';
import 'fake_image_picker_service.dart';
import 'sample_inventory.dart';

/// In-memory InventoryService, so tests exercise the Inventory tab with no
/// Firebase. Starts with the sample catalogue (sample categories, products
/// and stock at the three sample branches).
class FakeInventoryService extends Fake implements InventoryService {
  FakeInventoryService() {
    for (final item in sampleInventory()) {
      products[item.product.id] = item.product;
      stock.putIfAbsent(item.branchId, () => {})[item.product.id] =
          item.branchStock;
    }
  }

  final List<ProductCategory> categories = [...sampleCategories()];
  final Map<String, Product> products = {};

  /// Price and stock rows, by branch id then product id.
  final Map<String, Map<String, BranchStock>> stock = {};
  int _nextId = 1;

  @override
  Future<List<ProductCategory>> getCategories() async => [...categories];

  @override
  Future<ProductCategory> createCategory(String name, int sortOrder) async {
    final category = ProductCategory(
      id: 'c-new-${_nextId++}',
      name: name,
      sortOrder: sortOrder,
    );
    categories.add(category);
    return category;
  }

  @override
  Future<List<Product>> getProducts() async => [...products.values];

  @override
  Future<Product?> getProduct(String productId) async => products[productId];

  @override
  String newProductId() => 'new-product-${_nextId++}';

  @override
  Future<Map<String, BranchStock>> getBranchStock(String branchId) async {
    return {...?stock[branchId]};
  }

  @override
  Future<void> createProduct(
    Product product,
    Map<String, BranchStock> stockByBranch,
  ) async {
    products[product.id] = product;
    for (final entry in stockByBranch.entries) {
      stock.putIfAbsent(entry.key, () => {})[product.id] = entry.value;
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    products[product.id] = product;
  }

  @override
  Future<void> saveBranchStock(
    String branchId,
    String productId,
    BranchStock row,
  ) async {
    stock.putIfAbsent(branchId, () => {})[productId] = row;
  }

  @override
  Future<int> copyBranchStock({
    required String fromBranchId,
    required String toBranchId,
  }) async {
    final target = stock.putIfAbsent(toBranchId, () => {});
    var copied = 0;
    for (final entry in {...?stock[fromBranchId]}.entries) {
      if (target.containsKey(entry.key)) continue;
      target[entry.key] = entry.value.copyWith(stock: 0, isHidden: false);
      copied++;
    }
    return copied;
  }
}

/// ProductPhotoService that keeps nothing: uploads return a fake URL and
/// deletes are recorded.
class FakeProductPhotoService extends Fake implements ProductPhotoService {
  final List<String> uploaded = [];
  final List<String> deleted = [];

  /// Set to make the next uploads fail.
  bool failUploads = false;

  @override
  Future<String> upload(String productId, Uint8List bytes) async {
    if (failUploads) throw Exception('offline');
    final url = 'https://photos.test/$productId/${uploaded.length}.jpg';
    uploaded.add(url);
    return url;
  }

  @override
  Future<void> delete(String url) async => deleted.add(url);
}

/// An InventoryRepository over the fakes above.
InventoryRepository fakeInventoryRepository({
  FakeImagePickerService? imagePicker,
  FakeInventoryService? service,
  FakeProductPhotoService? photos,
  BranchService? branchService,
}) {
  return InventoryRepository(
    imagePicker ?? FakeImagePickerService(),
    service ?? FakeInventoryService(),
    photos ?? FakeProductPhotoService(),
    BranchRepository(branchService ?? FakeBranchService()),
  );
}

/// The Riverpod overrides that put fresh fakes behind the Inventory tab.
List<Override> fakeInventoryOverrides() => [
  inventoryServiceProvider.overrideWithValue(FakeInventoryService()),
  productPhotoServiceProvider.overrideWithValue(FakeProductPhotoService()),
];
