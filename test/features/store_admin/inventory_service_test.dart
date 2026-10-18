import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/services/inventory_service.dart';

const _milk = Product(
  id: 'p1',
  name: 'Fresh milk',
  brand: 'Farm',
  categoryId: 'dairy',
  packSize: '1L',
  description: 'Full cream',
  lowStockLevel: 6,
  photos: [ProductPhoto.stored('https://photos.test/p1/a.jpg')],
);

void main() {
  late FakeFirebaseFirestore firestore;
  late InventoryService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = InventoryService(firestore);
  });

  Future<Map<String, dynamic>> raw(String path) async {
    return (await firestore.doc(path).get()).data()!;
  }

  test('createProduct saves the product and a row at every branch', () async {
    await service.createProduct(_milk, {
      'ss15': const BranchStock(price: 8.9, stock: 12, isHidden: false),
      'puchong': const BranchStock(price: 8.9, stock: 0, isHidden: false),
    });

    final product = await raw('products/p1');
    expect(product[ProductFields.name], 'Fresh milk');
    expect(product[ProductFields.lowStockLevel], 6);
    expect(product[ProductFields.imageUrls], ['https://photos.test/p1/a.jpg']);
    expect(product.containsKey('id'), isFalse);
    expect(
      (await raw('branches/ss15/inventory/p1'))[InventoryFields.stock],
      12,
    );
    expect(
      (await raw('branches/puchong/inventory/p1'))[InventoryFields.stock],
      0,
    );
  });

  test('getProducts and getProduct read back what was saved', () async {
    await service.createProduct(_milk, const {});

    expect((await service.getProducts()).single, _milk);
    expect(await service.getProduct('p1'), _milk);
    expect(await service.getProduct('missing'), isNull);
  });

  test(
    'getProducts reads a seeded product that has no low-stock level',
    () async {
      await firestore.collection('products').doc('seed').set({
        ProductFields.name: 'Seed rice',
        ProductFields.categoryId: 'pantry',
      });

      final product = (await service.getProducts()).single;

      expect(product.lowStockLevel, Product.defaultLowStockLevel);
      expect(product.photos, isEmpty);
    },
  );

  test('getProducts skips a product without a name', () async {
    await service.createProduct(_milk, const {});
    await firestore.collection('products').doc('bad').set({'brand': 'X'});

    expect((await service.getProducts()).map((p) => p.id), ['p1']);
  });

  test('updateProduct replaces the details', () async {
    await service.createProduct(_milk, const {});

    await service.updateProduct(
      _milk.copyWith(name: 'Fresh milk 2L', photos: const []),
    );

    final product = await raw('products/p1');
    expect(product[ProductFields.name], 'Fresh milk 2L');
    expect(product[ProductFields.imageUrls], isEmpty);
  });

  test('saveBranchStock and getBranchStock round-trip a row', () async {
    await service.saveBranchStock(
      'ss15',
      'p1',
      const BranchStock(price: 9.5, stock: 3, isHidden: true),
    );

    final stock = await service.getBranchStock('ss15');

    expect(
      stock['p1'],
      const BranchStock(price: 9.5, stock: 3, isHidden: true),
    );
    expect(await service.getBranchStock('empty-branch'), isEmpty);
  });

  test('getBranchStock skips a row without a price', () async {
    await firestore
        .collection('branches')
        .doc('ss15')
        .collection('inventory')
        .doc('bad')
        .set({InventoryFields.stock: 4});

    expect(await service.getBranchStock('ss15'), isEmpty);
  });

  test('createCategory saves a name and sort order under a new id', () async {
    final category = await service.createCategory('Drinks', 4);

    expect(category.id, isNotEmpty);
    expect(await raw('categories/${category.id}'), {
      CategoryFields.name: 'Drinks',
      CategoryFields.sortOrder: 4,
    });
    expect((await service.getCategories()).single, category);
  });

  group('copyBranchStock', () {
    setUp(() async {
      await service.saveBranchStock(
        'ss15',
        'p1',
        const BranchStock(price: 8.9, stock: 12, isHidden: true),
      );
      await service.saveBranchStock(
        'ss15',
        'p2',
        const BranchStock(price: 4, stock: 5, isHidden: false),
      );
    });

    test('gives the new branch every product at 0 stock and visible', () async {
      final copied = await service.copyBranchStock(
        fromBranchId: 'ss15',
        toBranchId: 'new',
      );

      expect(copied, 2);
      final stock = await service.getBranchStock('new');
      expect(
        stock['p1'],
        const BranchStock(price: 8.9, stock: 0, isHidden: false),
      );
      expect(
        stock['p2'],
        const BranchStock(price: 4, stock: 0, isHidden: false),
      );
    });

    test('leaves rows the branch already has alone', () async {
      await service.saveBranchStock(
        'new',
        'p1',
        const BranchStock(price: 1, stock: 99, isHidden: false),
      );

      final copied = await service.copyBranchStock(
        fromBranchId: 'ss15',
        toBranchId: 'new',
      );

      expect(copied, 1);
      expect((await service.getBranchStock('new'))['p1']?.stock, 99);
    });

    test('copies nothing from a branch with no rows', () async {
      expect(
        await service.copyBranchStock(fromBranchId: 'none', toBranchId: 'new'),
        0,
      );
    });
  });
}
