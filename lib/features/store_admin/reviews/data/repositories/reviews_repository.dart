import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review_summary.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/sample_reviews.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository();
});

/// Customer reviews for the Reviews tab. Read only.
/// No backend yet: returns sample reviews.
class ReviewsRepository {
  final List<Review> _reviews = sampleReviews(DateTime.now());

  /// Averages over all of the branch's reviews.
  Future<ReviewSummary> getSummary(String branchId) async {
    return ReviewSummary.from(
      _reviews.where((review) => review.branchId == branchId).toList(),
    );
  }

  /// One page of the branch's reviews, newest first.
  /// A filter that is null (or false) is not applied.
  Future<PageResult<Review>> getReviews(
    String branchId, {
    String searchText = '',
    int? stars,
    String? driverId,
    ReviewPeriod? period,
    bool commentsOnly = false,
    int page = 1,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = period == null
        ? null
        : today.subtract(Duration(days: period.days));

    final matching = _reviews.where((review) {
      if (review.branchId != branchId) return false;
      if (stars != null && review.stars != stars) return false;
      if (driverId != null && review.driverId != driverId) return false;
      if (from != null && review.createdAt.isBefore(from)) return false;
      if (commentsOnly && review.comment == null) return false;
      return review.matchesSearch(searchText);
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return PageResult.fromList(matching, page: page);
  }
}
