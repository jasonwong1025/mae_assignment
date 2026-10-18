import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/repositories/inventory_repository.dart';

import '../../helpers/fake_image_picker_service.dart';
import '../../helpers/fake_inventory.dart';

void main() {
  late FakeInventoryService service;
  late FakeProductPhotoService photos;
  late InventoryRepository repository;

  setUp(() {
    service = FakeInventoryService();
    photos = FakeProductPhotoService();
    repository = fakeInventoryRepository(service: service, photos: photos);
  });

  Future<void> add({
    List<ProductPhoto> photos = const [],
    String name = 'Kaya',
  }) {
    return repository.addProduct(
      name: name,
      brand: 'Yeos',
      categoryId: 'pantry',
      packSize: '300g',
      description: '',
      lowStockLevel: 5,
      photos: photos,
      branchId: 'ss15',
      price: 13.9,
      stock: 12,
    );
  }

  group('getItems', () {
    test(
      'lists a product with no row at the branch as hidden, no stock',
      () async {
        // Remove one sample row, as a product the branch has never stocked.
        final id = service.products.keys.first;
        service.stock['ss15']!.remove(id);

        final items = (await repository.getItems('ss15')).items;
        final unlisted = items.singleWhere((item) => item.product.id == id);

        expect(unlisted.isHidden, isTrue);
        expect(unlisted.stock, 0);
        expect(unlisted.price, 0);
      },
    );

    test('sorts categories by their order, then name', () async {
      service.categories
        ..clear()
        ..addAll(const [
          ProductCategory(id: 'b', name: 'Bakery', sortOrder: 1),
          ProductCategory(id: 'a', name: 'Dairy'),
          ProductCategory(id: 'c', name: 'Apples', sortOrder: 1),
        ]);

      final names = (await repository.getCategories()).map((c) => c.name);

      expect(names, ['Dairy', 'Apples', 'Bakery']);
    });
  });

  group('addProduct', () {
    test('uploads picked photos and saves their URLs', () async {
      await add(
        photos: [
          ProductPhoto.picked(Uint8List.fromList([1, 2])),
        ],
      );

      final saved = service.products.values.singleWhere(
        (p) => p.name == 'Kaya',
      );
      expect(photos.uploaded, hasLength(1));
      expect(saved.photos, [ProductPhoto.stored(photos.uploaded.single)]);
    });

    test('puts the stock at the chosen branch and 0 elsewhere', () async {
      await add();

      final kaya = service.products.values.singleWhere((p) => p.name == 'Kaya');
      expect(service.stock['ss15']![kaya.id]?.stock, 12);
      expect(service.stock['bukit-jalil']![kaya.id]?.stock, 0);
      expect(service.stock['puchong']![kaya.id]?.price, 13.9);
    });

    test('refuses a duplicate name, brand and pack size', () async {
      await add();

      await expectLater(add(), throwsA(isA<InventoryException>()));
    });

    test('a failed upload saves nothing and says why', () async {
      photos.failUploads = true;
      final before = service.products.length;

      await expectLater(
        add(
          photos: [
            ProductPhoto.picked(Uint8List.fromList([1])),
          ],
        ),
        throwsA(
          isA<InventoryException>().having(
            (e) => e.message,
            'message',
            contains('Could not upload the photos'),
          ),
        ),
      );
      expect(service.products.length, before);
    });

    test('removes uploaded photos when the product cannot be saved', () async {
      final failing = _FailingCreateService();
      final repo = fakeInventoryRepository(service: failing, photos: photos);

      await expectLater(
        repo.addProduct(
          name: 'Kaya',
          brand: 'Yeos',
          categoryId: 'pantry',
          packSize: '300g',
          description: '',
          lowStockLevel: 5,
          photos: [
            ProductPhoto.picked(Uint8List.fromList([1])),
          ],
          branchId: 'ss15',
          price: 1,
          stock: 1,
        ),
        throwsA(isA<InventoryException>()),
      );

      expect(photos.deleted, photos.uploaded);
    });
  });

  group('updateItem', () {
    Future<InventoryItem> firstItem() async {
      return (await repository.getItems('ss15')).items.first;
    }

    test('removed photos are deleted once the product is saved', () async {
      final item = await firstItem();
      await service.updateProduct(
        item.product.copyWith(
          photos: const [
            ProductPhoto.stored('https://photos.test/old-1.jpg'),
            ProductPhoto.stored('https://photos.test/old-2.jpg'),
          ],
        ),
      );
      final withPhotos = (await repository.getItems(
        'ss15',
      )).items.firstWhere((i) => i.product.id == item.product.id);

      await repository.updateItem(
        withPhotos.copyWith(
          product: withPhotos.product.copyWith(
            photos: [
              const ProductPhoto.stored('https://photos.test/old-1.jpg'),
              ProductPhoto.picked(Uint8List.fromList([9])),
            ],
          ),
        ),
      );

      expect(photos.deleted, ['https://photos.test/old-2.jpg']);
      final saved = service.products[item.product.id]!;
      expect(saved.storedUrls, [
        'https://photos.test/old-1.jpg',
        photos.uploaded.single,
      ]);
    });

    test('price, stock and hidden change at this branch only', () async {
      final item = await firstItem();

      await repository.updateItem(
        item.copyWith(price: 99, stock: 1, isHidden: true),
      );

      expect(service.stock['ss15']![item.product.id]?.price, 99);
      expect(service.stock['bukit-jalil']![item.product.id]?.price, isNot(99));
    });

    test('a failed upload keeps the saved product as it was', () async {
      final item = await firstItem();
      photos.failUploads = true;

      await expectLater(
        repository.updateItem(
          item.copyWith(
            product: item.product.copyWith(
              name: 'Renamed',
              photos: [
                ProductPhoto.picked(Uint8List.fromList([1])),
              ],
            ),
          ),
        ),
        throwsA(isA<InventoryException>()),
      );

      expect(service.products[item.product.id]?.name, item.product.name);
    });
  });

  group('addBranch', () {
    test('gives the new branch every product at 0 stock', () async {
      final before = (await repository.getItems('ss15')).totalCount;

      await repository.addBranch('new-branch');

      final stock = service.stock['new-branch']!;
      expect(stock.length, before);
      expect(
        stock.values.every((row) => row.stock == 0 && !row.isHidden),
        isTrue,
      );
    });
  });

  group('categories', () {
    test('a new category sorts last and names must be unique', () async {
      final added = await repository.addCategory('Garden');

      final all = await repository.getCategories();
      expect(all.last, added);
      await expectLater(
        repository.addCategory('garden'),
        throwsA(isA<InventoryException>()),
      );
    });
  });

  test(
    'picking photos reports a friendly error when the picker fails',
    () async {
      final repo = fakeInventoryRepository(imagePicker: _BrokenPicker());

      await expectLater(repo.pickPhotos(2), throwsA(isA<InventoryException>()));
    },
  );
}

class _FailingCreateService extends FakeInventoryService {
  @override
  Future<void> createProduct(
    Product product,
    Map<String, BranchStock> stockByBranch,
  ) {
    throw Exception('denied');
  }
}

class _BrokenPicker extends FakeImagePickerService {
  @override
  Future<List<Uint8List>> pickPhotos(int limit) {
    throw Exception('no gallery');
  }
}
