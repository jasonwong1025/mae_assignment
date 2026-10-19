import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'catalogue_product.freezed.dart';

/// A product in the customer catalogue, with the price and stock for the
/// branch the customer is shopping from.
///
/// This is a read model: it joins the shared products/{id} document with the
/// branch's branches/{branchId}/inventory/{id} document, so it is built by
/// [CatalogueProduct.fromFirestore] and never written back. Images are URLs
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

    /// Name of the category, e.g. "Dairy & Eggs", filled in by the
    /// repository from the categories. Copied onto order lines at checkout.
    @Default('') String categoryName,

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
    String categoryName = '',
  }) {
    if (inventory[InventoryFields.isHidden] == true) return null;
    try {
      return CatalogueProduct(
        id: id,
        name: product.requiredString(ProductFields.name),
        brand: product.string(ProductFields.brand),
        categoryId: product.string(ProductFields.categoryId),
        packSize: product.string(ProductFields.packSize),
        price: inventory.requiredDecimal(InventoryFields.price),
        stock: inventory.requiredInteger(InventoryFields.stock),
        description: product.string(ProductFields.description),
        categoryName: categoryName,
        imageUrls: product.strings(ProductFields.imageUrls),
      );
    } on FormatException {
      return null;
    }
  }

  /// The cover image URL, or null if the product has no images.
  String? get coverImageUrl => imageUrls.isEmpty ? null : imageUrls.first;

  /// True when the customer cannot add this to the cart.
  bool get isOutOfStock => stock <= 0;

  /// Shown as a scarcity hint, e.g. "Only 9 left". Null when there is
  /// plenty of stock or none at all.
  int? get lowStockRemaining => stock > 0 && stock <= 10 ? stock : null;
}

/// A catalogue category, e.g. "Fresh produce", stored at
/// categories/{categoryId}.
@freezed
abstract class CatalogueCategory with _$CatalogueCategory {
  const factory CatalogueCategory({
    required String id,
    required String name,

    /// Lower sorts first in the category tabs.
    @Default(0) int sortOrder,
  }) = _CatalogueCategory;

  const CatalogueCategory._();

  /// Reads categories/{id}. Returns null when the name is missing, so a
  /// malformed document is skipped.
  static CatalogueCategory? fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      return CatalogueCategory(
        id: id,
        name: data.requiredString(CategoryFields.name),
        sortOrder: data.integer(CategoryFields.sortOrder),
      );
    } on FormatException {
      return null;
    }
  }
}
