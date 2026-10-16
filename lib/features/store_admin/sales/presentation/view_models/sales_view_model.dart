import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/models/page_result.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/sales_report.dart';
import '../../data/repositories/sales_repository.dart';
import 'sales_filter_view_model.dart';

final salesViewModelProvider =
    AsyncNotifierProvider.autoDispose<SalesViewModel, SalesState>(
      SalesViewModel.new,
    );

/// What the Sales tab shows.
class SalesState {
  const SalesState({required this.report, required this.topProducts});

  final SalesReport report;

  /// One page of the best-selling products.
  final PageResult<ProductSales> topProducts;
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
