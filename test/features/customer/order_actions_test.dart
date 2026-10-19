import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/data/repositories/catalogue_repository.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/features/customer/orders/presentation/views/customer_order_tracking_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_review.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/repositories/order_repository.dart';
import 'package:mae_assignment/shared/repositories/review_repository.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockReviewRepository extends Mock implements ReviewRepository {}

class _FakeOrder extends Fake implements Order {}

class _FakeUser extends Fake implements AppUser {}

class _FakeCatalogue implements CatalogueRepository {
  _FakeCatalogue(this.products);

  final List<CatalogueProduct> products;

  @override
  Future<bool> hasProducts(String branchId) async => true;

  @override
  Future<CatalogueData> loadCatalogue(String branchId) async =>
      CatalogueData(categories: const [], products: products);
}

CatalogueProduct _product(String id, String name, {int stock = 20}) {
  return CatalogueProduct(
    id: id,
    name: name,
    brand: 'BrandCo',
    categoryId: 'produce',
    packSize: '1kg',
    price: 4,
    stock: stock,
  );
}

Order _order({
  OrderStatus status = OrderStatus.pending,
  bool isDelivery = true,
  String branchId = 'ss15',
}) {
  return Order(
    id: 'o1',
    number: 2301,
    customerId: 'u1',
    customerName: 'Aisha',
    customerPhone: '012',
    branchId: branchId,
    branchName: 'SS15 Subang',
    isDelivery: isDelivery,
    items: const [
      OrderItem(
        lineId: 'l1',
        productId: 'p1',
        name: 'Fresh milk',
        brand: 'Farm',
        packSize: '1L',
        quantity: 2,
        unitPrice: 4,
      ),
      OrderItem(
        lineId: 'l2',
        productId: 'p2',
        name: 'Roma tomato',
        brand: 'Cameron',
        packSize: '1kg',
        quantity: 1,
        unitPrice: 4,
      ),
    ],
    subtotal: 12,
    deliveryFee: 3,
    discount: 0,
    total: 15,
    status: status,
    address: '1 Jalan Besar',
  );
}

const _review = OrderReview(
  id: 'o1',
  orderNumber: 2301,
  branchId: 'ss15',
  customerId: 'u1',
  customerName: 'Aisha',
  shoppingScore: 5,
  productScore: 4,
  deliveryScore: 3,
  comment: 'Fast and fresh',
);

void main() {
  late _MockOrderRepository orders;
  late _MockReviewRepository reviews;
  late FakeBranchService branches;

  setUpAll(() {
    registerFallbackValue(_FakeOrder());
    registerFallbackValue(_FakeUser());
  });

  setUp(() {
    orders = _MockOrderRepository();
    reviews = _MockReviewRepository();
    branches = FakeBranchService();
    when(
      () => reviews.watchReview(any()),
    ).thenAnswer((_) => Stream.value(null));
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    Order order, {
    List<CatalogueProduct>? catalogue,
  }) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    when(() => orders.watchOrder('o1')).thenAnswer((_) => Stream.value(order));

    final auth = FakeAuthRepository()
      ..signedIn = true
      ..userToSignIn = const AppUser(
        uid: 'u1',
        name: 'Aisha',
        email: 'a@example.com',
        phone: '012',
        role: UserRole.customer,
      );
    final container = ProviderContainer(
      overrides: <Override>[
        orderRepositoryProvider.overrideWithValue(orders),
        reviewRepositoryProvider.overrideWithValue(reviews),
        authRepositoryProvider.overrideWithValue(auth),
        branchServiceProvider.overrideWithValue(branches),
        catalogueRepositoryProvider.overrideWithValue(
          _FakeCatalogue(
            catalogue ??
                [_product('p1', 'Fresh milk'), _product('p2', 'Roma tomato')],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/order',
      routes: [
        GoRoute(
          path: '/order',
          builder: (context, state) =>
              const CustomerOrderTrackingView(orderId: 'o1'),
        ),
        GoRoute(
          path: AppRoutes.customerCart,
          builder: (context, state) => const Scaffold(body: Text('CART PAGE')),
        ),
        GoRoute(
          path: AppRoutes.customerOrders,
          builder: (context, state) => const Scaffold(body: Text('ORDERS')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('cancel', () {
    testWidgets('a pending order can be cancelled after confirming', (
      tester,
    ) async {
      when(() => orders.cancelOrder('o1')).thenAnswer((_) async {});
      await pump(tester, _order());

      await tapKey(tester, 'cancel_order_button');
      expect(find.text('Cancel order #2301?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel order'));
      await tester.pumpAndSettle();

      verify(() => orders.cancelOrder('o1')).called(1);
      expect(find.text('Order #2301 was cancelled.'), findsOneWidget);
    });

    testWidgets('keeping the order does nothing', (tester) async {
      await pump(tester, _order());

      await tapKey(tester, 'cancel_order_button');
      await tester.tap(find.text('Keep order'));
      await tester.pumpAndSettle();

      verifyNever(() => orders.cancelOrder(any()));
    });

    testWidgets('shows why when it can no longer be cancelled', (tester) async {
      when(() => orders.cancelOrder('o1')).thenThrow(
        const OrderException('This order can no longer be cancelled.'),
      );
      await pump(tester, _order());

      await tapKey(tester, 'cancel_order_button');
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel order'));
      await tester.pumpAndSettle();

      expect(
        find.text('This order can no longer be cancelled.'),
        findsOneWidget,
      );
    });

    testWidgets('only a pending order offers cancel', (tester) async {
      await pump(tester, _order(status: OrderStatus.packing));

      expect(find.byKey(const Key('cancel_order_button')), findsNothing);
      expect(find.byKey(const Key('reorder_button')), findsNothing);
    });
  });

  group('order again', () {
    testWidgets('puts the order in the cart and opens it', (tester) async {
      final container = await pump(
        tester,
        _order(status: OrderStatus.completed),
      );

      await tapKey(tester, 'reorder_button');

      final cart = container.read(cartViewModelProvider);
      expect(cart.quantityOf('p1'), 2);
      expect(cart.quantityOf('p2'), 1);
      expect(cart.fulfilment, FulfilmentMethod.delivery);
      expect(container.read(branchChoiceProvider), 'ss15');
      expect(find.text('CART PAGE'), findsOneWidget);
    });

    testWidgets('asks before replacing a cart that has items', (tester) async {
      final container = await pump(
        tester,
        _order(status: OrderStatus.cancelled),
      );
      container
          .read(cartViewModelProvider.notifier)
          .add(_product('other', 'Something else'));

      await tapKey(tester, 'reorder_button');
      expect(find.text('Replace your cart?'), findsOneWidget);
      await tester.tap(find.text('Keep my cart'));
      await tester.pumpAndSettle();
      expect(container.read(cartViewModelProvider).quantityOf('other'), 1);

      await tapKey(tester, 'reorder_button');
      await tester.tap(find.text('Replace cart'));
      await tester.pumpAndSettle();

      final cart = container.read(cartViewModelProvider);
      expect(cart.quantityOf('other'), 0);
      expect(cart.quantityOf('p1'), 2);
    });

    testWidgets('leaves out products that are gone and says so', (
      tester,
    ) async {
      final container = await pump(
        tester,
        _order(status: OrderStatus.completed),
        catalogue: [_product('p1', 'Fresh milk', stock: 1)],
      );

      await tapKey(tester, 'reorder_button');

      final cart = container.read(cartViewModelProvider);
      // Quantity is capped at the stock left; the gone product is dropped.
      expect(cart.quantityOf('p1'), 1);
      expect(cart.quantityOf('p2'), 0);
      expect(find.textContaining('Roma tomato'), findsWidgets);
    });

    testWidgets('does nothing when nothing is available', (tester) async {
      final container = await pump(
        tester,
        _order(status: OrderStatus.completed),
        catalogue: const [],
      );

      await tapKey(tester, 'reorder_button');

      expect(container.read(cartViewModelProvider).isEmpty, isTrue);
      expect(find.textContaining('None of these items'), findsOneWidget);
      expect(find.text('CART PAGE'), findsNothing);
    });

    testWidgets('refuses when the store is closed', (tester) async {
      branches.branches[0] = branches.branches[0].withTemporarilyClosed(
        closed: true,
      );
      final container = await pump(
        tester,
        _order(status: OrderStatus.completed),
      );

      await tapKey(tester, 'reorder_button');

      expect(container.read(cartViewModelProvider).isEmpty, isTrue);
      expect(find.textContaining('is closed right now'), findsOneWidget);
    });

    testWidgets('refuses when the store no longer exists', (tester) async {
      await pump(
        tester,
        _order(status: OrderStatus.completed, branchId: 'gone'),
      );

      await tapKey(tester, 'reorder_button');

      expect(find.textContaining('no longer available'), findsOneWidget);
    });
  });

  group('rating', () {
    setUp(() {
      when(
        () => reviews.submit(
          order: any(named: 'order'),
          customer: any(named: 'customer'),
          shoppingScore: any(named: 'shoppingScore'),
          productScore: any(named: 'productScore'),
          deliveryScore: any(named: 'deliveryScore'),
          comment: any(named: 'comment'),
        ),
      ).thenAnswer((_) async {});
    });

    testWidgets('a completed order can be rated', (tester) async {
      await pump(tester, _order(status: OrderStatus.completed));

      await tapKey(tester, 'rate_order_button');
      expect(find.text('Rate order #2301'), findsOneWidget);

      // Send is disabled until every rating is chosen.
      FilledButton send() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Send rating'),
      );
      expect(send().onPressed, isNull);

      await tester.tap(find.byTooltip('Shopping experience: 5 stars'));
      await tester.tap(find.byTooltip('Product quality: 4 stars'));
      await tester.pump();
      expect(send().onPressed, isNull);
      await tester.tap(find.byTooltip('Delivery: 3 stars'));
      await tester.pump();
      expect(send().onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), 'Fast and fresh');
      await tester.tap(find.widgetWithText(FilledButton, 'Send rating'));
      await tester.pumpAndSettle();

      verify(
        () => reviews.submit(
          order: any(named: 'order'),
          customer: any(named: 'customer'),
          shoppingScore: 5,
          productScore: 4,
          deliveryScore: 3,
          comment: 'Fast and fresh',
        ),
      ).called(1);
      expect(find.text('Thanks for your feedback!'), findsOneWidget);
    });

    testWidgets('a pickup order is not asked about delivery', (tester) async {
      await pump(
        tester,
        _order(status: OrderStatus.completed, isDelivery: false),
      );

      await tapKey(tester, 'rate_order_button');

      expect(find.byTooltip('Delivery: 3 stars'), findsNothing);
      await tester.tap(find.byTooltip('Shopping experience: 5 stars'));
      await tester.tap(find.byTooltip('Product quality: 5 stars'));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Send rating'),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('shows the error when saving fails', (tester) async {
      when(
        () => reviews.submit(
          order: any(named: 'order'),
          customer: any(named: 'customer'),
          shoppingScore: any(named: 'shoppingScore'),
          productScore: any(named: 'productScore'),
          deliveryScore: any(named: 'deliveryScore'),
          comment: any(named: 'comment'),
        ),
      ).thenThrow(const ReviewException('Could not save your rating.'));
      await pump(
        tester,
        _order(status: OrderStatus.completed, isDelivery: false),
      );

      await tapKey(tester, 'rate_order_button');
      await tester.tap(find.byTooltip('Shopping experience: 5 stars'));
      await tester.tap(find.byTooltip('Product quality: 5 stars'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Send rating'));
      await tester.pumpAndSettle();

      expect(find.text('Could not save your rating.'), findsOneWidget);
      expect(find.text('Rate order #2301'), findsOneWidget);
    });

    testWidgets('an already rated order shows the rating, not the button', (
      tester,
    ) async {
      when(
        () => reviews.watchReview('o1'),
      ).thenAnswer((_) => Stream.value(_review));
      await pump(tester, _order(status: OrderStatus.completed));

      expect(find.byKey(const Key('rate_order_button')), findsNothing);
      expect(find.text('Your rating'), findsOneWidget);
      expect(find.text('Fast and fresh'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);
    });

    testWidgets('a cancelled order cannot be rated', (tester) async {
      await pump(tester, _order(status: OrderStatus.cancelled));

      expect(find.byKey(const Key('rate_order_button')), findsNothing);
      expect(find.byKey(const Key('reorder_button')), findsOneWidget);
    });
  });

  group('pickup QR code', () {
    testWidgets('a ready pickup order shows the QR code to collect it', (
      tester,
    ) async {
      await pump(tester, _order(status: OrderStatus.ready, isDelivery: false));

      expect(find.text('Ready for pickup'), findsWidgets);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(
        find.text('Show this QR code at the counter of SS15 Subang.'),
        findsOneWidget,
      );
    });

    final others = {
      'before packing': _order(isDelivery: false),
      'while packing': _order(status: OrderStatus.packing, isDelivery: false),
      'after collection': _order(
        status: OrderStatus.completed,
        isDelivery: false,
      ),
      'for a delivery order': _order(status: OrderStatus.ready),
    };
    for (final entry in others.entries) {
      testWidgets('no QR code ${entry.key}', (tester) async {
        await pump(tester, entry.value);

        expect(find.byType(QrImageView), findsNothing);
      });
    }
  });
}
