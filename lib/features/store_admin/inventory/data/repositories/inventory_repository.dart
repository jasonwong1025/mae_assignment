import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/image_picker_service.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/inventory_service.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/product_photo_service.dart';
import 'package:mae_assignment/shared/models/page_result.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(
    ref.watch(imagePickerServiceProvider),
    ref.watch(inventoryServiceProvider),
    ref.watch(productPhotoServiceProvider),
    ref.watch(branchRepositoryProvider),
  );
});

/// Error with a message to show on screen.
class InventoryException extends AppException {
  const InventoryException(super.message);
}

/// Data for the Inventory tab, kept in Firestore so it is the same catalogue
/// customers shop from: categories, products (with photos in Firebase
/// Storage) and each branch's price and stock.
///
/// The catalogue is small, so a page is cut from the whole list in memory,
/// the same way the Branches tab does.
class InventoryRepository {
  InventoryRepository(
    this._imagePicker,
    this._service,
    this._photos,
    this._branches,
  );

  final ImagePickerService _imagePicker;
  final InventoryService _service;
  final ProductPhotoService _photos;
  final BranchRepository _branches;

  Future<List<ProductCategory>> getCategories() async {
    final categories = await _run(_service.getCategories);
    return categories..sort((a, b) {
      final byOrder = a.sortOrder.compareTo(b.sortOrder);
      return byOrder != 0
          ? byOrder
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

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

  /// Adds a category. Names must be unique. New categories sort last.
  Future<ProductCategory> addCategory(String name) async {
    final categories = await getCategories();
    final isTaken = categories.any((category) {
      return category.name.toLowerCase() == name.toLowerCase();
    });
    if (isTaken) {
      throw const InventoryException('This category already exists.');
    }
    final next = categories.isEmpty ? 0 : categories.last.sortOrder + 1;
    return await _run(() => _service.createCategory(name, next));
  }

  /// One page of a branch's products, sorted by name.
  /// A filter that is null is not applied.
  ///
  /// Every product is listed, even one this branch has no row for: that
  /// shows as hidden with no stock, so the admin can set it up.
  Future<PageResult<InventoryItem>> getItems(
    String branchId, {
    String searchText = '',
    String? categoryId,
    StockStatus? stockStatus,
    bool? isHidden,
    int page = 1,
  }) async {
    final (products, stock) = await _run(() async {
      return (
        await _service.getProducts(),
        await _service.getBranchStock(branchId),
      );
    });

    final search = searchText.trim().toLowerCase();
    final matching =
        [
            for (final product in products)
              InventoryItem.of(
                product,
                branchId,
                stock[product.id] ?? BranchStock.unlisted,
              ),
          ].where((item) {
            final product = item.product;
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
          }).toList()
          ..sort((a, b) {
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
    required List<ProductPhoto> photos,
    required String branchId,
    required double price,
    required int stock,
  }) async {
    final existing = await _run(_service.getProducts);
    final exists = existing.any((product) {
      return product.name.toLowerCase() == name.toLowerCase() &&
          product.brand.toLowerCase() == brand.toLowerCase() &&
          product.packSize.toLowerCase() == packSize.toLowerCase();
    });
    if (exists) {
      throw const InventoryException('This product already exists.');
    }

    final branches = await _run(_branches.getBranches);
    final productId = _service.newProductId();
    final uploaded = <String>[];
    try {
      final stored = await _upload(productId, photos, uploaded);
      await _run(
        () => _service.createProduct(
          Product(
            id: productId,
            name: name,
            brand: brand,
            categoryId: categoryId,
            packSize: packSize,
            description: description,
            lowStockLevel: lowStockLevel,
            photos: stored,
          ),
          {
            for (final branch in branches)
              branch.id: BranchStock(
                price: price,
                stock: branch.id == branchId ? stock : 0,
                isHidden: false,
              ),
          },
        ),
      );
    } on Object {
      // Do not leave photos behind for a product that was never saved.
      await _deleteQuietly(uploaded);
      rethrow;
    }
  }

  /// Gives a new branch every product the oldest other branch sells, at
  /// that branch's price and with 0 stock.
  Future<void> addBranch(String branchId) async {
    final branches = await _run(_branches.getBranches);
    for (final other in branches.where((branch) => branch.id != branchId)) {
      final copied = await _run(
        () => _service.copyBranchStock(
          fromBranchId: other.id,
          toBranchId: branchId,
        ),
      );
      if (copied > 0) return;
    }
  }

  /// Saves an item. Price, stock and hidden change at its branch only.
  /// Product details and photos change at every branch.
  Future<void> updateItem(InventoryItem changed) async {
    final product = changed.product;
    final saved = await _run(() => _service.getProduct(product.id));
    final keptUrls = product.storedUrls.toSet();
    final removed = [
      for (final url in saved?.storedUrls ?? const <String>[])
        if (!keptUrls.contains(url)) url,
    ];

    final uploaded = <String>[];
    try {
      final stored = await _upload(product.id, product.photos, uploaded);
      await _run(() async {
        await _service.updateProduct(product.copyWith(photos: stored));
        await _service.saveBranchStock(
          changed.branchId,
          product.id,
          changed.branchStock,
        );
      });
    } on Object {
      await _deleteQuietly(uploaded);
      rethrow;
    }
    // Only after the product no longer points at them.
    await _deleteQuietly(removed);
  }

  /// Uploads the picked photos and returns every photo as a stored one, in
  /// the same order. The URLs of new uploads are also added to [uploaded] so
  /// the caller can remove them if saving fails.
  Future<List<ProductPhoto>> _upload(
    String productId,
    List<ProductPhoto> photos,
    List<String> uploaded,
  ) async {
    final stored = <ProductPhoto>[];
    for (final photo in photos) {
      switch (photo) {
        case StoredPhoto():
          stored.add(photo);
        case PickedPhoto(:final bytes):
          final String url;
          try {
            url = await _photos.upload(productId, bytes);
          } on Object catch (error) {
            debugPrint('Photo upload failed: $error');
            throw const InventoryException(
              'Could not upload the photos. Please check your connection '
              'and try again.',
            );
          }
          uploaded.add(url);
          stored.add(ProductPhoto.stored(url));
      }
    }
    return stored;
  }

  Future<void> _deleteQuietly(List<String> urls) async {
    for (final url in urls) {
      try {
        await _photos.delete(url);
      } on Object catch (error) {
        debugPrint('Could not delete photo $url: $error');
      }
    }
  }

  Future<T> _run<T>(Future<T> Function() call) {
    return guard(
      call,
      label: 'inventory',
      onError: () => const InventoryException(kNetworkErrorMessage),
    );
  }
}
