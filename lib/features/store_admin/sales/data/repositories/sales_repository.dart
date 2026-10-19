import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sale.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_report.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/page_result.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(orderServiceProvider));
});

/// Error with a message to show on screen.
class SalesException extends AppException {
  const SalesException(super.message);
}

/// Sales numbers for the Sales & revenue tab. Each branch is separate.
///
/// Worked out from the branch's real orders: every order that was not
/// cancelled counts as a sale on the day it was placed (orders are paid at
/// checkout).
class SalesRepository {
  SalesRepository(this._orders);

  final OrderService _orders;

  /// Totals, chart and categories for one branch and period.
  Future<SalesReport> getReport(String branchId, SalesPeriod period) async {
    final previous = period.previous;
    final all = await _salesBetween(branchId, previous.start, period.end);
    final sales = all.where((sale) => period.contains(sale.paidAt)).toList();

    // Revenue of each category, by category id, and the names seen.
    final revenueByCategory = <String, double>{};
    final categoryNames = <String, String>{};
    for (final sale in sales) {
      for (final item in sale.items) {
        revenueByCategory[item.categoryId] =
            (revenueByCategory[item.categoryId] ?? 0) + item.lineTotal;
        if (item.categoryName.isNotEmpty) {
          categoryNames[item.categoryId] = item.categoryName;
        }
      }
    }
    final categories = [
      for (final entry in revenueByCategory.entries)
        CategorySales(
          categoryId: entry.key,
          name: categoryNames[entry.key] ?? 'Other',
          revenue: entry.value,
        ),
    ]..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Compare like with like: if the period is not over yet (e.g. today),
    // only count the period before up to the same point.
    final now = DateTime.now();
    final previousSales = all.where((sale) {
      if (!previous.contains(sale.paidAt)) return false;
      final timeIn = sale.paidAt.difference(previous.start);
      return period.start.add(timeIn).isBefore(now);
    }).toList();

    return SalesReport(
      period: period,
      totals: _totals(sales),
      previousTotals: _totals(previousSales),
      points: _points(sales, period),
      categories: categories,
    );
  }

  /// One page of products, best selling (by revenue) first.
  Future<PageResult<ProductSales>> getTopProducts(
    String branchId,
    SalesPeriod period, {
    int page = 1,
  }) async {
    // Sales of each product, by product id.
    final byProduct = <String, ProductSales>{};
    final sales = await _salesBetween(branchId, period.start, period.end);
    for (final sale in sales) {
      for (final item in sale.items) {
        final old = byProduct[item.productId];
        byProduct[item.productId] = ProductSales(
          productId: item.productId,
          name: item.productName,
          categoryName: item.categoryName.isEmpty ? 'Other' : item.categoryName,
          quantity: (old?.quantity ?? 0) + item.quantity,
          revenue: (old?.revenue ?? 0) + item.lineTotal,
        );
      }
    }

    final products = byProduct.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    return PageResult.fromList(products, page: page);
  }

  /// The branch's sales from [start] up to [end].
  Future<List<Sale>> _salesBetween(
    String branchId,
    DateTime start,
    DateTime end,
  ) {
    return guard(
      () async {
        final orders = await _orders.getBranchOrdersBetween(
          branchId,
          start,
          end,
        );
        return [
          for (final order in orders)
            if (order.status != OrderStatus.cancelled) Sale.fromOrder(order),
        ];
      },
      label: 'sales',
      onError: () =>
          const SalesException('Could not load the sales. Please try again.'),
    );
  }

  SalesTotals _totals(List<Sale> sales) {
    var itemSales = 0.0;
    var deliveryFees = 0.0;
    for (final sale in sales) {
      itemSales += sale.itemsTotal;
      deliveryFees += sale.deliveryFee;
    }
    return SalesTotals(
      itemSales: itemSales,
      deliveryFees: deliveryFees,
      orderCount: sales.length,
    );
  }

  /// Chart bars from the start to the end of [period].
  List<SalesPoint> _points(List<Sale> sales, SalesPeriod period) {
    final starts = <DateTime>[];
    var start = period.start;
    while (start.isBefore(period.end)) {
      starts.add(start);
      start = switch (period.grouping) {
        SalesGrouping.hour => start.add(const Duration(hours: 1)),
        SalesGrouping.day => DateTime(start.year, start.month, start.day + 1),
        SalesGrouping.week => DateTime(start.year, start.month, start.day + 7),
      };
    }

    // Add each sale to the last bar that starts before it.
    final revenue = List<double>.filled(starts.length, 0);
    for (final sale in sales) {
      var index = starts.length - 1;
      while (index > 0 && starts[index].isAfter(sale.paidAt)) {
        index--;
      }
      revenue[index] += sale.total;
    }

    final points = [
      for (var i = 0; i < starts.length; i++)
        SalesPoint(start: starts[i], revenue: revenue[i]),
    ];

    // By hour: leave out the closed hours before the first sale and after
    // the last one.
    if (period.grouping == SalesGrouping.hour) {
      final first = points.indexWhere((point) => point.revenue > 0);
      if (first == -1) return [];
      final last = points.lastIndexWhere((point) => point.revenue > 0);
      return points.sublist(first, last + 1);
    }
    return points;
  }
}
