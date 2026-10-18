import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/data/models/stored_cart.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

CatalogueProduct _product(String id, {int stock = 20}) => CatalogueProduct(
  id: id,
  name: 'Product $id',
  brand: 'BrandCo',
  categoryId: 'produce',
  packSize: '1kg',
  price: 4,
  stock: stock,
);

void main() {
  group('fromFirestore', () {
    test('reads lines, fulfilment and promo', () {
      final cart = StoredCart.fromFirestore({
        CartFields.lines: [
          {CartLineFields.productId: 'p1', CartLineFields.quantity: 2},
        ],
        CartFields.fulfilment: 'pickup',
        CartFields.promoCode: 'FRESH5',
      });

      expect(cart.lines, [const StoredCartLine(productId: 'p1', quantity: 2)]);
      expect(cart.fulfilment, FulfilmentMethod.pickup);
      expect(cart.promoCode, 'FRESH5');
    });

    test('skips malformed lines and defaults an unknown fulfilment', () {
      final cart = StoredCart.fromFirestore({
        CartFields.lines: [
          'junk',
          {CartLineFields.productId: '', CartLineFields.quantity: 1},
          {CartLineFields.productId: 'p1', CartLineFields.quantity: 0},
          {CartLineFields.productId: 'p2', CartLineFields.quantity: 'x'},
          {CartLineFields.productId: 'p3', CartLineFields.quantity: 3},
        ],
        CartFields.fulfilment: 'drone',
      });

      expect(cart.lines, [const StoredCartLine(productId: 'p3', quantity: 3)]);
      expect(cart.fulfilment, FulfilmentMethod.delivery);
    });
  });

  test('toMap leaves out the promo when there is none', () {
    final map = const StoredCart(
      lines: [StoredCartLine(productId: 'p1', quantity: 2)],
    ).toMap();

    expect(map.containsKey(CartFields.promoCode), isFalse);
    expect(map[CartFields.fulfilment], 'delivery');
    expect(map[CartFields.lines], [
      {CartLineFields.productId: 'p1', CartLineFields.quantity: 2},
    ]);
  });

  test('fromCart keeps only ids and quantities', () {
    final stored = StoredCart.fromCart(
      Cart(
        lines: [CartLine(product: _product('p1'), quantity: 2)],
        fulfilment: FulfilmentMethod.pickup,
        promoCode: Cart.promoFresh5,
      ),
    );

    expect(stored.lines, [const StoredCartLine(productId: 'p1', quantity: 2)]);
    expect(stored.fulfilment, FulfilmentMethod.pickup);
    expect(stored.promoCode, Cart.promoFresh5);
  });

  group('resolve', () {
    test('uses current catalogue data, caps stock, drops unavailable', () {
      final cart = const StoredCart(
        lines: [
          StoredCartLine(productId: 'p1', quantity: 5),
          StoredCartLine(productId: 'p2', quantity: 1),
          StoredCartLine(productId: 'p3', quantity: 1),
        ],
      ).resolve([_product('p1', stock: 2), _product('p2', stock: 0)]);

      expect(cart.lines, hasLength(1));
      expect(cart.quantityOf('p1'), 2);
    });

    test('ignores an unknown promo code', () {
      final cart = const StoredCart(promoCode: 'NOPE').resolve(const []);

      expect(cart.promoCode, isNull);
    });
  });
}
