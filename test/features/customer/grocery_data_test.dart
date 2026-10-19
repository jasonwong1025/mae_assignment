import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_item.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_row.dart';
import 'package:mae_assignment/features/customer/grocery/data/repositories/grocery_list_repository.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/grocery_list_service.dart';
import 'package:mae_assignment/features/customer/grocery/data/services/list_scan_service.dart';

class _Scanner implements ListScanService {
  @override
  bool isSupported = true;
  String? text;
  ScanProblem? problem;

  @override
  Future<String?> scanText() async {
    if (problem case final failure?) throw ScanException(failure);
    return text;
  }
}

class _BrokenListService extends GroceryListService {
  _BrokenListService() : super(FakeFirebaseFirestore());

  @override
  Future<List<GroceryItem>> getItems(String uid) => throw Exception('offline');

  @override
  Future<void> saveItems(String uid, List<GroceryItem> items) =>
      throw Exception('offline');
}

CatalogueProduct _product(String id, String name, {int stock = 10}) {
  return CatalogueProduct(
    id: id,
    name: name,
    brand: 'Farm',
    categoryId: 'c',
    packSize: '1kg',
    price: 5,
    stock: stock,
  );
}

void main() {
  group('GroceryItem', () {
    test('survives a round trip through its map', () {
      const item = GroceryItem(
        id: 'a',
        name: 'milk',
        quantity: 3,
        productId: 'p1',
      );

      expect(GroceryItem.fromMap(item.toMap()), item);
    });

    test('leaves out the product when none was chosen', () {
      const item = GroceryItem(id: 'a', name: 'milk');

      expect(item.toMap().containsKey('productId'), isFalse);
      expect(GroceryItem.fromMap(item.toMap()).productId, isNull);
    });

    test('reads a bad quantity as 1', () {
      final item = GroceryItem.fromMap({
        'id': 'a',
        'name': 'milk',
        'quantity': 0,
      });

      expect(item.quantity, 1);
    });

    test('an entry without a name cannot be read', () {
      expect(
        () => GroceryItem.fromMap({'id': 'a', 'quantity': 1}),
        throwsFormatException,
      );
    });
  });

  group('GroceryListService', () {
    late FakeFirebaseFirestore firestore;
    late GroceryListService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = GroceryListService(firestore);
    });

    test('has an empty list until one is saved', () async {
      expect(await service.getItems('u1'), isEmpty);
    });

    test('saves and reads the list, with a server time', () async {
      await service.saveItems('u1', const [
        GroceryItem(id: 'a', name: 'milk', quantity: 2),
        GroceryItem(id: 'b', name: 'eggs'),
      ]);

      final items = await service.getItems('u1');
      expect(items.map((i) => '${i.quantity} ${i.name}'), ['2 milk', '1 eggs']);
      final raw = await firestore
          .collection('users')
          .doc('u1')
          .collection('groceryList')
          .doc('current')
          .get();
      expect(raw.data()!['updatedAt'], isNotNull);
    });

    test('is private to each user', () async {
      await service.saveItems('u1', const [GroceryItem(id: 'a', name: 'milk')]);

      expect(await service.getItems('u2'), isEmpty);
    });

    test('saving an empty list deletes the document', () async {
      await service.saveItems('u1', const [GroceryItem(id: 'a', name: 'milk')]);

      await service.saveItems('u1', const []);

      expect(await service.getItems('u1'), isEmpty);
      final raw = await firestore
          .collection('users')
          .doc('u1')
          .collection('groceryList')
          .doc('current')
          .get();
      expect(raw.exists, isFalse);
    });

    test('skips an entry it cannot read, keeping the rest', () async {
      await firestore
          .collection('users')
          .doc('u1')
          .collection('groceryList')
          .doc('current')
          .set({
            'items': [
              {'id': 'a', 'name': 'milk', 'quantity': 1},
              {'id': 'b'},
              {'id': 'c', 'name': 'eggs', 'quantity': 2},
            ],
          });

      final items = await service.getItems('u1');

      expect(items.map((i) => i.name), ['milk', 'eggs']);
    });
  });

  group('GroceryListRepository', () {
    late _Scanner scanner;
    late GroceryListRepository repository;

    setUp(() {
      scanner = _Scanner();
      repository = GroceryListRepository(
        GroceryListService(FakeFirebaseFirestore()),
        scanner,
      );
    });

    test('turns the scanned text into items', () async {
      scanner.text = '2x milk\n- eggs';

      final lines = await repository.scan();

      expect(lines!.map((l) => '${l.quantity} ${l.name}'), [
        '2 milk',
        '1 eggs',
      ]);
    });

    test(
      'a closed scanner gives null, an unreadable photo gives none',
      () async {
        scanner.text = null;
        expect(await repository.scan(), isNull);

        scanner.text = '--\n7';
        expect(await repository.scan(), isEmpty);
      },
    );

    test('explains why a scan could not be done', () async {
      scanner.problem = ScanProblem.unsupported;
      expect(
        repository.scan(),
        throwsA(
          isA<GroceryException>().having(
            (e) => e.message,
            'message',
            contains('needs an Android phone'),
          ),
        ),
      );

      scanner.problem = ScanProblem.failed;
      expect(
        repository.scan(),
        throwsA(
          isA<GroceryException>().having(
            (e) => e.message,
            'message',
            contains('could not be scanned'),
          ),
        ),
      );
    });

    test('knows whether the phone can scan', () {
      expect(repository.canScan, isTrue);
      scanner.isSupported = false;
      expect(repository.canScan, isFalse);
    });

    test('a failed load or save gives a friendly message', () async {
      final broken = GroceryListRepository(_BrokenListService(), scanner);

      expect(
        broken.load('u1'),
        throwsA(
          isA<GroceryException>().having(
            (e) => e.message,
            'message',
            contains('Could not load'),
          ),
        ),
      );
      expect(
        broken.save('u1', const []),
        throwsA(
          isA<GroceryException>().having(
            (e) => e.message,
            'message',
            contains('Could not save'),
          ),
        ),
      );
    });
  });

  group('GroceryRow.resolve', () {
    final products = [
      _product('milk', 'Fresh milk'),
      _product('oat', 'Oat milk'),
      _product('soldout', 'Brown rice', stock: 0),
      _product('few', 'Roma tomato', stock: 3),
    ];

    test('finds the best product in stock', () {
      final row = GroceryRow.resolve(
        const GroceryItem(id: 'a', name: 'fresh milk'),
        products,
      );

      expect(row.product!.id, 'milk');
      expect(row.isMatched, isTrue);
      expect(row.soldOut, isFalse);
    });

    test('the product the customer chose wins over the best match', () {
      final row = GroceryRow.resolve(
        const GroceryItem(id: 'a', name: 'milk', productId: 'oat'),
        products,
      );

      expect(row.product!.id, 'oat');
      expect(row.candidates.first.id, 'oat');
    });

    test('a chosen product that is sold out is reported, not swapped', () {
      final row = GroceryRow.resolve(
        const GroceryItem(id: 'a', name: 'milk', productId: 'soldout'),
        products,
      );

      expect(row.product, isNull);
      expect(row.soldOut, isTrue);
    });

    test(
      'a chosen product the store no longer sells falls back to a match',
      () {
        final row = GroceryRow.resolve(
          const GroceryItem(id: 'a', name: 'fresh milk', productId: 'gone'),
          products,
        );

        expect(row.product!.id, 'milk');
      },
    );

    test('says when everything that fits is sold out', () {
      final row = GroceryRow.resolve(
        const GroceryItem(id: 'a', name: 'brown rice'),
        products,
      );

      expect(row.product, isNull);
      expect(row.soldOut, isTrue);
    });

    test('says nothing fits for an unknown item', () {
      final row = GroceryRow.resolve(
        const GroceryItem(id: 'a', name: 'dragon fruit'),
        products,
      );

      expect(row.product, isNull);
      expect(row.soldOut, isFalse);
      expect(row.candidates, isEmpty);
    });

    test('the quantity to add never passes the stock', () {
      final row = GroceryRow.resolve(
        const GroceryItem(id: 'a', name: 'roma tomato', quantity: 8),
        products,
      );

      expect(row.quantityToAdd, 3);
      expect(
        GroceryRow.resolve(
          const GroceryItem(id: 'a', name: 'roma tomato', quantity: 2),
          products,
        ).quantityToAdd,
        2,
      );
      expect(
        GroceryRow.resolve(
          const GroceryItem(id: 'a', name: 'dragon fruit'),
          products,
        ).quantityToAdd,
        0,
      );
    });
  });
}
