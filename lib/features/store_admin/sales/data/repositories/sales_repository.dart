import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/sample_inventory.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sale.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_report.dart';
import 'package:mae_assignment/features/store_admin/sales/data/sample_sales.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository();
});

/// Sales numbers for the Sales & revenue tab. Each branch is separate.
/// No backend yet: works them out from sample sales kept in memory.
class SalesRepository {
  /// Names for the sample sales' category ids. The sales are sample data,
  /// so they keep their own sample categories until Sales is connected to
  /// Firestore (the live catalogue has different category ids).
  final List<ProductCategory> _categories = sampleCategories();

  /// Sales of each branch, by branch id. Made on first use.
  final Map<String, List<Sale>> _sales = {};

  /// Totals, chart and categories for one branch and period.
  Future<SalesReport> getReport(String branchId, SalesPeriod period) async {
    final sales = _salesIn(branchId, period);
    final categoryNames = {
      for (final category in _categories) category.id: category.name,
    };

    // Revenue of each category, by category id.
    final revenueByCategory = <String, double>{};
    for (final sale in sales) {
      for (final item in sale.items) {
        revenueByCategory[item.categoryId] =
            (revenueByCategory[item.categoryId] ?? 0) + item.lineTotal;
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
    final previous = period.previous;
    final previousSales = _salesIn(branchId, previous).where((sale) {
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
    final categoryNames = {
      for (final category in _categories) category.id: category.name,
    };

    // Sales of each product, by product id.
    final byProduct = <String, ProductSales>{};
    for (final sale in _salesIn(branchId, period)) {
      for (final item in sale.items) {
        final old = byProduct[item.productId];
        byProduct[item.productId] = ProductSales(
          productId: item.productId,
          name: item.productName,
          categoryName: categoryNames[item.categoryId] ?? 'Other',
          quantity: (old?.quantity ?? 0) + item.quantity,
          revenue: (old?.revenue ?? 0) + item.lineTotal,
        );
      }
    }

    final products = byProduct.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    return PageResult.fromList(products, page: page);
  }

  List<Sale> _salesIn(String branchId, SalesPeriod period) {
    final all = _sales.putIfAbsent(
      branchId,
      () => sampleSales(branchId, DateTime.now()),
    );
    return all.where((sale) => period.contains(sale.paidAt)).toList();
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
