import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/repositories/inventory_repository.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/product_card.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/view_models/inventory_filter_view_model.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/views/inventory_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import 'package:mae_assignment/features/store_admin/inventory/data/services/image_picker_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_image_picker_service.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// Shows the Inventory tab on a screen of [size].
Future<void> _pumpInventory(
  WidgetTester tester,
  Size size, {
  FakeImagePickerService? imagePicker,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = FakeAuthRepository()
    ..userToSignIn = _admin
    ..signedIn = true;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        imagePickerServiceProvider.overrideWithValue(
          imagePicker ?? FakeImagePickerService(),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const InventoryView()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Types [text] into the field labelled [label].
Future<void> _fill(WidgetTester tester, String label, String text) async {
  final field = find.descendant(
    of: find
        .ancestor(
          of: find.text(label.toUpperCase()),
          matching: find.byType(Column),
        )
        .first,
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
}

InventoryItem _item({int stock = 20, int low = 10, bool hidden = false}) {
  return InventoryItem(
    product: Product(
      id: 'p1',
      name: 'Fresh milk',
      brand: 'Farm Fresh',
      categoryId: 'dairy-eggs',
      packSize: '1L',
      description: '',
      lowStockLevel: low,
    ),
    branchId: 'ss15',
    price: 7.90,
    stock: stock,
    isHidden: hidden,
  );
}

void main() {
  const desktop = Size(1600, 900);
  // Tall enough to show a whole form.
  const tallDesktop = Size(1600, 1500);
  const phone = Size(390, 844);

  group('InventoryItem', () {
    test('stock status follows the low stock level', () {
      expect(_item(stock: 0).stockStatus, StockStatus.out);
      expect(_item(stock: 10).stockStatus, StockStatus.low);
      expect(_item(stock: 11).stockStatus, StockStatus.inStock);
    });
  });

  group('InventoryFilter', () {
    test('search matches name or brand', () {
      expect(
        const InventoryFilter(searchText: 'MILK').matches(_item()),
        isTrue,
      );
      expect(
        const InventoryFilter(searchText: 'farm').matches(_item()),
        isTrue,
      );
      expect(
        const InventoryFilter(searchText: 'rice').matches(_item()),
        isFalse,
      );
    });

    test('filters by category, stock and visibility', () {
      expect(
        const InventoryFilter(categoryId: 'bakery').matches(_item()),
        isFalse,
      );
      expect(
        const InventoryFilter(stockStatus: StockStatus.low).matches(_item()),
        isFalse,
      );
      expect(
        const InventoryFilter(
          visibility: VisibilityFilter.visible,
        ).matches(_item(hidden: true)),
        isFalse,
      );
    });
  });

  group('InventoryRepository', () {
    test('a new product is added to every branch', () async {
      final repository = InventoryRepository(FakeImagePickerService());
      await repository.addProduct(
        name: 'Butter',
        brand: 'Anchor',
        categoryId: 'dairy-eggs',
        packSize: '250g',
        description: '',
        lowStockLevel: 5,
        photos: const [],
        branchId: 'ss15',
        price: 13.90,
        stock: 12,
      );

      final here = await repository.getItems('ss15');
      final there = await repository.getItems('puchong');
      final butterHere = here.firstWhere((i) => i.product.name == 'Butter');
      final butterThere = there.firstWhere((i) => i.product.name == 'Butter');

      expect(butterHere.stock, 12);
      expect(butterThere.stock, 0);
      expect(butterThere.price, 13.90);
    });

    test('details change everywhere, price and stock only here', () async {
      final repository = InventoryRepository(FakeImagePickerService());
      final milk = (await repository.getItems(
        'ss15',
      )).firstWhere((i) => i.product.id == 'p1');

      await repository.updateItem(
        milk.copyWith(
          product: Product(
            id: 'p1',
            name: 'Full cream milk',
            brand: milk.product.brand,
            categoryId: milk.product.categoryId,
            packSize: milk.product.packSize,
            description: '',
            lowStockLevel: 10,
          ),
          price: 8.50,
          stock: 1,
        ),
      );

      final there = (await repository.getItems(
        'puchong',
      )).firstWhere((i) => i.product.id == 'p1');
      expect(there.product.name, 'Full cream milk');
      expect(there.price, 7.90);
      expect(there.stock, 25);
    });

    test('refuses a category name that exists', () async {
      expect(
        () =>
            InventoryRepository(FakeImagePickerService()).addCategory('bakery'),
        throwsA(isA<InventoryException>()),
      );
    });
  });

  testWidgets('Table shows the selected branch\'s price and stock', (
    tester,
  ) async {
    await _pumpInventory(tester, desktop);

    expect(find.text('Prices and stock at SS15 Subang'), findsOneWidget);
    expect(find.text('Fresh milk'), findsOneWidget);
    expect(find.text('Farm Fresh · 1L'), findsOneWidget);
    expect(find.text('RM 7.90'), findsOneWidget);

    // Oat milk has 0 at SS15.
    await tester.enterText(find.byType(TextField), 'oat');
    await tester.pumpAndSettle();
    expect(find.text('Out of stock'), findsOneWidget);
  });

  testWidgets('Switching branch changes the stock', (tester) async {
    await _pumpInventory(tester, desktop);
    await tester.enterText(find.byType(TextField), 'jasmine');
    await tester.pumpAndSettle();
    expect(find.text('RM 28.90'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Puchong'));
    await tester.pumpAndSettle();

    // Puchong sells it cheaper.
    expect(find.text('RM 27.50'), findsOneWidget);
  });

  testWidgets('Stock filter shows only products that are out', (tester) async {
    await _pumpInventory(tester, desktop);

    await tester.tap(find.byTooltip('Filter by stock'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Out of stock').last);
    await tester.pumpAndSettle();

    expect(find.text('Oat milk'), findsOneWidget);
    expect(find.text('Fresh milk'), findsNothing);
  });

  testWidgets('Saving stock updates the row and its status', (tester) async {
    await _pumpInventory(tester, desktop);

    await tester.enterText(find.byType(TextField), 'oat');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oat milk'));
    await tester.pumpAndSettle();
    expect(find.text('Save stock'), findsNothing);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Add one'));
      await tester.pump();
    }
    await tester.tap(find.text('Save stock'));
    await tester.pumpAndSettle();

    expect(find.text('Stock updated to 3.'), findsOneWidget);
    // 3 is low (level is 5). Shown in the row and the panel.
    expect(find.text('Low'), findsNWidgets(2));
    expect(find.text('Save stock'), findsNothing);
  });

  testWidgets('Hiding a product marks it hidden', (tester) async {
    await _pumpInventory(tester, desktop);

    await tester.tap(find.text('Fresh milk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide'));
    await tester.pumpAndSettle();

    expect(find.text('Fresh milk is now hidden.'), findsOneWidget);
    expect(find.text('Unhide'), findsOneWidget);
    expect(find.text('Hidden from customers at SS15 Subang.'), findsOneWidget);
  });

  testWidgets('Adding a product with a new category', (tester) async {
    await _pumpInventory(tester, tallDesktop);

    await tester.tap(find.text('Add product'));
    await tester.pumpAndSettle();

    await _fill(tester, 'Product name', 'Dog biscuits');
    await _fill(tester, 'Brand', 'Pedigree');
    await _fill(tester, 'Pack size', '500g');

    await tester.tap(find.text('New category'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Pets',
    );
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    await _fill(tester, 'Price (RM)', '15.50');
    await _fill(tester, 'Starting stock', '8');
    final save = find.widgetWithText(FilledButton, 'Add product').last;
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Dog biscuits was added.'), findsOneWidget);
    expect(find.text('Dog biscuits'), findsOneWidget);
    expect(find.text('Pets'), findsOneWidget);
    expect(find.text('RM 15.50'), findsOneWidget);
  });

  testWidgets('The add form needs a price and a category', (tester) async {
    await _pumpInventory(tester, tallDesktop);

    await tester.tap(find.text('Add product'));
    await tester.pumpAndSettle();
    await _fill(tester, 'Product name', 'Dog biscuits');
    final save = find.widgetWithText(FilledButton, 'Add product').last;
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Please choose a category'), findsOneWidget);
    expect(find.text('Please enter a valid price'), findsOneWidget);
  });

  testWidgets('Editing changes the name and price', (tester) async {
    await _pumpInventory(tester, tallDesktop);

    await tester.tap(find.text('Fresh milk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await _fill(tester, 'Product name', 'Full cream milk');
    await _fill(tester, 'Price (RM)', '8.50');
    final save = find.text('Save changes');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(find.text('Full cream milk was saved.'), findsOneWidget);
    // In the table and the panel title.
    expect(find.text('Full cream milk'), findsNWidgets(2));
    expect(find.text('RM 8.50'), findsNWidgets(2));
  });

  testWidgets('Photos added in the form show in the carousel', (tester) async {
    final imagePicker = FakeImagePickerService()..photosChosen = 2;
    await _pumpInventory(tester, tallDesktop, imagePicker: imagePicker);

    await tester.tap(find.text('Fresh milk'));
    await tester.pumpAndSettle();
    expect(find.text('No photos yet'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove photo'), findsNWidgets(2));

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('No photos yet'), findsNothing);
    // Two photos, so there is a next one.
    expect(find.byTooltip('Next photo'), findsOneWidget);
    await tester.tap(find.byTooltip('Next photo'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Previous photo'), findsOneWidget);
    expect(find.byTooltip('Next photo'), findsNothing);
  });

  testWidgets('A product can have at most five photos', (tester) async {
    final imagePicker = FakeImagePickerService()..photosChosen = 3;
    await _pumpInventory(tester, tallDesktop, imagePicker: imagePicker);

    await tester.tap(find.text('Add product'));
    await tester.pumpAndSettle();

    // 3 photos first, then only 2 more fit.
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pumpAndSettle();

    expect(imagePicker.lastLimit, 2);
    expect(find.byTooltip('Remove photo'), findsNWidgets(5));
    // Full, so the Add tile is gone.
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsNothing);

    await tester.tap(find.byTooltip('Remove photo').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove photo'), findsNWidgets(4));
  });

  testWidgets('Phone shows cards and opens details as a page', (tester) async {
    await _pumpInventory(tester, phone);

    expect(find.byType(ProductCard), findsWidgets);
    await tester.tap(find.text('Bananas'));
    await tester.pumpAndSettle();

    expect(find.text('STOCK AT SS15 SUBANG'), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);
  });
}
