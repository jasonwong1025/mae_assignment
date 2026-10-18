import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';

part 'inventory_item.freezed.dart';

enum StockStatus {
  inStock('In stock'),
  low('Low'),
  out('Out of stock');

  const StockStatus(this.label);

  /// Name shown on screen.
  final String label;
}

/// A product at one branch.
@freezed
abstract class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required Product product,
    required String branchId,

    /// Price at this branch, in ringgit.
    required double price,

    /// Stock at this branch.
    required int stock,

    /// True if hidden from customers at this branch.
    required bool isHidden,
  }) = _InventoryItem;

  const InventoryItem._();

  StockStatus get stockStatus {
    if (stock == 0) return StockStatus.out;
    if (stock <= product.lowStockLevel) return StockStatus.low;
    return StockStatus.inStock;
  }
}
