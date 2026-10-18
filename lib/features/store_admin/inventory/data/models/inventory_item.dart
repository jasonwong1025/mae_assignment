import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
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

/// Price, stock and visibility of a product at one branch, stored at
/// branches/{branchId}/inventory/{productId} (the document id is the
/// product id).
@freezed
abstract class BranchStock with _$BranchStock {
  const factory BranchStock({
    /// Price at this branch, in ringgit.
    required double price,

    /// Stock at this branch.
    required int stock,

    /// True if hidden from customers at this branch.
    required bool isHidden,
  }) = _BranchStock;

  const BranchStock._();

  /// Reads one inventory row (the product id is the document id).
  factory BranchStock.fromMap(Map<String, dynamic> data) {
    return BranchStock(
      price: data.requiredDecimal(InventoryFields.price),
      stock: data.requiredInteger(InventoryFields.stock),
      isHidden: data.boolean(InventoryFields.isHidden, fallback: false),
    );
  }

  /// A product that has no row at a branch: not for sale there. It shows as
  /// hidden with no stock, so saving a stock number never puts it on sale by
  /// accident.
  static const BranchStock unlisted = BranchStock(
    price: 0,
    stock: 0,
    isHidden: true,
  );

  Map<String, dynamic> toMap() {
    return {
      InventoryFields.price: price,
      InventoryFields.stock: stock,
      InventoryFields.isHidden: isHidden,
    };
  }
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

  /// A [product] with its [stock] row at [branchId].
  factory InventoryItem.of(
    Product product,
    String branchId,
    BranchStock stock,
  ) {
    return InventoryItem(
      product: product,
      branchId: branchId,
      price: stock.price,
      stock: stock.stock,
      isHidden: stock.isHidden,
    );
  }

  /// The branch row for this item.
  BranchStock get branchStock {
    return BranchStock(price: price, stock: stock, isHidden: isHidden);
  }

  StockStatus get stockStatus {
    if (stock == 0) return StockStatus.out;
    if (stock <= product.lowStockLevel) return StockStatus.low;
    return StockStatus.inStock;
  }
}
