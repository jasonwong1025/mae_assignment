import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_report.dart';
import 'package:mae_assignment/features/store_admin/sales/data/repositories/sales_repository.dart';
import 'package:mae_assignment/features/store_admin/sales/presentation/view_models/sales_filter_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

part 'sales_view_model.freezed.dart';

final AsyncNotifierProvider<SalesViewModel, SalesState> salesViewModelProvider =
    AsyncNotifierProvider.autoDispose<SalesViewModel, SalesState>(
      SalesViewModel.new,
    );

/// What the Sales tab shows.
@freezed
abstract class SalesState with _$SalesState {
  const factory SalesState({
    required SalesReport report,

    /// One page of the best-selling products.
    required PageResult<ProductSales> topProducts,
  }) = _SalesState;

  const SalesState._();
}

/// State for the Sales & revenue tab of the selected branch. Read only.
class SalesViewModel extends AsyncNotifier<SalesState> {
  @override
  Future<SalesState> build() async {
    // Runs again when the branch, period or page changes.
    final filter = ref.watch(salesFilterViewModelProvider);
    final branchState = await ref.watch(branchViewModelProvider.future);
    final repository = ref.watch(salesRepositoryProvider);
    final branchId = branchState.selected.id;

    return SalesState(
      report: await repository.getReport(branchId, filter.period),
      topProducts: await repository.getTopProducts(
        branchId,
        filter.period,
        page: filter.page,
      ),
    );
  }
}
