import 'dart:math' as math;

import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/sample_inventory.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sale.dart';

/// About a year of sample sales for one branch, oldest first, using the
/// branch's sample products and prices. Nothing later than [now].
// TODO(team): delete once sales are read from paid orders in Firestore.
List<Sale> sampleSales(String branchId, DateTime now) {
  final setup = _setups[branchId];
  if (setup == null) return [];

  // Same seed every time, so the numbers do not change between runs.
  final random = math.Random(setup.seed);
  final products = sampleInventory()
      .where((item) => item.branchId == branchId && !item.isHidden)
      .toList();

  final sales = <Sale>[];
  var orderNumber = 1;

  for (var age = _days; age >= 0; age--) {
    final day = DateTime(now.year, now.month, now.day - age);

    // Busier at weekends, and a little busier every month.
    final isWeekend = day.weekday >= DateTime.saturday;
    final growth = 0.8 + 0.2 * (1 - age / _days);
    final orderCount =
        (setup.ordersPerDay *
                (isWeekend ? 1.3 : 1) *
                growth *
                (0.8 + random.nextDouble() * 0.4))
            .round();

    for (var i = 0; i < orderCount; i++) {
      final paidAt = day.add(
        Duration(
          hours: _busyHours[random.nextInt(_busyHours.length)],
          minutes: random.nextInt(60),
        ),
      );
      // Today: only orders placed so far.
      if (paidAt.isAfter(now)) continue;

      final isDelivery = random.nextDouble() < 0.7;
      final lineCount = 1 + random.nextInt(5);

      sales.add(
        Sale(
          orderNumber: orderNumber++,
          branchId: branchId,
          paidAt: paidAt,
          isDelivery: isDelivery,
          deliveryFee: isDelivery ? 5.0 : 0,
          items: [
            for (var line = 0; line < lineCount; line++)
              _saleItem(products[random.nextInt(products.length)], random),
          ],
        ),
      );
    }
  }

  sales.sort((a, b) => a.paidAt.compareTo(b.paidAt));
  return sales;
}

/// Days of history before today.
const _days = 400;

/// Hours orders are placed in. Busy hours are listed more than once.
const _busyHours = [
  9,
  10,
  11,
  11,
  12,
  12,
  13,
  14,
  15,
  16,
  17,
  17,
  18,
  18,
  19,
  20,
];

/// How each branch's sample sales are made.
class _BranchSetup {
  const _BranchSetup(this.seed, this.ordersPerDay);

  final int seed;
  final int ordersPerDay;
}

const _setups = {
  'ss15': _BranchSetup(1, 42),
  'bukit-jalil': _BranchSetup(2, 30),
  'puchong': _BranchSetup(3, 18),
};

SaleItem _saleItem(InventoryItem item, math.Random random) {
  final product = item.product;
  return SaleItem(
    productId: product.id,
    productName: product.name,
    categoryId: product.categoryId,
    // Mostly 1, sometimes 2 or 3.
    quantity: random.nextInt(10) < 7 ? 1 : 2 + random.nextInt(2),
    unitPrice: item.price,
  );
}
