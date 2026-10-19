import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review_summary.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/repositories/reviews_repository.dart';
import 'package:mae_assignment/features/store_admin/reviews/presentation/view_models/reviews_filter_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

part 'reviews_view_model.freezed.dart';

final AsyncNotifierProvider<ReviewsViewModel, ReviewsState>
reviewsViewModelProvider =
    AsyncNotifierProvider.autoDispose<ReviewsViewModel, ReviewsState>(
      ReviewsViewModel.new,
    );

/// What the Reviews tab shows.
@freezed
abstract class ReviewsState with _$ReviewsState {
  const factory ReviewsState({
    /// Averages over all of the branch's reviews (not filtered).
    required ReviewSummary summary,

    /// One page of the filtered reviews.
    required PageResult<Review> page,
  }) = _ReviewsState;

  const ReviewsState._();
}

/// State for the Reviews tab. Read only: reviews cannot be changed here.
class ReviewsViewModel extends AsyncNotifier<ReviewsState> {
  @override
  Future<ReviewsState> build() async {
    // Runs again when the branch, search, a filter or the page changes.
    final filter = ref.watch(reviewsFilterViewModelProvider);
    // Read before the first await: the provider can be disposed while it
    // waits (for example on sign-out), and a disposed ref cannot be used.
    final repository = ref.watch(reviewsRepositoryProvider);
    final branchState = await ref.watch(branchViewModelProvider.future);
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
