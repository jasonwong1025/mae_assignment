import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/models/page_result.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/review.dart';
import '../../data/models/review_summary.dart';
import '../../data/repositories/reviews_repository.dart';
import 'reviews_filter_view_model.dart';

final reviewsViewModelProvider =
    AsyncNotifierProvider.autoDispose<ReviewsViewModel, ReviewsState>(
      ReviewsViewModel.new,
    );

/// What the Reviews tab shows.
class ReviewsState {
  const ReviewsState({required this.summary, required this.page});

  /// Averages over all of the branch's reviews (not filtered).
  final ReviewSummary summary;

  /// One page of the filtered reviews.
  final PageResult<Review> page;
}

/// State for the Reviews tab. Read only: reviews cannot be changed here.
class ReviewsViewModel extends AsyncNotifier<ReviewsState> {
  @override
  Future<ReviewsState> build() async {
    // Runs again when the branch, search, a filter or the page changes.
    final filter = ref.watch(reviewsFilterViewModelProvider);
    final branchState = await ref.watch(branchViewModelProvider.future);
    final repository = ref.watch(reviewsRepositoryProvider);
    final branchId = branchState.selected.id;

    return ReviewsState(
      summary: await repository.getSummary(branchId),
      page: await repository.getReviews(
        branchId,
        searchText: filter.searchText,
        stars: filter.stars,
        driverId: filter.driverId,
        period: filter.period,
        commentsOnly: filter.commentsOnly,
        page: filter.page,
      ),
    );
  }
}
