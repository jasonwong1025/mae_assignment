import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/cart/presentation/views/cart_view.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';

CatalogueProduct _product(
  String id,
  String name, {
  double price = 4,
  int stock = 20,
}) {
  return CatalogueProduct(
    id: id,
    name: name,
    brand: 'BrandCo',
    categoryId: 'produce',
    packSize: '1kg',
    price: price,
    stock: stock,
  );
}

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required List<CartLine> lines,
}) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  // Seed the cart before pumping.
  for (final line in lines) {
    for (var i = 0; i < line.quantity; i++) {
      container.read(cartViewModelProvider.notifier).add(line.product);
    }
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CartView()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('empty cart shows the empty state', (tester) async {
    await _pump(tester, lines: const []);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('shows lines, item count and a total', (tester) async {
    await _pump(
      tester,
      lines: [
        CartLine(
          product: _product('p1', 'Fresh milk', price: 8.9),
          quantity: 2,
        ),
        CartLine(
          product: _product('p2', 'Roma tomato', price: 6.8),
          quantity: 1,
        ),
      ],
    );

    expect(find.text('Fresh milk — BrandCo'), findsOneWidget);
    expect(find.text('Roma tomato — BrandCo'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    // Subtotal 8.9*2 + 6.8 = 24.6, + 3 delivery = 27.60.
    expect(find.textContaining('Place order — RM 27.60'), findsOneWidget);
  });

  testWidgets('plus button increases the quantity and total', (tester) async {
    final container = await _pump(
      tester,
      lines: [
        CartLine(product: _product('p1', 'Fresh milk', price: 10), quantity: 1),
      ],
    );

    await tester.tap(find.byTooltip('Add one'));
    await tester.pumpAndSettle();

    expect(container.read(cartViewModelProvider).quantityOf('p1'), 2);
  });

  testWidgets('switching to pickup drops the delivery fee', (tester) async {
    await _pump(
      tester,
      lines: [
        CartLine(product: _product('p1', 'Fresh milk', price: 10), quantity: 1),
      ],
    );

    // Delivery: 10 + 3 = 13.00.
    expect(find.textContaining('Place order — RM 13.00'), findsOneWidget);

    await tester.tap(find.text('Self pickup'));
    await tester.pumpAndSettle();

    // Pickup: no fee, 10.00.
    expect(find.textContaining('Place order — RM 10.00'), findsOneWidget);
  });

  testWidgets('applying FRESH5 shows the discount', (tester) async {
    await _pump(
      tester,
      lines: [
        CartLine(product: _product('p1', 'Fresh milk', price: 20), quantity: 1),
      ],
    );

    await tester.enterText(find.byType(TextField), 'FRESH5');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('FRESH5 applied'), findsOneWidget);
    expect(find.textContaining('Discount'), findsOneWidget);
    // 20 + 3 delivery - 5 = 18.00.
    expect(find.textContaining('Place order — RM 18.00'), findsOneWidget);
  });
}
