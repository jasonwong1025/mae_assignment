import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'catalogue_product.freezed.dart';

/// A product in the customer catalogue, with the price and stock for the
/// branch the customer is shopping from.
///
/// This is the customer's read-only view of a product. Images are URLs
/// (Firebase Storage), not raw bytes like the admin's editing model.
@freezed
abstract class CatalogueProduct with _$CatalogueProduct {
  const factory CatalogueProduct({
    required String id,
    required String name,
    required String brand,
    required String categoryId,

    /// E.g. "1L" or "500g".
    required String packSize,

    /// Price at the customer's branch, in ringgit.
    required double price,

    /// Stock at the customer's branch.
    required int stock,
    @Default('') String description,

    /// Image URLs; the first is the cover. Empty shows a placeholder.
    @Default(<String>[]) List<String> imageUrls,
  }) = _CatalogueProduct;

  const CatalogueProduct._();

  /// Builds a product by joining its catalogue document with the branch's
  /// inventory document. Returns null if the product is hidden at the
  /// branch or is missing required fields, so it is simply left out.
  static CatalogueProduct? fromFirestore({
    required String id,
    required Map<String, dynamic> product,
    required Map<String, dynamic> inventory,
  }) {
    if (inventory[InventoryFields.isHidden] == true) return null;

    final name = product[ProductFields.name] as String?;
    final price = (inventory[InventoryFields.price] as num?)?.toDouble();
    final stock = (inventory[InventoryFields.stock] as num?)?.toInt();
    if (name == null || price == null || stock == null) return null;

    return CatalogueProduct(
      id: id,
      name: name,
      brand: product[ProductFields.brand] as String? ?? '',
      categoryId: product[ProductFields.categoryId] as String? ?? '',
      packSize: product[ProductFields.packSize] as String? ?? '',
      price: price,
      stock: stock,
      description: product[ProductFields.description] as String? ?? '',
      imageUrls: _stringList(product[ProductFields.imageUrls]),
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is String && item.isNotEmpty) item,
    ];
  }

  /// The cover image URL, or null if the product has no images.
  String? get coverImageUrl => imageUrls.isEmpty ? null : imageUrls.first;

  /// True when the customer cannot add this to the cart.
  bool get isOutOfStock => stock <= 0;

  /// Shown as a scarcity hint, e.g. "Only 9 left". Null when there is
  /// plenty of stock or none at all.
  int? get lowStockRemaining => stock > 0 && stock <= 10 ? stock : null;
}

/// A catalogue category, e.g. "Fresh produce".
@freezed
abstract class CatalogueCategory with _$CatalogueCategory {
  const factory CatalogueCategory({
    required String id,
    required String name,

    /// Lower sorts first in the category tabs.
    @Default(0) int sortOrder,
  }) = _CatalogueCategory;

  const CatalogueCategory._();

  static CatalogueCategory? fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final name = data[CategoryFields.name] as String?;
    if (name == null) return null;
    return CatalogueCategory(
      id: id,
      name: name,
      sortOrder: (data[CategoryFields.sortOrder] as num?)?.toInt() ?? 0,
    );
  }
}

/// Converts a Firestore timestamp field if present (reserved for future
/// catalogue fields like createdAt).
DateTime? timestampToDate(Object? value) {
  return value is Timestamp ? value.toDate() : null;
}
