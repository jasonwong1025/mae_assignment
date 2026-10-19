import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';
import 'package:mae_assignment/features/store_admin/sales/data/repositories/sales_repository.dart';
import 'package:mae_assignment/features/store_admin/sales/presentation/ui/top_products_rows.dart';
import 'package:mae_assignment/features/store_admin/sales/presentation/views/sales_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';
import '../../helpers/worker_test_store.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// Shows the Sales tab on a screen of [size].
Future<void> _pumpSales(WidgetTester tester, Size size) async {
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
        firebaseFirestoreProvider.overrideWithValue(await _salesDatabase()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const SalesView()),
    ),
  );
  await tester.pumpAndSettle();
}

/// 30 days of completed orders: SS15 has 3 a day, Puchong 1 a day. Orders
/// cycle through 30 products in 5 categories, so the top products fill
/// more than one page.
Future<FakeFirebaseFirestore> _salesDatabase() async {
  final firestore = FakeFirebaseFirestore();
  final today = DateTime.now();
  var number = 1000;
  for (final (branch, perDay) in [('ss15', 3), ('puchong', 1)]) {
    for (var day = 0; day < 30; day++) {
      for (var i = 0; i < perDay; i++) {
        number++;
        final items = [
          for (var line = 0; line < 4; line++)
            OrderItem(
              lineId: 'L${line + 1}',
              productId: 'p${(day * 3 + i + line * 7) % 30}',
              name: 'Product ${(day * 3 + i + line * 7) % 30}',
              brand: 'Brand',
              packSize: '1',
              quantity: 1 + line,
              unitPrice: 5.0 + line,
              categoryId: 'c${(day + line) % 5}',
              category: 'Category ${(day + line) % 5}',
            ),
        ];
        final subtotal = items.fold<double>(0, (sum, i) => sum + i.lineTotal);
        final placed = DateTime(
          today.year,
          today.month,
          today.day - day,
          10 + i,
        );
        await putOrder(
          firestore,
          Order(
            id: 'o$number',
            number: number,
            customerId: 'customer',
            customerName: 'Customer',
            customerPhone: '012',
            branchId: branch,
            branchName: branch,
            isDelivery: i.isEven,
            items: items,
            subtotal: subtotal,
            deliveryFee: i.isEven ? 4 : 0,
            discount: 0,
            total: subtotal + (i.isEven ? 4 : 0),
            status: OrderStatus.completed,
            placedAt: placed,
            statusSince: placed,
          ),
        );
      }
    }
  }
  return firestore;
}

Future<SalesRepository> _repository() async {
  return SalesRepository(OrderService(await _salesDatabase()));
}

void main() {
  const desktop = Size(1600, 1200);
  const phone = Size(390, 844);
  final now = DateTime(2026, 10, 16, 15);

  group('SalesPeriod', () {
    test('presets end today and group by hour or day', () {
      final today = SalesPeriod.fromPreset(SalesPreset.today, now);
      final week = SalesPeriod.fromPreset(SalesPreset.last7Days, now);

      expect(today.start, DateTime(2026, 10, 16));
      expect(today.end, DateTime(2026, 10, 17));
      expect(today.grouping, SalesGrouping.hour);
      expect(week.days, 7);
      expect(week.grouping, SalesGrouping.day);
    });

    test('long custom periods group by week', () {
      final period = SalesPeriod.custom(
        DateTime(2026, 7),
        DateTime(2026, 9, 30),
      );

      expect(period.days, 92);
      expect(period.grouping, SalesGrouping.week);
      expect(period.previous.end, period.start);
      expect(period.previous.days, 92);
    });
  });

  group('SalesRepository', () {
    test('revenue is item sales plus delivery fees', () async {
      final period = SalesPeriod.fromPreset(
        SalesPreset.last30Days,
        DateTime.now(),
      );
      final report = await (await _repository()).getReport('ss15', period);
      final totals = report.totals;

      expect(totals.orderCount, greaterThan(0));
      expect(
        totals.revenue,
        closeTo(totals.itemSales + totals.deliveryFees, 0.01),
      );
      expect(report.points.length, 30);

      // The chart adds up to the same revenue.
      final chartTotal = report.points.fold<double>(
        0,
        (sum, p) => sum + p.revenue,
      );
      expect(chartTotal, closeTo(totals.revenue, 0.01));
    });

    test('branches are kept separate', () async {
      final repository = await _repository();
      final period = SalesPeriod.fromPreset(
        SalesPreset.last7Days,
        DateTime.now(),
      );

      final ss15 = await repository.getReport('ss15', period);
      final puchong = await repository.getReport('puchong', period);

      expect(ss15.totals.revenue, isNot(puchong.totals.revenue));
    });

    test('top products are paged, best selling first', () async {
      final period = SalesPeriod.fromPreset(
        SalesPreset.last30Days,
        DateTime.now(),
      );
      final first = await (await _repository()).getTopProducts('ss15', period);
      final revenues = first.items.map((product) => product.revenue).toList();

      expect(first.items.length, 20);
      expect(first.pageCount, greaterThan(1));
      expect(revenues, [...revenues]..sort((a, b) => b.compareTo(a)));
    });
  });

  testWidgets('Shows totals, chart, categories and top products', (
    tester,
  ) async {
    await _pumpSales(tester, desktop);

    expect(
      find.text('SS15 Subang · paid by Grocerly Wallet at checkout'),
      findsOneWidget,
    );
    expect(find.text('ITEM SALES'), findsOneWidget);
    expect(find.text('DELIVERY FEES'), findsOneWidget);
    expect(find.text('REVENUE BY DAY'), findsOneWidget);
    expect(find.text('BY CATEGORY'), findsOneWidget);
    expect(find.byType(TopProductRow), findsWidgets);
  });

  testWidgets('Picking Today groups the chart by hour', (tester) async {
    await _pumpSales(tester, desktop);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();

    expect(find.text('REVENUE BY HOUR'), findsOneWidget);
  });

  testWidgets('Phone lists top products as tiles', (tester) async {
    await _pumpSales(tester, phone);
    // Tiles are only built once scrolled into view: drag the page up until
    // the first one appears.
    final page = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    for (var i = 0; i < 30; i++) {
      if (find.byType(TopProductTile).evaluate().isNotEmpty) break;
      await tester.drag(page, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(find.byType(TopProductTile), findsWidgets);
  });
}
