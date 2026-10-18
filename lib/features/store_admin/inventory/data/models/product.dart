import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'product.freezed.dart';

/// Product category, e.g. "Dairy & Eggs", stored at categories/{id}.
@freezed
abstract class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required String id,
    required String name,

    /// Lower sorts first. New categories go last.
    @Default(0) int sortOrder,
  }) = _ProductCategory;

  const ProductCategory._();

  /// Reads categories/{id}. A category without a name throws, so it is
  /// skipped.
  factory ProductCategory.fromFirestore(String id, Map<String, dynamic> data) {
    return ProductCategory(
      id: id,
      name: data.requiredString(CategoryFields.name),
      sortOrder: data.integer(CategoryFields.sortOrder),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {CategoryFields.name: name, CategoryFields.sortOrder: sortOrder};
  }
}

/// One photo of a product: already uploaded (a Firebase Storage URL) or just
/// picked from the gallery and not uploaded yet.
@freezed
sealed class ProductPhoto with _$ProductPhoto {
  const factory ProductPhoto.stored(String url) = StoredPhoto;
  const factory ProductPhoto.picked(Uint8List bytes) = PickedPhoto;
}

/// A product. Shared by every branch, stored at products/{id}.
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String brand,
    required String categoryId,

    /// E.g. "1L" or "500g".
    required String packSize,

    /// Can be empty.
    required String description,

    /// Stock at or below this counts as low.
    required int lowStockLevel,

    /// Up to [maxPhotos]. The first is the cover. Saved products only hold
    /// stored photos; picked ones are uploaded on save.
    @Default(<ProductPhoto>[]) List<ProductPhoto> photos,
  }) = _Product;

  const Product._();

  /// Reads products/{id}. A product without a name throws, so it is skipped.
  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data.requiredString(ProductFields.name),
      brand: data.string(ProductFields.brand),
      categoryId: data.string(ProductFields.categoryId),
      packSize: data.string(ProductFields.packSize),
      description: data.string(ProductFields.description),
      lowStockLevel: data.integer(
        ProductFields.lowStockLevel,
        fallback: defaultLowStockLevel,
      ),
      photos: [
        for (final url in data.strings(ProductFields.imageUrls))
          ProductPhoto.stored(url),
      ],
    );
  }

  static const int maxPhotos = 5;

  /// Used when a product was saved without a low-stock level (for example
  /// by the seed script).
  static const int defaultLowStockLevel = 10;

  /// Fields saved in products/{id}. Only stored photos are written: upload
  /// picked ones first (the repository does).
  Map<String, dynamic> toFirestore() {
    return {
      ProductFields.name: name,
      ProductFields.brand: brand,
      ProductFields.categoryId: categoryId,
      ProductFields.packSize: packSize,
      ProductFields.description: description,
      ProductFields.lowStockLevel: lowStockLevel,
      ProductFields.imageUrls: [
        for (final photo in photos)
          if (photo case StoredPhoto(:final url)) url,
      ],
    };
  }

  /// URLs of the photos already uploaded.
  List<String> get storedUrls => [
    for (final photo in photos)
      if (photo case StoredPhoto(:final url)) url,
  ];

  /// First photo. Null if none.
  ProductPhoto? get cover => photos.isEmpty ? null : photos.first;
}
