import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

/// The customer's cart. Not autoDispose: it must survive moving between
/// tabs (Home, Cart, Orders) and is only cleared when an order is placed.
/// In memory for now; it will be persisted per user in a later slice.
final NotifierProvider<CartViewModel, Cart> cartViewModelProvider =
    NotifierProvider<CartViewModel, Cart>(CartViewModel.new);

/// Number of items in the cart, for the bottom-navigation badge.
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartViewModelProvider).itemCount;
});

/// Adds, removes and re-counts cart lines, and holds the chosen fulfilment
/// method and promo. Quantities never exceed the product's stock.
class CartViewModel extends Notifier<Cart> {
  @override
  Cart build() => const Cart();

  /// Adds one of [product], up to its stock. No-op when out of stock or
  /// already at the stock limit.
  void add(CatalogueProduct product) {
    if (product.isOutOfStock) return;
    final current = state.quantityOf(product.id);
    if (current >= product.stock) return;
    _setQuantity(product, current + 1);
  }

  /// Removes one of [product]; drops the line at zero.
  void removeOne(CatalogueProduct product) {
    final current = state.quantityOf(product.id);
    if (current <= 0) return;
    _setQuantity(product, current - 1);
  }

  /// Sets the quantity of [product] directly, clamped to 0..stock.
  void setQuantity(CatalogueProduct product, int quantity) {
    _setQuantity(product, quantity.clamp(0, product.stock));
  }

  /// Removes the whole line for [productId].
  void removeLine(String productId) {
    state = state.copyWith(
      lines: [
        for (final line in state.lines)
          if (line.product.id != productId) line,
      ],
    );
  }

  void setFulfilment(FulfilmentMethod method) {
    state = state.copyWith(fulfilment: method);
  }

  /// Applies [code] (case-insensitive). Returns true if it is a known code.
  bool applyPromo(String code) {
    final normalised = code.trim().toUpperCase();
    if (normalised != Cart.promoFresh5) return false;
    state = state.copyWith(promoCode: normalised);
    return true;
  }

  void removePromo() => state = state.copyWith(promoCode: null);

  /// Empties the cart (e.g. after an order is placed).
  void clear() => state = const Cart();

  void _setQuantity(CatalogueProduct product, int quantity) {
    if (quantity <= 0) {
      removeLine(product.id);
      return;
    }

    final existing = state.lines.any((line) => line.product.id == product.id);
    state = state.copyWith(
      lines: existing
          ? [
              for (final line in state.lines)
                if (line.product.id == product.id)
                  line.copyWith(product: product, quantity: quantity)
                else
                  line,
            ]
          : [...state.lines, CartLine(product: product, quantity: quantity)],
    );
  }
}
