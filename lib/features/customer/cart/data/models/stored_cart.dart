import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

part 'stored_cart.freezed.dart';

/// One saved cart line: only the product id and quantity. Everything else
/// (name, price, stock) is looked up in the catalogue when the cart loads.
@freezed
abstract class StoredCartLine with _$StoredCartLine {
  const factory StoredCartLine({
    required String productId,
    required int quantity,
  }) = _StoredCartLine;

  const StoredCartLine._();

  /// Reads one entry of the cart's `lines` array.
  factory StoredCartLine.fromMap(Map<String, dynamic> map) {
    return StoredCartLine(
      productId: map.string(CartLineFields.productId),
      quantity: map.integer(CartLineFields.quantity),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CartLineFields.productId: productId,
      CartLineFields.quantity: quantity,
    };
  }
}

/// The cart as saved in Firestore at users/{uid}/cart/current.
@freezed
abstract class StoredCart with _$StoredCart {
  const factory StoredCart({
    @Default(<StoredCartLine>[]) List<StoredCartLine> lines,
    @Default(FulfilmentMethod.delivery) FulfilmentMethod fulfilment,

    /// Promo code applied, uppercased. Null when none.
    String? promoCode,
  }) = _StoredCart;

  const StoredCart._();

  /// The part of [cart] worth saving.
  factory StoredCart.fromCart(Cart cart) {
    return StoredCart(
      lines: [
        for (final line in cart.lines)
          StoredCartLine(productId: line.product.id, quantity: line.quantity),
      ],
      fulfilment: cart.fulfilment,
      promoCode: cart.promoCode,
    );
  }

  /// Reads users/{uid}/cart/current (the document has no id of its own).
  /// Lines without a product or quantity are skipped, so one bad line never
  /// blocks the rest of the cart from loading.
  factory StoredCart.fromMap(Map<String, dynamic> map) {
    return StoredCart(
      lines: [
        for (final raw in map.maps(CartFields.lines))
          if (StoredCartLine.fromMap(raw) case final line
              when line.productId.isNotEmpty && line.quantity > 0)
            line,
      ],
      fulfilment: map.enumValue(
        CartFields.fulfilment,
        FulfilmentMethod.values,
        fallback: FulfilmentMethod.delivery,
      ),
      promoCode: map.stringOrNull(CartFields.promoCode),
    );
  }

  /// Fields saved in the cart document. A missing promo is left out, so it
  /// is removed from the saved document too. `updatedAt` is added by the
  /// service with the server time.
  Map<String, dynamic> toMap() {
    return {
      CartFields.lines: [for (final line in lines) line.toMap()],
      CartFields.fulfilment: fulfilment.name,
      if (promoCode != null) CartFields.promoCode: promoCode,
    };
  }

  bool get isEmpty => lines.isEmpty;

  /// Rebuilds a [Cart] against the current catalogue. Products that are no
  /// longer sold (or are out of stock) at the branch are dropped, and
  /// quantities are capped at the branch's stock. Unknown promo codes are
  /// ignored.
  Cart resolve(List<CatalogueProduct> catalogue) {
    final byId = {for (final product in catalogue) product.id: product};
    final resolved = <CartLine>[];
    for (final line in lines) {
      final product = byId[line.productId];
      if (product == null || product.isOutOfStock) continue;
      final quantity = line.quantity.clamp(1, product.stock);
      resolved.add(CartLine(product: product, quantity: quantity));
    }
    return Cart(
      lines: resolved,
      fulfilment: fulfilment,
      promoCode: promoCode == Cart.promoFresh5 ? promoCode : null,
    );
  }
}
