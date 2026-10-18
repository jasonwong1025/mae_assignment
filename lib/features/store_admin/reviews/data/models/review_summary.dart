import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';

part 'review_summary.freezed.dart';

/// Averages and counts over all of a branch's reviews.
@freezed
abstract class ReviewSummary with _$ReviewSummary {
  const factory ReviewSummary({
    required int reviewCount,

    /// Reviews of delivery orders (pickup orders have no delivery score).
    required int deliveryCount,

    /// Averages out of 5. 0 if there are no reviews.
    required double shoppingAverage,
    required double productAverage,
    required double deliveryAverage,

    /// Reviews per overall star rating. Index 0 is 1 star.
    required List<int> starCounts,

    /// Drivers who delivered for the branch, best rated first.
    required List<DriverRating> drivers,
  }) = _ReviewSummary;

  const ReviewSummary._();

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
}

/// A driver's average delivery score at one branch.
@freezed
abstract class DriverRating with _$DriverRating {
  const factory DriverRating({
    required String driverId,
    required String name,
    required double average,
    required int reviewCount,
  }) = _DriverRating;

  const DriverRating._();
}
