import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
}

/// The cart as saved in Firestore at users/{uid}/cart/current.
@freezed
abstract class StoredCart with _$StoredCart {
  const factory StoredCart({
    @Default(<StoredCartLine>[]) List<StoredCartLine> lines,
    @Default(FulfilmentMethod.delivery) FulfilmentMethod fulfilment,
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

  /// Reads a saved cart. Malformed lines are skipped, so one bad entry
  /// never blocks the rest of the cart from loading.
  factory StoredCart.fromFirestore(Map<String, dynamic> data) {
    final rawLines = data[CartFields.lines];
    final lines = <StoredCartLine>[];
    if (rawLines is List) {
      for (final raw in rawLines) {
        if (raw is! Map) continue;
        final productId = raw[CartLineFields.productId];
        final quantity = raw[CartLineFields.quantity];
        if (productId is String && productId.isNotEmpty && quantity is num) {
          final whole = quantity.toInt();
          if (whole > 0) {
            lines.add(StoredCartLine(productId: productId, quantity: whole));
          }
        }
      }
    }

    final fulfilmentName = data[CartFields.fulfilment];
    return StoredCart(
      lines: lines,
      fulfilment: FulfilmentMethod.values.firstWhere(
        (method) => method.name == fulfilmentName,
        orElse: () => FulfilmentMethod.delivery,
      ),
      promoCode: data[CartFields.promoCode] as String?,
    );
  }

  /// The Firestore map. [CartFields.promoCode] is left out when there is no
  /// promo, so it is removed from the saved document too.
  Map<String, dynamic> toMap() {
    return {
      CartFields.lines: [
        for (final line in lines)
          {
            CartLineFields.productId: line.productId,
            CartLineFields.quantity: line.quantity,
          },
      ],
      CartFields.fulfilment: fulfilment.name,
      CartFields.promoCode: ?promoCode,
      CartFields.updatedAt: FieldValue.serverTimestamp(),
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
