import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/data/services/catalogue_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogueService extends Mock implements CatalogueService {}

void main() {
  late _MockCatalogueService service;
  late CatalogueRepository repository;

  setUp(() {
    service = _MockCatalogueService();
    repository = CatalogueRepository(service);
  });

  void stub({
    required Map<String, Map<String, dynamic>> products,
    required Map<String, Map<String, dynamic>> inventory,
    Map<String, Map<String, dynamic>> categories = const {},
  }) {
    when(service.fetchProducts).thenAnswer((_) async => products);
    when(
      () => service.fetchInventory(any()),
    ).thenAnswer((_) async => inventory);
    when(service.fetchCategories).thenAnswer((_) async => categories);
  }

  test('joins products with the branch inventory, sorted by name', () async {
    stub(
      products: {
        'p2': {'name': 'Banana', 'brand': 'Dole', 'categoryId': 'produce'},
        'p1': {'name': 'Apple', 'brand': 'Fuji', 'categoryId': 'produce'},
      },
      inventory: {
        'p1': {'price': 3.5, 'stock': 20},
        'p2': {'price': 2.0, 'stock': 5},
      },
    );

    final data = await repository.loadCatalogue('ss15');

    expect(data.products.map((p) => p.name), ['Apple', 'Banana']);
    final apple = data.products.first;
    expect(apple.price, 3.5);
    expect(apple.stock, 20);
    expect(apple.brand, 'Fuji');
  });

  test('leaves out hidden products', () async {
    stub(
      products: {
        'p1': {'name': 'Apple'},
        'p2': {'name': 'Secret'},
      },
      inventory: {
        'p1': {'price': 3.5, 'stock': 10},
        'p2': {'price': 9.0, 'stock': 10, 'isHidden': true},
      },
    );

    final data = await repository.loadCatalogue('ss15');

    expect(data.products.map((p) => p.name), ['Apple']);
  });

  test('leaves out products with no inventory at the branch', () async {
    stub(
      products: {
        'p1': {'name': 'Apple'},
        'p2': {'name': 'Not stocked here'},
      },
      inventory: {
        'p1': {'price': 3.5, 'stock': 10},
      },
    );

    final data = await repository.loadCatalogue('ss15');

    expect(data.products.map((p) => p.name), ['Apple']);
  });

  test('leaves out malformed products (missing price or stock)', () async {
    stub(
      products: {
        'p1': {'name': 'Apple'},
        'p2': {'name': 'Broken'},
      },
      inventory: {
        'p1': {'price': 3.5, 'stock': 10},
        'p2': {'stock': 10}, // no price
      },
    );

    final data = await repository.loadCatalogue('ss15');

    expect(data.products.map((p) => p.name), ['Apple']);
  });

  test('sorts categories by sortOrder then name', () async {
    stub(
      products: const {},
      inventory: const {},
      categories: {
        'c1': {'name': 'Pantry', 'sortOrder': 2},
        'c2': {'name': 'Bakery', 'sortOrder': 1},
        'c3': {'name': 'Dairy', 'sortOrder': 1},
      },
    );

    final data = await repository.loadCatalogue('ss15');

    expect(data.categories.map((c) => c.name), ['Bakery', 'Dairy', 'Pantry']);
  });

  test('productsIn filters by category; null returns all', () async {
    stub(
      products: {
        'p1': {'name': 'Apple', 'categoryId': 'produce'},
        'p2': {'name': 'Milk', 'categoryId': 'dairy'},
      },
      inventory: {
        'p1': {'price': 3.5, 'stock': 10},
        'p2': {'price': 6.0, 'stock': 10},
      },
    );

    final data = await repository.loadCatalogue('ss15');

    expect(data.productsIn('produce').map((p) => p.name), ['Apple']);
    expect(data.productsIn(null).map((p) => p.name), ['Apple', 'Milk']);
  });

  test('wraps a Firestore failure in a friendly CatalogueException', () async {
    when(service.fetchProducts).thenThrow(Exception('offline'));

    await expectLater(
      repository.loadCatalogue('ss15'),
      throwsA(
        isA<CatalogueException>().having(
          (e) => e.message,
          'message',
          contains('Could not load the store'),
        ),
      ),
    );
  });

  group('hasProducts', () {
    test('is true when something visible is in stock', () async {
      stub(
        products: const {},
        inventory: {
          'p1': {'price': 3.5, 'stock': 0},
          'p2': {'price': 3.5, 'stock': 4},
        },
      );

      expect(await repository.hasProducts('ss15'), isTrue);
    });

    test('is false for an empty branch', () async {
      stub(products: const {}, inventory: const {});

      expect(await repository.hasProducts('puchong'), isFalse);
    });

    test('is false when everything is hidden or out of stock', () async {
      stub(
        products: const {},
        inventory: {
          'p1': {'price': 3.5, 'stock': 9, 'isHidden': true},
          'p2': {'price': 3.5, 'stock': 0},
        },
      );

      expect(await repository.hasProducts('ss15'), isFalse);
    });

    test('wraps a Firestore failure in a CatalogueException', () async {
      when(() => service.fetchInventory(any())).thenThrow(Exception('offline'));

      await expectLater(
        repository.hasProducts('ss15'),
        throwsA(isA<CatalogueException>()),
      );
    });
  });
}
