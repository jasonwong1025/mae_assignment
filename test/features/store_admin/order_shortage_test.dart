import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/orders/data/repositories/orders_repository.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/views/orders_view.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sale.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';
import '../../helpers/seed_data.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// 3 pm, so "minutes ago" orders in the seed data are still today.
final _now = DateTime(2026, 10, 16, 15);

OrdersRepository _repository(FakeFirebaseFirestore firestore) {
  return OrdersRepository(
    OrderService(firestore),
    StaffService(firestore),
    clock: () => _now,
  );
}

Future<FakeFirebaseFirestore> _pumpOrders(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final firestore = await seededFirestore(now: _now);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository()
            ..userToSignIn = _admin
            ..signedIn = true,
        ),
        branchServiceProvider.overrideWithValue(FakeBranchService()),
        firebaseFirestoreProvider.overrideWithValue(firestore),
        ordersRepositoryProvider.overrideWithValue(_repository(firestore)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const OrdersView()),
    ),
  );
  await tester.pumpAndSettle();
  return firestore;
}

/// Seeded order #2303 has a replacement waiting for its customer: the
/// bananas (L4) are unavailable and apples were offered instead.
void main() {
  group('Order #2303 in the seed', () {
    test('has a proposal waiting and keeps the money it was paid', () async {
      final firestore = await seededFirestore(now: _now);

      final order = (await OrderService(firestore).getOrder('ord-2303'))!;

      expect(order.hasOpenShortage, isTrue);
      expect(order.shortageOf('L4')!.replacement!.name, 'Granny Smith apple');
      expect(order.total, closeTo(53.1, 0.001));
      // Until the customer accepts, nothing about the amount changes.
      expect(order.adjustedTotal, closeTo(53.1, 0.001));
    });
  });

  group('OrdersRepository.cancelOrder', () {
    test('cancels an order waiting on the customer', () async {
      final firestore = await seededFirestore(now: _now);
      final repository = _repository(firestore);
      final order = (await OrderService(firestore).getOrder('ord-2303'))!;

      await repository.cancelOrder(order);

      final saved = (await OrderService(firestore).getOrder('ord-2303'))!;
      expect(saved.status, OrderStatus.cancelled);
    });

    test('refuses an order that has already finished', () async {
      final firestore = await seededFirestore(now: _now);
      final repository = _repository(firestore);
      final done = (await OrderService(firestore).getBranchOrdersBetween(
        'ss15',
        DateTime(2020),
        DateTime(2030),
      )).firstWhere((order) => order.status == OrderStatus.completed);

      expect(repository.cancelOrder(done), throwsA(isA<OrdersException>()));
    });
  });

  group('sales', () {
    test('count what the customer actually got', () async {
      final firestore = await seededFirestore(now: _now);
      final order = (await OrderService(firestore).getOrder('ord-2303'))!;
      final accepted = order.copyWith(
        shortages: {
          'L4': order
              .shortageOf('L4')!
              .copyWith(status: ShortageStatus.accepted),
        },
      );

      final sale = Sale.fromOrder(accepted);

      expect(
        sale.items.map((item) => item.productName),
        contains('Granny Smith apple'),
      );
      expect(
        sale.items.map((item) => item.productName),
        isNot(contains('Bananas')),
      );
    });

    test('leave out a removed item', () async {
      final firestore = await seededFirestore(now: _now);
      final order = (await OrderService(firestore).getOrder('ord-2303'))!;
      final removed = order.copyWith(
        shortages: {'L4': const LineShortage(status: ShortageStatus.removed)},
      );

      final sale = Sale.fromOrder(removed);

      expect(
        sale.items.map((item) => item.productName),
        isNot(contains('Bananas')),
      );
      expect(sale.itemsTotal, closeTo(removed.adjustedSubtotal, 0.001));
    });
  });

  group('order panel', () {
    testWidgets('shows what is waiting and cancels the order', (tester) async {
      final firestore = await _pumpOrders(tester);

      await tester.tap(find.text('#2303'));
      await tester.pumpAndSettle();

      expect(find.text('AWAITING CUSTOMER'), findsOneWidget);
      expect(
        find.text('Unavailable, waiting for the customer'),
        findsOneWidget,
      );
      expect(find.text('Offered, not yet accepted'), findsOneWidget);
      expect(find.text('Adjusted total'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel_waiting_order_button')));
      await tester.pumpAndSettle();
      expect(find.text('Cancel order #2303?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Cancel order'));
      await tester.pumpAndSettle();

      final saved = (await OrderService(firestore).getOrder('ord-2303'))!;
      expect(saved.status, OrderStatus.cancelled);
      expect(find.text('Order #2303 cancelled.'), findsOneWidget);
    });

    testWidgets('keeping the order leaves it as it was', (tester) async {
      final firestore = await _pumpOrders(tester);
      await tester.tap(find.text('#2303'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cancel_waiting_order_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep order'));
      await tester.pumpAndSettle();

      final saved = (await OrderService(firestore).getOrder('ord-2303'))!;
      expect(saved.status, OrderStatus.packing);
    });

    testWidgets('an order with no shortage has no cancel button', (
      tester,
    ) async {
      await _pumpOrders(tester);

      await tester.tap(find.text('#2291'));
      await tester.pumpAndSettle();

      expect(find.text('AWAITING CUSTOMER'), findsNothing);
      expect(
        find.byKey(const Key('cancel_waiting_order_button')),
        findsNothing,
      );
    });
  });
}
