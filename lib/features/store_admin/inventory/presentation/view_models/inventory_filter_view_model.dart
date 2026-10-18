import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

part 'inventory_filter_view_model.freezed.dart';

final NotifierProvider<InventoryFilterViewModel, InventoryFilter>
inventoryFilterViewModelProvider =
    NotifierProvider.autoDispose<InventoryFilterViewModel, InventoryFilter>(
      InventoryFilterViewModel.new,
    );

/// Choices of the "Visibility" filter.
enum VisibilityFilter {
  visible('Visible only'),
  hidden('Hidden only');

  const VisibilityFilter(this.label);

  final String label;
}

/// Which products the Inventory tab asks for: search text, filters and
/// page. A filter that is null is not applied.
@freezed
abstract class InventoryFilter with _$InventoryFilter {
  const factory InventoryFilter({
    @Default('') String searchText,
    String? categoryId,
    StockStatus? stockStatus,
    VisibilityFilter? visibility,

    /// The first page is 1.
    @Default(1) int page,
  }) = _InventoryFilter;

  const InventoryFilter._();

  /// True if a search or filter is narrowing the list.
  bool get isNarrowing {
    return searchText.trim().isNotEmpty ||
        categoryId != null ||
        stockStatus != null ||
        visibility != null;
  }
}

/// State for the Inventory search box, filters and page buttons.
/// Changing the search or a filter goes back to page 1.
class InventoryFilterViewModel extends Notifier<InventoryFilter> {
  @override
  InventoryFilter build() {
    // Go back to page 1 when the branch changes.
    ref.listen(branchViewModelProvider, (previous, next) {
      final oldBranch = previous?.value?.selected.id;
      final newBranch = next.value?.selected.id;
      if (oldBranch != null && oldBranch != newBranch) setPage(1);
    });
    return const InventoryFilter();
  }

  void setSearchText(String text) {
    state = state.copyWith(searchText: text, page: 1);
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, page: 1);
  }

  void setStockStatus(StockStatus? stockStatus) {
    state = state.copyWith(stockStatus: stockStatus, page: 1);
  }

  void setVisibility(VisibilityFilter? visibility) {
    state = state.copyWith(visibility: visibility, page: 1);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }
}
