/// One paid order, as Sales sees it. Orders are paid from the wallet at
/// checkout and cannot be cancelled, so every sale is final.
class Sale {
  const Sale({
    required this.orderNumber,
    required this.branchId,
    required this.paidAt,
    required this.isDelivery,
    required this.deliveryFee,
    required this.items,
  });

  final int orderNumber;
  final String branchId;
  final DateTime paidAt;
  final bool isDelivery;

  /// In ringgit. 0 for pickup orders.
  final double deliveryFee;
  final List<SaleItem> items;

  double get itemsTotal {
    var sum = 0.0;
    for (final item in items) {
      sum += item.lineTotal;
    }
    return sum;
  }

  double get total => itemsTotal + deliveryFee;
}

/// One product line of a sale.
class SaleItem {
  const SaleItem({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final String categoryId;
  final int quantity;

  /// Price of one when it was sold, in ringgit.
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;
}
