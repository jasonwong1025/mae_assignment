import 'product.dart';

enum StockStatus {
  inStock('In stock'),
  low('Low'),
  out('Out of stock');

  const StockStatus(this.label);

  /// Name shown on screen.
  final String label;
}

/// A product at one branch: its price, stock and visibility there.
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

  /// In ringgit. Each branch sets its own.
  final double price;

  /// Units this branch has.
  final int stock;

  /// True if customers of this branch cannot see it.
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
