import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

final NotifierProvider<ReviewsFilterViewModel, ReviewsFilter>
reviewsFilterViewModelProvider =
    NotifierProvider.autoDispose<ReviewsFilterViewModel, ReviewsFilter>(
      ReviewsFilterViewModel.new,
    );

/// Which reviews the Reviews tab asks for: search text, filters and page.
/// A filter that is null (or false) is not applied.
class ReviewsFilter {
  const ReviewsFilter({
    this.searchText = '',
    this.stars,
    this.driverId,
    this.period,
    this.commentsOnly = false,
    this.page = 1,
  });

  final String searchText;

  /// Overall star rating, 1 to 5.
  final int? stars;
  final String? driverId;
  final ReviewPeriod? period;
  final bool commentsOnly;

  /// The first page is 1.
  final int page;

  /// True if a search or filter is narrowing the list.
  bool get isNarrowing {
    return searchText.trim().isNotEmpty ||
        stars != null ||
        driverId != null ||
        period != null ||
        commentsOnly;
  }
}

/// State for the Reviews search box, filters and page buttons.
/// Changing the search or a filter goes back to page 1.
class ReviewsFilterViewModel extends Notifier<ReviewsFilter> {
  @override
  ReviewsFilter build() {
    // A new branch has other drivers, so start again with no filters.
    ref.listen(branchViewModelProvider, (previous, next) {
      final oldBranch = previous?.value?.selected.id;
      final newBranch = next.value?.selected.id;
      if (oldBranch != null && oldBranch != newBranch) {
        state = ReviewsFilter(searchText: state.searchText);
      }
    });
    return const ReviewsFilter();
  }

  void setSearchText(String text) {
    state = ReviewsFilter(
      searchText: text,
      stars: state.stars,
      driverId: state.driverId,
      period: state.period,
      commentsOnly: state.commentsOnly,
    );
  }

  void setStars(int? stars) {
    state = ReviewsFilter(
      searchText: state.searchText,
      stars: stars,
      driverId: state.driverId,
      period: state.period,
      commentsOnly: state.commentsOnly,
    );
  }

  void setDriver(String? driverId) {
    state = ReviewsFilter(
      searchText: state.searchText,
      stars: state.stars,
      driverId: driverId,
      period: state.period,
      commentsOnly: state.commentsOnly,
    );
  }

  void setPeriod(ReviewPeriod? period) {
    state = ReviewsFilter(
      searchText: state.searchText,
      stars: state.stars,
      driverId: state.driverId,
      period: period,
      commentsOnly: state.commentsOnly,
    );
  }

  void setCommentsOnly({required bool commentsOnly}) {
    state = ReviewsFilter(
      searchText: state.searchText,
      stars: state.stars,
      driverId: state.driverId,
      period: state.period,
      commentsOnly: commentsOnly,
    );
  }

  void setPage(int page) {
    state = ReviewsFilter(
      searchText: state.searchText,
      stars: state.stars,
      driverId: state.driverId,
      period: state.period,
      commentsOnly: state.commentsOnly,
      page: page,
    );
  }
}
