import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

part 'cart.freezed.dart';

/// How the customer wants the order fulfilled.
enum FulfilmentMethod {
  delivery('Delivery'),
  pickup('Self pickup');

  const FulfilmentMethod(this.label);

  final String label;
}

/// One product in the cart with its chosen quantity. Carries the product
/// snapshot (name, price, stock) taken when it was added, so the cart can
/// show line totals without re-reading the catalogue.
@freezed
abstract class CartLine with _$CartLine {
  const factory CartLine({
    required CatalogueProduct product,
    required int quantity,
  }) = _CartLine;

  const CartLine._();

  /// Price for this line: unit price times quantity.
  double get lineTotal => product.price * quantity;

  /// True when the chosen quantity has reached the product's stock, so the
  /// customer cannot add more.
  bool get atStockLimit => quantity >= product.stock;
}

/// The customer's cart: the lines, the chosen fulfilment method, and any
/// applied promo. Immutable; the view model replaces it on every change.
@freezed
abstract class Cart with _$Cart {
  const factory Cart({
    @Default(<CartLine>[]) List<CartLine> lines,
    @Default(FulfilmentMethod.delivery) FulfilmentMethod fulfilment,

    /// Applied promo code, uppercased, or null if none.
    String? promoCode,
  }) = _Cart;

  const Cart._();

  /// A fixed first-order promo from the wireframe: RM5 off with FRESH5.
  static const String promoFresh5 = 'FRESH5';
  static const double _fresh5Discount = 5;

  /// A flat delivery fee for now; a distance-based fee comes with the
  /// address picker. Pickup is free.
  static const double _deliveryFee = 3;

  bool get isEmpty => lines.isEmpty;

  /// Total number of items, counting quantities.
  int get itemCount {
    var count = 0;
    for (final line in lines) {
      count += line.quantity;
    }
    return count;
  }

  /// Sum of every line total, before fees and discounts.
  double get subtotal {
    var total = 0.0;
    for (final line in lines) {
      total += line.lineTotal;
    }
    return total;
  }

  /// A flat delivery fee used only as a fallback: before an address is
  /// chosen, the real fee (distance-based, from the branch) is not known.
  /// Pickup is always free. Prefer [deliveryFeeFor] / [totalWith] once a
  /// quote is available.
  double get deliveryFee {
    return fulfilment == FulfilmentMethod.delivery ? _deliveryFee : 0;
  }

  /// The delivery fee to charge given a [quotedFee] from the branch's
  /// distance-based pricing. Pickup is always free, so the quote is ignored.
  double deliveryFeeFor(double quotedFee) {
    return fulfilment == FulfilmentMethod.delivery ? quotedFee : 0;
  }

  /// Discount from the applied promo, never more than the subtotal.
  double get discount {
    if (promoCode != promoFresh5) return 0;
    return _fresh5Discount.clamp(0, subtotal).toDouble();
  }

  /// What the customer pays with the flat fallback fee. Prefer [totalWith].
  double get total => totalWith(deliveryFee);

  /// What the customer pays given a specific delivery fee: subtotal plus
  /// that fee, less any discount, never below zero.
  double totalWith(double fee) {
    final value = subtotal + deliveryFeeFor(fee) - discount;
    return value < 0 ? 0 : value;
  }

  /// The quantity of [productId] in the cart, or 0 if it is not in the cart.
  int quantityOf(String productId) {
    for (final line in lines) {
      if (line.product.id == productId) return line.quantity;
    }
    return 0;
  }
}
