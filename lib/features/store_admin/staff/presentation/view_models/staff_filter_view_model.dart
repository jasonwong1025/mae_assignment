import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/presentation/view_models/branch_view_model.dart';

final staffFilterViewModelProvider =
    NotifierProvider.autoDispose<StaffFilterViewModel, StaffFilter>(
      StaffFilterViewModel.new,
    );

/// Which workers the Staff tab asks for: the search text and the page.
class StaffFilter {
  const StaffFilter({this.searchText = '', this.page = 1});

  final String searchText;

  /// The first page is 1.
  final int page;
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
    state = StaffFilter(searchText: text);
  }

  void setPage(int page) {
    state = StaffFilter(searchText: state.searchText, page: page);
  }
}
