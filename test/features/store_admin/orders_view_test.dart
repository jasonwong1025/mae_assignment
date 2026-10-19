import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/orders/data/admin_board_statuses.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/ui/order_card.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/ui/order_detail_panel.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/ui/orders_board.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/view_models/orders_filter_view_model.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/views/orders_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// The orders board with a signed-in fake admin, on a screen of [size].
Future<void> _pumpOrders(WidgetTester tester, Size size) async {
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
        branchServiceProvider.overrideWithValue(FakeBranchService()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const OrdersView()),
    ),
  );
  await tester.pumpAndSettle();
}

Order _order(int number, OrderStatus status, int minutesAgo) {
  return Order(
    id: 'ord-$number',
    number: number,
    customerId: 'customer-$number',
    branchId: 'ss15',
    branchName: 'SS15 Subang',
    customerName: 'Customer $number',
    customerPhone: '0123456789',
    status: status,
    statusSince: DateTime(
      2026,
      1,
      1,
      12,
    ).subtract(Duration(minutes: minutesAgo)),
    isDelivery: true,
    items: const [
      OrderItem(
        lineId: 'L1',
        productId: 'p1',
        name: 'Milk',
        brand: '',
        packSize: '',
        quantity: 2,
        unitPrice: 7.90,
      ),
      OrderItem(
        lineId: 'L2',
        productId: 'p2',
        name: 'Oat milk',
        brand: '',
        packSize: '',
        quantity: 1,
        unitPrice: 12,
      ),
    ],
    subtotal: 27.80,
    deliveryFee: 5,
    discount: 0,
    total: 32.80,
  );
}

void main() {
  const desktop = Size(1600, 900);
  const phone = Size(390, 844);

  group('Order', () {
    test('counts quantities and adds up the total', () {
      final order = _order(1, OrderStatus.pending, 0);

      expect(order.itemCount, 3);
      expect(order.subtotal, closeTo(27.80, 0.001));
      expect(order.total, closeTo(32.80, 0.001));
      expect(
        order.items.fold<double>(0, (sum, item) => sum + item.lineTotal),
        closeTo(order.subtotal, 0.001),
      );
    });
  });

  group('OrdersFilter', () {
    final order = _order(2288, OrderStatus.packing, 0);

    test('search matches the number or the name', () {
      expect(const OrdersFilter(searchText: '#2288').matches(order), isTrue);
      expect(const OrdersFilter(searchText: '228').matches(order), isTrue);
      expect(const OrdersFilter(searchText: 'CUSTOMER').matches(order), isTrue);
      expect(const OrdersFilter(searchText: 'farah').matches(order), isFalse);
    });

    test('pickup filter hides delivery orders', () {
      const filter = OrdersFilter(fulfilment: FulfilmentFilter.pickup);
      expect(filter.matches(order), isFalse);
    });
  });

  group('ordersWithStatus', () {
    test('lists the longest waiting first', () {
      final orders = [
        _order(1, OrderStatus.packing, 5),
        _order(2, OrderStatus.packing, 30),
        _order(3, OrderStatus.packing, 10),
        _order(4, OrderStatus.ready, 60),
      ];

      final packing = ordersWithStatus(orders, OrderStatus.packing);

      expect(packing.map((order) => order.number), [2, 3, 1]);
    });

    test('lists finished orders newest first', () {
      final orders = [
        _order(1, OrderStatus.completed, 40),
        _order(2, OrderStatus.completed, 5),
      ];

      final completed = ordersWithStatus(orders, OrderStatus.completed);

      expect(completed.map((order) => order.number), [2, 1]);
    });
  });

  testWidgets('Board shows a column for every status', (tester) async {
    await _pumpOrders(tester, desktop);

    for (final status in adminBoardStatuses) {
      expect(find.text(status.label.toUpperCase()), findsOneWidget);
    }
    // No Cancelled column: paid orders cannot be cancelled.
    expect(find.text('CANCELLED'), findsNothing);
    expect(find.byType(OrderCard), findsNWidgets(12));
    expect(find.text('Farah Idris'), findsOneWidget);
    expect(find.text('Wei Ming'), findsOneWidget);
    expect(find.textContaining('SS15 Subang · today'), findsOneWidget);
  });

  testWidgets('Search and filter narrow the board', (tester) async {
    await _pumpOrders(tester, desktop);

    await tester.enterText(find.byType(TextField), 'david');
    await tester.pumpAndSettle();
    expect(find.byType(OrderCard), findsOneWidget);
    expect(find.text('David Wong'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.byTooltip('Filter orders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pickup').last);
    await tester.pumpAndSettle();

    // Wong Kar Yee, Siti Aminah and Lim H. are the pickup orders.
    expect(find.byType(OrderCard), findsNWidgets(3));
    expect(find.text('Farah Idris'), findsNothing);
  });

  testWidgets('Tapping an order opens its details beside the board', (
    tester,
  ) async {
    await _pumpOrders(tester, desktop);

    await tester.tap(find.text('David Wong'));
    await tester.pumpAndSettle();

    expect(find.text('Order #2288'), findsOneWidget);
    expect(find.text('Oat milk 1L'), findsOneWidget);
    expect(find.text('Handled by Hakim'), findsOneWidget);
    // The board is still there.
    expect(find.text('Farah Idris'), findsOneWidget);

    // The timeline is further down the panel.
    await tester.scrollUntilVisible(
      find.text('Packing started'),
      200,
      scrollable: find.descendant(
        of: find.byType(OrderDetailPanel),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Packing started'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Order #2288'), findsNothing);
  });

  testWidgets("Switching branch shows that branch's orders", (tester) async {
    await _pumpOrders(tester, desktop);

    await tester.tap(find.byTooltip('Switch branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Puchong'));
    await tester.pumpAndSettle();

    expect(find.byType(OrderCard), findsNWidgets(3));
    expect(find.text('Aisyah Rahman'), findsOneWidget);
    expect(find.text('Farah Idris'), findsNothing);
  });

  testWidgets('Phone shows one status at a time', (tester) async {
    await _pumpOrders(tester, phone);

    expect(find.text('Pending 3'), findsOneWidget);
    expect(find.text('Packing 2'), findsOneWidget);
    expect(find.byType(OrderCard), findsNWidgets(3));

    await tester.tap(find.text('Packing 2'));
    await tester.pumpAndSettle();
    expect(find.byType(OrderCard), findsNWidgets(2));

    // On a phone the details open as a full page.
    await tester.tap(find.text('Mei Ling Tan'));
    await tester.pumpAndSettle();
    expect(find.text('Order #2291'), findsOneWidget);
    expect(find.text('Packing 2'), findsNothing);
  });
}
