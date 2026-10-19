import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/shared/models/order.dart';

part 'sale.freezed.dart';

/// One paid order, as Sales sees it. Orders are paid from the wallet at
/// checkout, so every order that was not cancelled is a sale.
@freezed
abstract class Sale with _$Sale {
  const factory Sale({
    required int orderNumber,
    required String branchId,
    required DateTime paidAt,
    required bool isDelivery,

    /// In ringgit. 0 for pickup orders.
    required double deliveryFee,
    required List<SaleItem> items,
  }) = _Sale;

  const Sale._();

  /// The sale made by [order], on the day it was placed.
  factory Sale.fromOrder(Order order) {
    return Sale(
      orderNumber: order.number,
      branchId: order.branchId,
      paidAt: order.placedAt ?? order.statusStartedAt,
      isDelivery: order.isDelivery,
      deliveryFee: order.deliveryFee,
      items: [
        for (final item in order.effectiveItems)
          SaleItem(
            productId: item.productId,
            productName: item.name,
            categoryId: item.categoryId,
            categoryName: item.category,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
          ),
      ],
    );
  }

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
@freezed
abstract class SaleItem with _$SaleItem {
  const factory SaleItem({
    required String productId,
    required String productName,
    required String categoryId,

    /// Category name when it was sold. Empty if unknown.
    required String categoryName,
    required int quantity,

    /// Price of one when it was sold, in ringgit.
    required double unitPrice,
  }) = _SaleItem;

  const SaleItem._();

  double get lineTotal => unitPrice * quantity;
}
