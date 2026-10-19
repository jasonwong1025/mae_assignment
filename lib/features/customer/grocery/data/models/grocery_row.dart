import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_matcher.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';

part 'grocery_row.freezed.dart';

/// A list item together with the product it means at the customer's store.
/// Worked out every time the list or the catalogue changes, never saved.
@freezed
abstract class GroceryRow with _$GroceryRow {
  const factory GroceryRow({
    required GroceryItem item,

    /// The product that would be added to the cart: the one the customer
    /// picked, or the best match in stock. Null when there is none.
    CatalogueProduct? product,

    /// True when something fits the item but it is sold out here.
    @Default(false) bool soldOut,

    /// Other products that might be what the customer meant, best first.
    @Default(<CatalogueProduct>[]) List<CatalogueProduct> candidates,
  }) = _GroceryRow;

  const GroceryRow._();

  /// Finds the product for [item] among the store's [products].
  factory GroceryRow.resolve(
    GroceryItem item,
    List<CatalogueProduct> products,
  ) {
    final candidates = [
      for (final match in GroceryMatcher.rank(item.name, products, limit: 8))
        match.product,
    ];

    // A product the customer picked wins, unless it is no longer sold here.
    final chosenId = item.productId;
    final chosen = chosenId == null
        ? null
        : products.where((p) => p.id == chosenId).firstOrNull;
    if (chosen != null) {
      return GroceryRow(
        item: item,
        product: chosen.isOutOfStock ? null : chosen,
        soldOut: chosen.isOutOfStock,
        candidates: [
          chosen,
          for (final other in candidates)
            if (other.id != chosen.id) other,
        ],
      );
    }

    final best = GroceryMatcher.best(item.name, products);
    return GroceryRow(
      item: item,
      product: best,
      soldOut: best == null && candidates.isNotEmpty,
      candidates: candidates,
    );
  }

  /// True if the item can go to the cart.
  bool get isMatched => product != null;

  /// How many go to the cart: what was asked for, up to the stock.
  int get quantityToAdd {
    final matched = product;
    if (matched == null) return 0;
    return item.quantity < matched.stock ? item.quantity : matched.stock;
  }
}
