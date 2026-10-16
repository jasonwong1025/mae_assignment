import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

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
class InventoryFilter {
  const InventoryFilter({
    this.searchText = '',
    this.categoryId,
    this.stockStatus,
    this.visibility,
    this.page = 1,
  });

  final String searchText;
  final String? categoryId;
  final StockStatus? stockStatus;
  final VisibilityFilter? visibility;

  /// The first page is 1.
  final int page;

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
    state = InventoryFilter(
      searchText: text,
      categoryId: state.categoryId,
      stockStatus: state.stockStatus,
      visibility: state.visibility,
    );
  }

  void setCategory(String? categoryId) {
    state = InventoryFilter(
      searchText: state.searchText,
      categoryId: categoryId,
      stockStatus: state.stockStatus,
      visibility: state.visibility,
    );
  }

  void setStockStatus(StockStatus? stockStatus) {
    state = InventoryFilter(
      searchText: state.searchText,
      categoryId: state.categoryId,
      stockStatus: stockStatus,
      visibility: state.visibility,
    );
  }

  void setVisibility(VisibilityFilter? visibility) {
    state = InventoryFilter(
      searchText: state.searchText,
      categoryId: state.categoryId,
      stockStatus: state.stockStatus,
      visibility: visibility,
    );
  }

  void setPage(int page) {
    state = InventoryFilter(
      searchText: state.searchText,
      categoryId: state.categoryId,
      stockStatus: state.stockStatus,
      visibility: state.visibility,
      page: page,
    );
  }
}
