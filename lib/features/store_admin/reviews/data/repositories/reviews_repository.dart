import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review_summary.dart';
import 'package:mae_assignment/shared/models/page_result.dart';
import 'package:mae_assignment/shared/services/review_service.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.watch(reviewServiceProvider));
});

/// Error with a message to show on screen.
class ReviewsException extends AppException {
  const ReviewsException(super.message);
}

/// Customer reviews for the Reviews tab, read from the shared `reviews`
/// collection. Read only.
class ReviewsRepository {
  ReviewsRepository(this._service);

  final ReviewService _service;

  /// Averages over the branch's reviews.
  Future<ReviewSummary> getSummary(String branchId) async {
    return ReviewSummary.from(await _load(branchId));
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
    final matching = (await _load(branchId)).where((review) {
      if (stars != null && review.stars != stars) return false;
      if (driverId != null && review.driverId != driverId) return false;
      if (from != null && review.createdAt.isBefore(from)) return false;
      if (commentsOnly && review.comment == null) return false;
      return review.matchesSearch(searchText);
    }).toList();
    return PageResult.fromList(matching, page: page);
  }

  /// The branch's reviews, newest first.
  Future<List<Review>> _load(String branchId) {
    return guard(
      () async {
        final reviews = await _service.getBranchReviews(branchId);
        return [for (final review in reviews) Review.fromOrderReview(review)]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      },
      label: 'reviews',
      onError: () => const ReviewsException(
        'Could not load the reviews. Please try again.',
      ),
    );
  }
}
