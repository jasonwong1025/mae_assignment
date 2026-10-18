import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';

part 'sales_report.freezed.dart';

/// Totals for one period.
@freezed
abstract class SalesTotals with _$SalesTotals {
  const factory SalesTotals({
    /// In ringgit.
    required double itemSales,
    required double deliveryFees,
    required int orderCount,
  }) = _SalesTotals;

  const SalesTotals._();

  double get revenue => itemSales + deliveryFees;

  /// Average money per order. 0 if there were no orders.
  double get averageOrderValue => orderCount == 0 ? 0 : revenue / orderCount;
}

/// One bar of the revenue chart.
@freezed
abstract class SalesPoint with _$SalesPoint {
  const factory SalesPoint({
    /// Start of the hour, day or week.
    required DateTime start,
    required double revenue,
  }) = _SalesPoint;

  const SalesPoint._();
}

/// Revenue of one category in the period.
@freezed
abstract class CategorySales with _$CategorySales {
  const factory CategorySales({
    required String categoryId,
    required String name,
    required double revenue,
  }) = _CategorySales;

  const CategorySales._();
}

/// Everything above the top products table.
@freezed
abstract class SalesReport with _$SalesReport {
  const factory SalesReport({
    required SalesPeriod period,
    required SalesTotals totals,

    /// The period of the same length just before, for "+12%" labels.
    required SalesTotals previousTotals,

    /// Chart bars, oldest first. Grouped by [SalesPeriod.grouping].
    required List<SalesPoint> points,

    /// Categories with sales, highest revenue first.
    required List<CategorySales> categories,
  }) = _SalesReport;

  const SalesReport._();
}

/// How much of one product was sold in the period.
@freezed
abstract class ProductSales with _$ProductSales {
  const factory ProductSales({
    required String productId,
    required String name,
    required String categoryName,
    required int quantity,
    required double revenue,
  }) = _ProductSales;

  const ProductSales._();
}
