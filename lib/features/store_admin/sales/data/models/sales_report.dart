import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';

/// Totals for one period.
class SalesTotals {
  const SalesTotals({
    required this.itemSales,
    required this.deliveryFees,
    required this.orderCount,
  });

  /// In ringgit.
  final double itemSales;
  final double deliveryFees;
  final int orderCount;

  double get revenue => itemSales + deliveryFees;

  /// Average money per order. 0 if there were no orders.
  double get averageOrderValue => orderCount == 0 ? 0 : revenue / orderCount;
}

/// One bar of the revenue chart.
class SalesPoint {
  const SalesPoint({required this.start, required this.revenue});

  /// Start of the hour, day or week.
  final DateTime start;
  final double revenue;
}

/// Revenue of one category in the period.
class CategorySales {
  const CategorySales({
    required this.categoryId,
    required this.name,
    required this.revenue,
  });

  final String categoryId;
  final String name;
  final double revenue;
}

/// Everything above the top products table.
class SalesReport {
  const SalesReport({
    required this.period,
    required this.totals,
    required this.previousTotals,
    required this.points,
    required this.categories,
  });

  final SalesPeriod period;
  final SalesTotals totals;

  /// The period of the same length just before, for "+12%" labels.
  final SalesTotals previousTotals;

  /// Chart bars, oldest first. Grouped by [SalesPeriod.grouping].
  final List<SalesPoint> points;

  /// Categories with sales, highest revenue first.
  final List<CategorySales> categories;
}

/// How much of one product was sold in the period.
class ProductSales {
  const ProductSales({
    required this.productId,
    required this.name,
    required this.categoryName,
    required this.quantity,
    required this.revenue,
  });

  final String productId;
  final String name;
  final String categoryName;
  final int quantity;
  final double revenue;
}
