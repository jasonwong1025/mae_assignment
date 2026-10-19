import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/shared/models/order.dart';

final replacementRepositoryProvider = Provider<ReplacementRepository>((ref) {
  return ReplacementRepository(ref.watch(catalogueRepositoryProvider));
});

/// Suggests what a packer can offer instead of an unavailable item: other
/// products that are in stock at the order's branch.
class ReplacementRepository {
  ReplacementRepository(this._catalogue);

  final CatalogueRepository _catalogue;

  /// Products the packer can offer for [unavailable], as order lines for the
  /// same quantity and the same `lineId`, ready to save.
  ///
  /// Only products with enough stock for the quantity, and not already on
  /// the order. The unavailable item's own category comes first, then the
  /// rest, each by name. Throws [CatalogueException] if the catalogue cannot
  /// be loaded.
  Future<List<OrderItem>> optionsFor(Order order, OrderItem unavailable) async {
    final catalogue = await _catalogue.loadCatalogue(order.branchId);
    final onOrder = {for (final item in order.items) item.productId};
    final fits = [
      for (final product in catalogue.products)
        if (product.stock >= unavailable.quantity &&
            !onOrder.contains(product.id))
          product,
    ];
    // Stable: the catalogue is already sorted by name.
    final sameCategory = [
      for (final product in fits)
        if (_sameCategory(product, unavailable)) product,
    ];
    final others = [
      for (final product in fits)
        if (!_sameCategory(product, unavailable)) product,
    ];
    return [
      for (final product in [...sameCategory, ...others])
        _asLine(product, unavailable),
    ];
  }

  static bool _sameCategory(CatalogueProduct product, OrderItem item) {
    return item.categoryId.isNotEmpty && product.categoryId == item.categoryId;
  }

  static OrderItem _asLine(CatalogueProduct product, OrderItem unavailable) {
    return OrderItem(
      lineId: unavailable.lineId,
      productId: product.id,
      name: product.name,
      brand: product.brand,
      packSize: product.packSize,
      quantity: unavailable.quantity,
      unitPrice: product.price,
      categoryId: product.categoryId,
      category: product.categoryName,
      description: product.description,
      imageUrl: product.coverImageUrl,
    );
  }
}
