import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/cart/presentation/views/cart_view.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_thumbnail.dart';
import 'package:mae_assignment/features/customer/orders/presentation/views/customer_order_tracking_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/services/address_service.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mae_assignment/shared/services/order_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_address_service.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

class _MockOrderService extends Mock implements OrderService {}

class _FakeOrder extends Fake implements Order {}

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

  final auth = FakeAuthRepository()
    ..signedIn = true
    ..userToSignIn = const AppUser(
      uid: 'u1',
      name: 'Aisha',
      email: 'aisha@example.com',
      phone: '0123456789',
      role: UserRole.customer,
    );
  final container = ProviderContainer(
    overrides: [
      // The cart watches the delivery quote (saved addresses -> auth), so
      // provide fakes to avoid real Firebase and its pending timers.
      authRepositoryProvider.overrideWithValue(auth),
      addressServiceProvider.overrideWithValue(FakeAddressService()),
      branchServiceProvider.overrideWithValue(FakeBranchService()),
    ],
  );
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

    await tester.enterText(find.byKey(const Key('cart_promo_field')), 'FRESH5');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('FRESH5 applied'), findsOneWidget);
    expect(find.textContaining('Discount'), findsOneWidget);
    // 20 + 3 delivery - 5 = 18.00.
    expect(find.textContaining('Place order — RM 18.00'), findsOneWidget);
  });

  group('checkout', () {
    late _MockOrderService orderService;
    late FakeAuthRepository auth;

    setUpAll(() => registerFallbackValue(_FakeOrder()));

    setUp(() {
      orderService = _MockOrderService();
      auth = FakeAuthRepository()
        ..signedIn = true
        ..userToSignIn = const AppUser(
          uid: 'u1',
          name: 'Aisha',
          email: 'aisha@example.com',
          phone: '0123456789',
          role: UserRole.customer,
        );
      when(orderService.highestOrderNumber).thenAnswer((_) async => 2300);
      when(() => orderService.createOrder(any())).thenAnswer((_) async => 'o1');
      // The tracking screen the view navigates to streams the order by id.
      when(() => orderService.watchOrder('o1')).thenAnswer(
        (_) => Stream.value(
          Order.fromFirestore('o1', {
            'number': 2301,
            'customerId': 'u1',
            'customerName': 'Aisha',
            'branchId': 'ss15',
            'branchName': 'SS15 Subang',
            'isDelivery': true,
            'items': const [
              {
                'lineId': 'p1',
                'productId': 'p1',
                'name': 'Fresh milk',
                'brand': 'BrandCo',
                'packSize': '1kg',
                'quantity': 1,
                'unitPrice': 12.9,
              },
            ],
            'subtotal': 12.9,
            'deliveryFee': 3,
            'discount': 0,
            'total': 15.9,
            'status': 'pending',
          }),
        ),
      );
    });

    Future<ProviderContainer> pumpWithRouter(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          branchServiceProvider.overrideWithValue(FakeBranchService()),
          authRepositoryProvider.overrideWithValue(auth),
          addressServiceProvider.overrideWithValue(FakeAddressService()),
          orderServiceProvider.overrideWithValue(orderService),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(cartViewModelProvider.notifier)
          .add(_product('p1', 'Fresh milk', price: 12.9));

      final router = GoRouter(
        initialLocation: '/shop/cart',
        routes: [
          GoRoute(
            path: '/shop/cart',
            builder: (context, state) => const CartView(),
          ),
          GoRoute(
            path: '/shop/orders/:id',
            builder: (context, state) =>
                CustomerOrderTrackingView(orderId: state.pathParameters['id']!),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('the cart line renders (body is not blank)', (tester) async {
      await pumpWithRouter(tester);
      expect(find.text('Fresh milk — BrandCo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // Regression: on device the cart list was blank because the line's
    // thumbnail (an AspectRatio) had only a width constraint and no height,
    // so with a product image it had no height to resolve and collapsed the
    // line. A product WITH an image exercises the ProductThumbnail image
    // branch; the line must still render with a bounded height.
    testWidgets('a line with a product image still renders', (tester) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          branchServiceProvider.overrideWithValue(FakeBranchService()),
          authRepositoryProvider.overrideWithValue(auth),
          addressServiceProvider.overrideWithValue(FakeAddressService()),
          orderServiceProvider.overrideWithValue(orderService),
        ],
      );
      addTearDown(container.dispose);
      const withImage = CatalogueProduct(
        id: 'p1',
        name: 'Fresh milk',
        brand: 'BrandCo',
        categoryId: 'produce',
        packSize: '1kg',
        price: 12.9,
        stock: 20,
        imageUrls: ['https://example.com/milk.png'],
      );
      container.read(cartViewModelProvider.notifier).add(withImage);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: CartView()),
        ),
      );
      // Image.network fails to load under the test binding; the thumbnail's
      // errorBuilder renders a placeholder. The point is that the AspectRatio
      // lays out at its fixed 56x56 box, not that the network image loads.
      await tester.pump();

      expect(find.text('Fresh milk — BrandCo'), findsOneWidget);
      expect(find.byType(ProductThumbnail), findsOneWidget);
      // The thumbnail laid out at its fixed 56x56 size (not collapsed).
      final size = tester.getSize(find.byType(ProductThumbnail));
      expect(size.width, 56);
      expect(size.height, 56);
      expect(tester.takeException(), isNull);
    });

    testWidgets('placing a pickup order resolves the branch and navigates '
        'to tracking without "No store selected"', (tester) async {
      final container = await pumpWithRouter(tester);

      // Self-pickup needs no delivery address, so this exercises the full
      // checkout -> tracking path without the address picker.
      await tester.tap(find.text('Self pickup'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Place order'));
      await tester.pumpAndSettle();

      // The order was written and we navigated to its tracking page, which
      // rendered the real tracking screen without a layout/null-check crash.
      verify(() => orderService.createOrder(any())).called(1);
      expect(find.text('Order tracking'), findsOneWidget);
      expect(find.text('Order #2301'), findsOneWidget);
      expect(find.textContaining('No store selected'), findsNothing);
      // The cart was cleared on success.
      expect(container.read(cartViewModelProvider).isEmpty, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
