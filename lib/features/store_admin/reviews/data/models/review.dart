import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/shared/models/order_review.dart';

part 'review.freezed.dart';

/// A customer's rating of one completed order.
@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required int orderNumber,
    required String branchId,
    required String customerName,
    required DateTime createdAt,

    /// Scores from 1 to 5.
    required int shoppingScore,
    required int productScore,

    /// Null for pickup orders.
    int? deliveryScore,

    /// Driver who delivered it. Null for pickup orders.
    String? driverId,
    String? driverName,

    /// Written feedback. Null if the customer left none.
    String? comment,
  }) = _Review;

  const Review._();

  /// The admin's view of a customer's [OrderReview]. A review whose server
  /// time is still being saved counts as written now.
  factory Review.fromOrderReview(OrderReview review) {
    return Review(
      id: review.id,
      orderNumber: review.orderNumber,
      branchId: review.branchId,
      customerName: review.customerName,
      createdAt: review.createdAt ?? DateTime.now(),
      shoppingScore: review.shoppingScore,
      productScore: review.productScore,
      deliveryScore: review.deliveryScore,
      driverId: review.driverId,
      driverName: review.driverName,
      comment: review.comment,
    );
  }

  bool get isDelivery => deliveryScore != null;

  /// Average of the scores given.
  double get averageScore {
    final scores = [shoppingScore, productScore, ?deliveryScore];
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// [averageScore] rounded to whole stars, used by the star filter.
  int get stars => averageScore.round();

  /// True if [text] is in the customer's name or the order number.
  bool matchesSearch(String text) {
    final search = text.trim().toLowerCase().replaceFirst('#', '');
    if (search.isEmpty) return true;
    return customerName.toLowerCase().contains(search) ||
        orderNumber.toString().contains(search);
  }
}

/// Choices of the date filter.
enum ReviewPeriod {
  today('Today', 0),
  last7Days('Last 7 days', 7),
  last30Days('Last 30 days', 30);

  const ReviewPeriod(this.label, this.days);

  final String label;

  /// Days back from today. 0 means today only.
  final int days;
}
