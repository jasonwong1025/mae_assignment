/// A customer's rating of one completed order.
class Review {
  const Review({
    required this.id,
    required this.orderNumber,
    required this.branchId,
    required this.customerName,
    required this.createdAt,
    required this.shoppingScore,
    required this.productScore,
    this.deliveryScore,
    this.driverId,
    this.driverName,
    this.comment,
  });

  final String id;
  final int orderNumber;
  final String branchId;
  final String customerName;
  final DateTime createdAt;

  /// Scores from 1 to 5.
  final int shoppingScore;
  final int productScore;

  /// Null for pickup orders.
  final int? deliveryScore;

  /// Driver who delivered it. Null for pickup orders.
  final String? driverId;
  final String? driverName;

  /// Written feedback. Null if the customer left none.
  final String? comment;

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
