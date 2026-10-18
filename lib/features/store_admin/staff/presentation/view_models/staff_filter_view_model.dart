import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

part 'staff_filter_view_model.freezed.dart';

final NotifierProvider<StaffFilterViewModel, StaffFilter>
staffFilterViewModelProvider =
    NotifierProvider.autoDispose<StaffFilterViewModel, StaffFilter>(
      StaffFilterViewModel.new,
    );

/// Which workers the Staff tab asks for: the search text and the page.
@freezed
abstract class StaffFilter with _$StaffFilter {
  const factory StaffFilter({
    @Default('') String searchText,

    /// The first page is 1.
    @Default(1) int page,
  }) = _StaffFilter;

  const StaffFilter._();
}

/// State for the search box and page buttons of the Staff tab.
class StaffFilterViewModel extends Notifier<StaffFilter> {
  @override
  StaffFilter build() {
    // Go back to page 1 when the branch changes.
    ref.listen(branchViewModelProvider, (previous, next) {
      final oldBranch = previous?.value?.selected.id;
      final newBranch = next.value?.selected.id;
      if (oldBranch != null && oldBranch != newBranch) setPage(1);
    });
    return const StaffFilter();
  }

  /// A new search starts again from page 1.
  void setSearchText(String text) {
    state = state.copyWith(searchText: text, page: 1);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }
}
