import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_review.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/review_service.dart';

final Provider<ReviewRepository> reviewRepositoryProvider =
    Provider<ReviewRepository>((ref) {
      return ReviewRepository(ref.watch(reviewServiceProvider));
    });

/// Error with a message that is safe to show on screen.
class ReviewException extends AppException {
  const ReviewException(super.message);
}

/// Customers' ratings of completed orders.
class ReviewRepository {
  ReviewRepository(this._service);

  final ReviewService _service;

  /// Live review of [orderId], or null while it is not rated.
  Stream<OrderReview?> watchReview(String orderId) {
    return _service.watchReview(orderId);
  }

  /// Rates a completed [order]. Checks what the rules also check, so the
  /// customer gets a clear message instead of a bare "permission denied":
  /// the order is completed, scores are 1 to 5, a delivery order has a
  /// delivery score and a pickup order does not.
  Future<void> submit({
    required Order order,
    required AppUser customer,
    required int shoppingScore,
    required int productScore,
    int? deliveryScore,
    String? comment,
  }) async {
    if (order.status != OrderStatus.completed) {
      throw const ReviewException(
        'You can rate an order once it has been completed.',
      );
    }
    final scores = [shoppingScore, productScore, ?deliveryScore];
    if (scores.any((score) => score < 1 || score > 5)) {
      throw const ReviewException('Please give each rating from 1 to 5 stars.');
    }
    if (order.isDelivery && deliveryScore == null) {
      throw const ReviewException('Please rate the delivery too.');
    }
    final text = comment?.trim();
    if (text != null && text.length > ReviewFields.maxCommentLength) {
      throw const ReviewException(
        'Please keep your comment under '
        '${ReviewFields.maxCommentLength} characters.',
      );
    }

    final review = OrderReview(
      id: order.id,
      orderNumber: order.number,
      branchId: order.branchId,
      customerId: customer.uid,
      customerName: customer.name,
      shoppingScore: shoppingScore,
      productScore: productScore,
      // A pickup order has no delivery score, whatever the caller passed.
      deliveryScore: order.isDelivery ? deliveryScore : null,
      comment: (text == null || text.isEmpty) ? null : text,
    );
    await guard(
      () => _service.createReview(review),
      label: 'submitReview (reviews/${order.id})',
      onError: () => const ReviewException(
        'Could not save your rating. You may have rated this order already, '
        'or the connection failed.',
      ),
    );
  }
}
