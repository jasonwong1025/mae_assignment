import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

CatalogueProduct _product(String id, {double price = 4, int stock = 20}) {
  return CatalogueProduct(
    id: id,
    name: 'Product $id',
    brand: 'BrandCo',
    categoryId: 'produce',
    packSize: '1kg',
    price: price,
    stock: stock,
  );
}

void main() {
  late ProviderContainer container;
  CartViewModel notifier() => container.read(cartViewModelProvider.notifier);
  Cart cart() => container.read(cartViewModelProvider);

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('adding and removing', () {
    test('starts empty', () {
      expect(cart().isEmpty, isTrue);
      expect(cart().itemCount, 0);
    });

    test('add increments the line and item count', () {
      final apple = _product('p1');
      notifier()
        ..add(apple)
        ..add(apple);

      expect(cart().itemCount, 2);
      expect(cart().quantityOf('p1'), 2);
      expect(cart().lines, hasLength(1));
    });

    test('removeOne drops the line at zero', () {
      final apple = _product('p1');
      notifier()
        ..add(apple)
        ..removeOne(apple);

      expect(cart().isEmpty, isTrue);
    });

    test('removeLine deletes the whole line', () {
      final apple = _product('p1');
      notifier()
        ..add(apple)
        ..add(apple)
        ..removeLine('p1');

      expect(cart().isEmpty, isTrue);
    });

    test('cannot add beyond stock', () {
      final scarce = _product('p1', stock: 2);
      notifier()
        ..add(scarce)
        ..add(scarce)
        ..add(scarce); // third add ignored

      expect(cart().quantityOf('p1'), 2);
    });

    test('out-of-stock products are never added', () {
      notifier().add(_product('p1', stock: 0));
      expect(cart().isEmpty, isTrue);
    });

    test('setQuantity clamps to 0..stock', () {
      final product = _product('p1', stock: 5);
      notifier().setQuantity(product, 99);
      expect(cart().quantityOf('p1'), 5);

      notifier().setQuantity(product, 0);
      expect(cart().quantityOf('p1'), 0);
    });

    test('clear empties everything', () {
      notifier()
        ..add(_product('p1'))
        ..add(_product('p2'))
        ..clear();
      expect(cart().isEmpty, isTrue);
    });
  });

  group('totals', () {
    test('subtotal sums line totals', () {
      notifier()
        ..add(_product('p1', price: 3)) // 3
        ..add(_product('p2', price: 2.5)) // 2.5
        ..add(_product('p2', price: 2.5)); // +2.5

      expect(cart().subtotal, closeTo(8.0, 0.001));
    });

    test('delivery adds a fee; pickup is free', () {
      notifier().add(_product('p1', price: 10));
      expect(cart().fulfilment, FulfilmentMethod.delivery);
      expect(cart().deliveryFee, greaterThan(0));
      expect(cart().total, closeTo(cart().subtotal + cart().deliveryFee, 0.01));

      notifier().setFulfilment(FulfilmentMethod.pickup);
      expect(cart().deliveryFee, 0);
      expect(cart().total, closeTo(cart().subtotal, 0.01));
    });

    test('FRESH5 promo takes RM5 off, case-insensitive', () {
      notifier().add(_product('p1', price: 20));
      final applied = notifier().applyPromo('fresh5');

      expect(applied, isTrue);
      expect(cart().promoCode, 'FRESH5');
      expect(cart().discount, 5);
      expect(
        cart().total,
        closeTo(cart().subtotal + cart().deliveryFee - 5, 0.01),
      );
    });

    test('an unknown promo is rejected and not applied', () {
      notifier().add(_product('p1', price: 20));
      final applied = notifier().applyPromo('BOGUS');

      expect(applied, isFalse);
      expect(cart().promoCode, isNull);
      expect(cart().discount, 0);
    });

    test('discount never exceeds the subtotal; total never negative', () {
      notifier()
        ..add(_product('p1', price: 1)) // subtotal 1
        ..setFulfilment(FulfilmentMethod.pickup) // no fee
        ..applyPromo('FRESH5'); // 5 off, clamped to 1

      expect(cart().discount, 1);
      expect(cart().total, 0);
    });

    test('removePromo clears the discount', () {
      notifier()
        ..add(_product('p1', price: 20))
        ..applyPromo('FRESH5')
        ..removePromo();
      expect(cart().discount, 0);
    });
  });

  group('cartCountProvider', () {
    test('reflects the item count', () {
      expect(container.read(cartCountProvider), 0);
      notifier()
        ..add(_product('p1'))
        ..add(_product('p1'));
      expect(container.read(cartCountProvider), 2);
    });
  });
}
