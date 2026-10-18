import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

part 'sales_filter_view_model.freezed.dart';

final NotifierProvider<SalesFilterViewModel, SalesFilter>
salesFilterViewModelProvider =
    NotifierProvider.autoDispose<SalesFilterViewModel, SalesFilter>(
      SalesFilterViewModel.new,
    );

/// What the Sales tab shows: the period and the top products page.
@freezed
abstract class SalesFilter with _$SalesFilter {
  const factory SalesFilter({
    required SalesPeriod period,

    /// Page of the top products table. The first page is 1.
    @Default(1) int page,
  }) = _SalesFilter;

  const SalesFilter._();
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
    state = state.copyWith(page: page);
  }
}
