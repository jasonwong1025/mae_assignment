import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

/// Product category, e.g. "Dairy & Eggs".
@freezed
abstract class ProductCategory with _$ProductCategory {
  const factory ProductCategory({required String id, required String name}) =
      _ProductCategory;

  const ProductCategory._();
}

/// A product. Shared by every branch.
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

    /// Up to [maxPhotos]. The first is the cover.
    /// Image data for now. Firebase Storage links later.
    @Default(<Uint8List>[]) List<Uint8List> photos,
  }) = _Product;

  const Product._();

  static const int maxPhotos = 5;

  /// First photo. Null if none.
  Uint8List? get cover => photos.isEmpty ? null : photos.first;
}
