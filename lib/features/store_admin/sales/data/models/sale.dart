import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale.freezed.dart';

/// One paid order, as Sales sees it. Orders are paid from the wallet at
/// checkout and cannot be cancelled, so every sale is final.
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
    required int quantity,

    /// Price of one when it was sold, in ringgit.
    required double unitPrice,
  }) = _SaleItem;

  const SaleItem._();

  double get lineTotal => unitPrice * quantity;
}
