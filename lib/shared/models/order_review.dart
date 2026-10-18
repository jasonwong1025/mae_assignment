import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

part 'order_review.freezed.dart';

/// A customer's rating of one completed order, stored at
/// reviews/{orderId}. The document id is the order id, so an order is rated
/// once and a review is never edited.
///
/// Scores are 1 to 5. Delivery orders are also rated on delivery; pickup
/// orders have no delivery score.
@freezed
abstract class OrderReview with _$OrderReview {
  const factory OrderReview({
    /// The order this rates (also the document id).
    required String id,
    required int orderNumber,
    required String branchId,
    required String customerId,
    required String customerName,

    /// How the shopping experience went.
    required int shoppingScore,

    /// Quality of the products.
    required int productScore,

    /// Null for pickup orders.
    int? deliveryScore,

    /// Written feedback. Null if the customer left none.
    String? comment,

    /// Null until Firestore has saved the server time.
    DateTime? createdAt,
  }) = _OrderReview;

  const OrderReview._();

  /// Reads reviews/{orderId}. A document without its required fields throws,
  /// so it is skipped when reading a list.
  factory OrderReview.fromFirestore(String id, Map<String, dynamic> data) {
    return OrderReview(
      id: id,
      orderNumber: data.requiredInteger(ReviewFields.orderNumber),
      branchId: data.requiredString(ReviewFields.branchId),
      customerId: data.requiredString(ReviewFields.customerId),
      customerName: data.string(ReviewFields.customerName),
      shoppingScore: data.requiredInteger(ReviewFields.shoppingScore),
      productScore: data.requiredInteger(ReviewFields.productScore),
      deliveryScore: data[ReviewFields.deliveryScore] is num
          ? data.integer(ReviewFields.deliveryScore)
          : null,
      comment: data.stringOrNull(ReviewFields.comment),
      createdAt: data.dateTime(ReviewFields.createdAt),
    );
  }

  /// The id is the document id, and `createdAt` is added by the service with
  /// the server time, so neither is written from here. Absent optional
  /// values are left out, which is what `firestore.rules` expects.
  Map<String, dynamic> toFirestore() {
    return {
      ReviewFields.orderNumber: orderNumber,
      ReviewFields.branchId: branchId,
      ReviewFields.customerId: customerId,
      ReviewFields.customerName: customerName,
      ReviewFields.shoppingScore: shoppingScore,
      ReviewFields.productScore: productScore,
      if (deliveryScore != null) ReviewFields.deliveryScore: deliveryScore,
      if (comment != null && comment!.isNotEmpty) ReviewFields.comment: comment,
    };
  }

  /// Average of the scores given, 1 to 5.
  double get averageScore {
    final scores = [shoppingScore, productScore, ?deliveryScore];
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}
