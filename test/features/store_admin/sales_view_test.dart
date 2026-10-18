import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';
import 'package:mae_assignment/features/store_admin/sales/data/repositories/sales_repository.dart';
import 'package:mae_assignment/features/store_admin/sales/presentation/ui/top_products_rows.dart';
import 'package:mae_assignment/features/store_admin/sales/presentation/views/sales_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
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
      ],
      child: MaterialApp(theme: AppTheme.light, home: const SalesView()),
    ),
  );
  await tester.pumpAndSettle();
}

SalesRepository _repository() {
  return SalesRepository();
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
      final report = await _repository().getReport('ss15', period);
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
      final repository = _repository();
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
      final first = await _repository().getTopProducts('ss15', period);
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

    await tester.scrollUntilVisible(
      find.text('Top products'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byType(TopProductTile), findsWidgets);
  });
}
