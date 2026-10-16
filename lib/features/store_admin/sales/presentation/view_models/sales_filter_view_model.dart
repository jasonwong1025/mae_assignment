import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/sales_period.dart';

final salesFilterViewModelProvider =
    NotifierProvider.autoDispose<SalesFilterViewModel, SalesFilter>(
      SalesFilterViewModel.new,
    );

/// What the Sales tab shows: the period and the top products page.
class SalesFilter {
  const SalesFilter({required this.period, this.page = 1});

  final SalesPeriod period;

  /// Page of the top products table. The first page is 1.
  final int page;
}

/// State for the period picker and the top products page buttons.
/// Changing the period goes back to page 1.
class SalesFilterViewModel extends Notifier<SalesFilter> {
  @override
  SalesFilter build() {
    // Go back to page 1 when the branch changes.
    ref.listen(branchViewModelProvider, (previous, next) {
      final oldBranch = previous?.value?.selected.id;
      final newBranch = next.value?.selected.id;
      if (oldBranch != null && oldBranch != newBranch) setPage(1);
    });
    return SalesFilter(
      period: SalesPeriod.fromPreset(SalesPreset.last7Days, DateTime.now()),
    );
  }

  void setPreset(SalesPreset preset) {
    state = SalesFilter(period: SalesPeriod.fromPreset(preset, DateTime.now()));
  }

  /// [first] and [last] are both included.
  void setCustom(DateTime first, DateTime last) {
    state = SalesFilter(period: SalesPeriod.custom(first, last));
  }

  void setPage(int page) {
    state = SalesFilter(period: state.period, page: page);
  }
}
