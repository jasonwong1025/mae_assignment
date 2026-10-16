import 'review.dart';

/// Averages and counts over all of a branch's reviews.
class ReviewSummary {
  const ReviewSummary({
    required this.reviewCount,
    required this.deliveryCount,
    required this.shoppingAverage,
    required this.productAverage,
    required this.deliveryAverage,
    required this.starCounts,
    required this.drivers,
  });

  /// Works out the summary from [reviews].
  factory ReviewSummary.from(List<Review> reviews) {
    double average(Iterable<int> scores) {
      if (scores.isEmpty) return 0;
      return scores.reduce((a, b) => a + b) / scores.length;
    }

    final deliveries = reviews.where((review) => review.isDelivery).toList();

    // Index 0 is 1 star, index 4 is 5 stars.
    final starCounts = List.filled(5, 0);
    for (final review in reviews) {
      starCounts[review.stars - 1]++;
    }

    // Delivery scores of each driver, by driver id.
    final scoresByDriver = <String, List<int>>{};
    final names = <String, String>{};
    for (final review in deliveries) {
      scoresByDriver.putIfAbsent(review.driverId!, () => []);
      scoresByDriver[review.driverId!]!.add(review.deliveryScore!);
      names[review.driverId!] = review.driverName!;
    }

    final drivers = [
      for (final entry in scoresByDriver.entries)
        DriverRating(
          driverId: entry.key,
          name: names[entry.key]!,
          average: average(entry.value),
          reviewCount: entry.value.length,
        ),
    ]..sort((a, b) => b.average.compareTo(a.average));

    return ReviewSummary(
      reviewCount: reviews.length,
      deliveryCount: deliveries.length,
      shoppingAverage: average(reviews.map((r) => r.shoppingScore)),
      productAverage: average(reviews.map((r) => r.productScore)),
      deliveryAverage: average(deliveries.map((r) => r.deliveryScore!)),
      starCounts: starCounts,
      drivers: drivers,
    );
  }

  final int reviewCount;

  /// Reviews of delivery orders (pickup orders have no delivery score).
  final int deliveryCount;

  /// Averages out of 5. 0 if there are no reviews.
  final double shoppingAverage;
  final double productAverage;
  final double deliveryAverage;

  /// Reviews per overall star rating. Index 0 is 1 star.
  final List<int> starCounts;

  /// Drivers who delivered for the branch, best rated first.
  final List<DriverRating> drivers;
}

/// A driver's average delivery score at one branch.
class DriverRating {
  const DriverRating({
    required this.driverId,
    required this.name,
    required this.average,
    required this.reviewCount,
  });

  final String driverId;
  final String name;
  final double average;
  final int reviewCount;
}
