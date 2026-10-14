import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_item.dart';

final inventoryFilterViewModelProvider =
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

/// The search text and the three filters. Null means "show all".
class InventoryFilter {
  const InventoryFilter({
    this.searchText = '',
    this.categoryId,
    this.stockStatus,
    this.visibility,
  });

  final String searchText;
  final String? categoryId;
  final StockStatus? stockStatus;
  final VisibilityFilter? visibility;

  /// True if [item] should be shown.
  bool matches(InventoryItem item) {
    if (categoryId != null && item.product.categoryId != categoryId) {
      return false;
    }
    if (stockStatus != null && item.stockStatus != stockStatus) return false;
    if (visibility == VisibilityFilter.visible && item.isHidden) return false;
    if (visibility == VisibilityFilter.hidden && !item.isHidden) return false;

    // Search by product name or brand.
    final text = searchText.trim().toLowerCase();
    if (text.isEmpty) return true;
    return item.product.name.toLowerCase().contains(text) ||
        item.product.brand.toLowerCase().contains(text);
  }
}

/// State for the search box and filters of the Inventory tab.
class InventoryFilterViewModel extends Notifier<InventoryFilter> {
  @override
  InventoryFilter build() => const InventoryFilter();

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
}
