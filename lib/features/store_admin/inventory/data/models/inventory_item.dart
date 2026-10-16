import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';

enum StockStatus {
  inStock('In stock'),
  low('Low'),
  out('Out of stock');

  const StockStatus(this.label);

  /// Name shown on screen.
  final String label;
}

/// A product at one branch.
class InventoryItem {
  const InventoryItem({
    required this.product,
    required this.branchId,
    required this.price,
    required this.stock,
    required this.isHidden,
  });

  final Product product;
  final String branchId;

  /// Price at this branch, in ringgit.
  final double price;

  /// Stock at this branch.
  final int stock;

  /// True if hidden from customers at this branch.
  final bool isHidden;

  StockStatus get stockStatus {
    if (stock == 0) return StockStatus.out;
    if (stock <= product.lowStockLevel) return StockStatus.low;
    return StockStatus.inStock;
  }

  /// Copy with some values changed.
  InventoryItem copyWith({
    Product? product,
    double? price,
    int? stock,
    bool? isHidden,
  }) {
    return InventoryItem(
      product: product ?? this.product,
      branchId: branchId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
