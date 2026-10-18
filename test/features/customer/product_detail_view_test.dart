import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/views/product_detail_view.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_branch_service.dart';

class _FakeCatalogueRepository implements CatalogueRepository {
  _FakeCatalogueRepository(this.products);

  final List<CatalogueProduct> products;

  @override
  Future<CatalogueData> loadCatalogue(String branchId) async =>
      CatalogueData(categories: const [], products: products);

  @override
  Future<bool> hasProducts(String branchId) async => true;
}

CatalogueProduct _product({int stock = 20}) => CatalogueProduct(
  id: 'p1',
  name: 'Fresh milk',
  brand: 'Dairy Co',
  categoryId: 'dairy',
  packSize: '1L',
  price: 7.5,
  stock: stock,
  description: 'Full cream, pasteurised.',
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<CatalogueProduct> products,
  String productId = 'p1',
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      branchServiceProvider.overrideWithValue(FakeBranchService()),
      catalogueRepositoryProvider.overrideWithValue(
        _FakeCatalogueRepository(products),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: ProductDetailView(productId: productId)),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('shows the product details', (tester) async {
    await _pump(tester, products: [_product()]);

    expect(find.text('Fresh milk'), findsOneWidget);
    expect(find.text('Dairy Co · 1L'), findsOneWidget);
    expect(find.text('RM 7.50'), findsOneWidget);
    expect(find.text('In stock'), findsOneWidget);
    expect(find.text('Full cream, pasteurised.'), findsOneWidget);
    expect(find.text('Add to cart · RM 7.50'), findsOneWidget);
  });

  testWidgets('shows a low stock hint', (tester) async {
    await _pump(tester, products: [_product(stock: 3)]);

    expect(find.text('Only 3 left'), findsOneWidget);
  });

  testWidgets('adds the chosen quantity to the cart', (tester) async {
    final container = await _pump(tester, products: [_product()]);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('Add to cart · RM 22.50'), findsOneWidget);

    await tester.tap(find.textContaining('Add to cart'));
    await tester.pump();

    expect(container.read(cartViewModelProvider).quantityOf('p1'), 3);
    expect(find.text('In your cart: 3'), findsOneWidget);
    expect(find.text('3 × Fresh milk added to cart'), findsOneWidget);
  });

  testWidgets('cannot choose more than the stock', (tester) async {
    final container = await _pump(tester, products: [_product(stock: 2)]);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pump();
    }
    await tester.tap(find.textContaining('Add to cart'));
    await tester.pump();

    expect(container.read(cartViewModelProvider).quantityOf('p1'), 2);
    expect(find.text('All available stock is in your cart'), findsOneWidget);
    expect(find.byTooltip('Increase quantity'), findsNothing);
  });

  testWidgets('an out-of-stock product cannot be added', (tester) async {
    final container = await _pump(tester, products: [_product(stock: 0)]);

    expect(find.text('Out of stock at this store'), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(container.read(cartViewModelProvider).itemCount, 0);
  });

  testWidgets('shows a message when the product is not available', (
    tester,
  ) async {
    await _pump(tester, products: [_product()], productId: 'missing');

    expect(find.text('Product not available'), findsOneWidget);
  });
}
