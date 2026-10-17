import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

void main() {
  CatalogueProduct product({int stock = 50, List<String> images = const []}) {
    return CatalogueProduct(
      id: 'p1',
      name: 'Apple',
      brand: 'Fuji',
      categoryId: 'produce',
      packSize: '1kg',
      price: 3.5,
      stock: stock,
      imageUrls: images,
    );
  }

  group('stock helpers', () {
    test('isOutOfStock is true only at zero or below', () {
      expect(product(stock: 0).isOutOfStock, isTrue);
      expect(product(stock: 1).isOutOfStock, isFalse);
    });

    test('lowStockRemaining shows 1..10, otherwise null', () {
      expect(product(stock: 0).lowStockRemaining, isNull);
      expect(product(stock: 9).lowStockRemaining, 9);
      expect(product(stock: 10).lowStockRemaining, 10);
      expect(product(stock: 11).lowStockRemaining, isNull);
    });
  });

  group('coverImageUrl', () {
    test('is the first image, or null when there are none', () {
      expect(product().coverImageUrl, isNull);
      expect(product(images: ['a.png', 'b.png']).coverImageUrl, 'a.png');
    });
  });

  group('fromFirestore', () {
    test('builds a product from product + inventory documents', () {
      final result = CatalogueProduct.fromFirestore(
        id: 'p1',
        product: {
          'name': 'Apple',
          'brand': 'Fuji',
          'categoryId': 'produce',
          'packSize': '1kg',
          'imageUrls': ['a.png', '', 42],
        },
        inventory: {'price': 3.5, 'stock': 20},
      );

      expect(result, isNotNull);
      expect(result!.name, 'Apple');
      expect(result.price, 3.5);
      expect(result.stock, 20);
      // Non-string and empty entries are dropped.
      expect(result.imageUrls, ['a.png']);
    });

    test('returns null when hidden', () {
      final result = CatalogueProduct.fromFirestore(
        id: 'p1',
        product: {'name': 'Apple'},
        inventory: {'price': 3.5, 'stock': 20, 'isHidden': true},
      );
      expect(result, isNull);
    });

    test('returns null when required fields are missing', () {
      expect(
        CatalogueProduct.fromFirestore(
          id: 'p1',
          product: {'brand': 'Fuji'}, // no name
          inventory: {'price': 3.5, 'stock': 20},
        ),
        isNull,
      );
      expect(
        CatalogueProduct.fromFirestore(
          id: 'p1',
          product: {'name': 'Apple'},
          inventory: {'stock': 20}, // no price
        ),
        isNull,
      );
    });
  });
}
