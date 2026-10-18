import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/reviews/data/models/review.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

part 'reviews_filter_view_model.freezed.dart';

final NotifierProvider<ReviewsFilterViewModel, ReviewsFilter>
reviewsFilterViewModelProvider =
    NotifierProvider.autoDispose<ReviewsFilterViewModel, ReviewsFilter>(
      ReviewsFilterViewModel.new,
    );

/// Which reviews the Reviews tab asks for: search text, filters and page.
/// A filter that is null (or false) is not applied.
@freezed
abstract class ReviewsFilter with _$ReviewsFilter {
  const factory ReviewsFilter({
    @Default('') String searchText,

    /// Overall star rating, 1 to 5.
    int? stars,
    String? driverId,
    ReviewPeriod? period,
    @Default(false) bool commentsOnly,

    /// The first page is 1.
    @Default(1) int page,
  }) = _ReviewsFilter;

  const ReviewsFilter._();

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
    state = state.copyWith(searchText: text, page: 1);
  }

  void setStars(int? stars) {
    state = state.copyWith(stars: stars, page: 1);
  }

  void setDriver(String? driverId) {
    state = state.copyWith(driverId: driverId, page: 1);
  }

  void setPeriod(ReviewPeriod? period) {
    state = state.copyWith(period: period, page: 1);
  }

  void setCommentsOnly({required bool commentsOnly}) {
    state = state.copyWith(commentsOnly: commentsOnly, page: 1);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }
}
