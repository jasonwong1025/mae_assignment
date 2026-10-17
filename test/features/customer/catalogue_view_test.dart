import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/views/catalogue_view.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_branch_service.dart';

/// Serves a fixed catalogue, so the Home screen can be tested with no
/// Firestore. Content is independent of the branch id.
class _FakeCatalogueRepository implements CatalogueRepository {
  _FakeCatalogueRepository(this.data);

  final CatalogueData data;

  @override
  Future<CatalogueData> loadCatalogue(String branchId) async => data;
}

CatalogueProduct _product(
  String id,
  String name, {
  String categoryId = 'produce',
  int stock = 20,
}) {
  return CatalogueProduct(
    id: id,
    name: name,
    brand: 'BrandCo',
    categoryId: categoryId,
    packSize: '1kg',
    price: 4,
    stock: stock,
  );
}

Future<ProviderContainer> _pump(WidgetTester tester, CatalogueData data) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      branchServiceProvider.overrideWithValue(FakeBranchService()),
      catalogueRepositoryProvider.overrideWithValue(
        _FakeCatalogueRepository(data),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CatalogueView()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('shows the store line, products and categories', (tester) async {
    await _pump(
      tester,
      CatalogueData(
        categories: const [
          CatalogueCategory(id: 'produce', name: 'Fresh produce'),
          CatalogueCategory(id: 'dairy', name: 'Dairy & eggs'),
        ],
        products: [
          _product('p1', 'Roma tomato'),
          _product('p2', 'Fresh milk', categoryId: 'dairy'),
        ],
      ),
    );

    // Store header line from the first in-memory branch.
    expect(find.textContaining('— open'), findsOneWidget);
    // Category tabs include an "All" chip plus the categories.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Fresh produce'), findsOneWidget);
    // Products render.
    expect(find.text('Roma tomato'), findsOneWidget);
    expect(find.text('Fresh milk'), findsOneWidget);
    // Promo banner shows when not searching.
    expect(find.textContaining('FRESH5'), findsOneWidget);
  });

  testWidgets('tapping a category filters the grid', (tester) async {
    await _pump(
      tester,
      CatalogueData(
        categories: const [
          CatalogueCategory(id: 'produce', name: 'Fresh produce'),
          CatalogueCategory(id: 'dairy', name: 'Dairy & eggs'),
        ],
        products: [
          _product('p1', 'Roma tomato'),
          _product('p2', 'Fresh milk', categoryId: 'dairy'),
        ],
      ),
    );

    final dairy = find.text('Dairy & eggs');
    await tester.ensureVisible(dairy);
    await tester.pumpAndSettle();
    await tester.tap(dairy);
    await tester.pumpAndSettle();

    expect(find.text('Fresh milk'), findsOneWidget);
    expect(find.text('Roma tomato'), findsNothing);
  });

  testWidgets('an out-of-stock product cannot be added', (tester) async {
    await _pump(
      tester,
      CatalogueData(
        categories: const [],
        products: [_product('p1', 'Sold out item', stock: 0)],
      ),
    );

    // The out-of-stock overlay shows and the product renders.
    expect(find.text('Out of stock'), findsOneWidget);
    expect(find.text('Sold out item'), findsOneWidget);

    // The add button's InkWell is disabled (no onTap), so a tap does
    // nothing: no "cart" message appears.
    final addButton = find.descendant(
      of: find.byType(InkWell),
      matching: find.byIcon(Icons.add_rounded),
    );
    await tester.tap(addButton, warnIfMissed: false);
    await tester.pump();
    expect(find.textContaining('cart'), findsNothing);
  });

  testWidgets('shows an empty state when nothing matches', (tester) async {
    await _pump(tester, const CatalogueData(categories: [], products: []));

    expect(find.text('No products found'), findsOneWidget);
  });

  testWidgets('tapping add puts the product in the cart', (tester) async {
    final container = await _pump(
      tester,
      CatalogueData(
        categories: const [],
        products: [_product('p1', 'Roma tomato')],
      ),
    );

    expect(container.read(cartViewModelProvider).itemCount, 0);

    final addButton = find.descendant(
      of: find.byType(InkWell),
      matching: find.byIcon(Icons.add_rounded),
    );
    await tester.tap(addButton);
    await tester.pump();

    expect(container.read(cartViewModelProvider).quantityOf('p1'), 1);
    // The cart badge now shows on the Cart tab.
    expect(find.text('1'), findsWidgets);
  });

  // Catalogue fits common phone widths at a real phone height, with no
  // overflow. The "Going fast today" row and the grid both carry a product
  // with a long two-line name and a low stock hint, which is what overflowed
  // before. 844 is a common phone height; a shorter height would clip the
  // scrollable lists, which is expected and not an overflow.
  for (final width in const [320.0, 360.0, 430.0]) {
    testWidgets('catalogue fits at ${width.toInt()}dp without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          branchServiceProvider.overrideWithValue(FakeBranchService()),
          catalogueRepositoryProvider.overrideWithValue(
            _FakeCatalogueRepository(
              CatalogueData(
                categories: const [
                  CatalogueCategory(id: 'produce', name: 'Fresh produce'),
                ],
                products: [
                  // Low stock → appears in "Going fast"; long name → 2 lines.
                  _product('p1', 'Granny Smith apple 4 pack', stock: 3),
                  _product('p2', 'Fresh milk 1 litre carton', stock: 5),
                ],
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CatalogueView()),
        ),
      );
      await tester.pumpAndSettle();

      // The "Going fast today" row rendered (low-stock products present).
      expect(find.text('GOING FAST TODAY'), findsOneWidget);
      // No RenderFlex overflow (or any other) was thrown while laying out.
      expect(tester.takeException(), isNull);
    });
  }
}
