import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/presentation/ui/admin_scaffold.dart';
import '../../../shell/presentation/ui/admin_sidebar.dart';
import '../../../shell/presentation/ui/filter_menu_button.dart';
import '../../../shell/presentation/ui/side_panel_frame.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/inventory_item.dart';
import '../../data/models/product.dart';
import '../ui/inventory_table.dart';
import '../ui/product_card.dart';
import '../ui/product_detail_panel.dart';
import '../ui/product_form.dart';
import '../view_models/inventory_filter_view_model.dart';
import '../view_models/inventory_view_model.dart';

/// Inventory tab: the product catalogue with the selected branch's
/// price and stock. The admin can add, edit and hide products and
/// change stock.
class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});

  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  /// Page widths where the layout changes.
  static const double _tableWidth = 720;
  static const double _sidePanelWidth = 1000;

  final _searchController = TextEditingController();

  /// Product open in the side panel.
  String? _selectedProductId;

  /// True if the side panel shows the add form.
  bool _isAdding = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _closePanel() {
    setState(() {
      _selectedProductId = null;
      _isAdding = false;
    });
  }

  /// Opens a product in the side panel, or as a full page if no room.
  void _openProduct(InventoryItem item, {required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() {
        _selectedProductId = item.product.id;
        _isAdding = false;
      });
      return;
    }

    _pushPage(
      (pageContext) => ProductDetailPanel(
        productId: item.product.id,
        onClose: () => Navigator.of(pageContext).pop(),
      ),
    );
  }

  /// Opens the add form in the side panel, or as a full page if no room.
  void _openAddForm({required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() {
        _selectedProductId = null;
        _isAdding = true;
      });
      return;
    }

    _pushPage(
      (pageContext) => _AddProductPanel(
        onClose: () => Navigator.of(pageContext).pop(),
        onAdded: (name) {
          Navigator.of(pageContext).pop();
          _showMessage('$name was added.');
        },
      ),
    );
  }

  void _pushPage(WidgetBuilder panelBuilder) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) =>
            Scaffold(body: SafeArea(child: panelBuilder(pageContext))),
      ),
    );
  }

  /// Filtered products, sorted by name.
  List<InventoryItem> _shownItems(
    List<InventoryItem> items,
    InventoryFilter filter,
  ) {
    final shown = items.where(filter.matches).toList();
    shown.sort((a, b) {
      return a.product.name.toLowerCase().compareTo(
        b.product.name.toLowerCase(),
      );
    });
    return shown;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inventory = ref.watch(inventoryViewModelProvider);
    final filter = ref.watch(inventoryFilterViewModelProvider);
    final branchName = ref.watch(branchViewModelProvider).value?.selected.name;

    return AdminScaffold(
      currentPage: AdminPage.inventory,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Width of the page without the sidebar.
          final showTable = constraints.maxWidth >= _tableWidth;
          final hasRoomForPanel = constraints.maxWidth >= _sidePanelWidth;
          final showPanel =
              hasRoomForPanel && (_isAdding || _selectedProductId != null);

          final page = Padding(
            padding: EdgeInsets.all(showTable ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  branchName: branchName,
                  isWide: showTable,
                  searchController: _searchController,
                  filter: filter,
                  categories: inventory.value?.categories ?? const [],
                  onAddProduct: () {
                    _openAddForm(inSidePanel: hasRoomForPanel);
                  },
                ),
                SizedBox(height: showTable ? 20 : 12),
                Expanded(
                  child: inventory.when(
                    // Keep the old list on screen while reloading.
                    skipLoadingOnReload: true,
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Could not load the inventory.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    data: (state) {
                      final shown = _shownItems(state.items, filter);

                      if (shown.isEmpty) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            state.items.isEmpty
                                ? 'No products yet. Add the first one.'
                                : 'No products match your search or filters.',
                            style: textTheme.bodyMedium,
                          ),
                        );
                      }

                      if (!showTable) {
                        return ListView.separated(
                          itemCount: shown.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = shown[index];
                            return ProductCard(
                              item: item,
                              onTap: () {
                                _openProduct(item, inSidePanel: false);
                              },
                            );
                          },
                        );
                      }

                      return InventoryTable(
                        items: shown,
                        inventory: state,
                        selectedProductId: showPanel
                            ? _selectedProductId
                            : null,
                        onItemTap: (item) {
                          _openProduct(item, inSidePanel: hasRoomForPanel);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );

          if (!showPanel) return page;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: page),
              const VerticalDivider(width: 1),
              SizedBox(
                width: 380,
                child: _isAdding
                    ? _AddProductPanel(
                        onClose: _closePanel,
                        onAdded: (name) {
                          _closePanel();
                          _showMessage('$name was added.');
                        },
                      )
                    // The key resets the panel when another product is
                    // opened.
                    : ProductDetailPanel(
                        key: ValueKey(_selectedProductId),
                        productId: _selectedProductId!,
                        onClose: _closePanel,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The add form inside the side panel.
class _AddProductPanel extends ConsumerWidget {
  const _AddProductPanel({required this.onClose, required this.onAdded});

  final VoidCallback onClose;

  /// Called with the new product's name.
  final ValueChanged<String> onAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchName =
        ref.watch(branchViewModelProvider).value?.selected.name ?? '';

    return SidePanelFrame(
      title: 'Add product',
      onClose: onClose,
      child: ProductForm(
        branchName: branchName,
        onCancel: onClose,
        onSaved: onAdded,
      ),
    );
  }
}

/// Title and "Add product" button, then the search box and filters.
/// No title on phones (the app bar shows it).
class _Header extends ConsumerWidget {
  const _Header({
    required this.branchName,
    required this.isWide,
    required this.searchController,
    required this.filter,
    required this.categories,
    required this.onAddProduct,
  });

  final String? branchName;
  final bool isWide;
  final TextEditingController searchController;
  final InventoryFilter filter;
  final List<ProductCategory> categories;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final viewModel = ref.read(inventoryFilterViewModelProvider.notifier);

    final search = TextField(
      controller: searchController,
      onChanged: viewModel.setSearchText,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search products',
        prefixIcon: Icon(Icons.search_rounded),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    );

    final addButton = FilledButton.icon(
      onPressed: onAddProduct,
      // Theme buttons are full width; this one fits its label.
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text(isWide ? 'Add product' : 'Add'),
    );

    final filters = [
      FilterMenuButton<String>(
        name: 'Category',
        allLabel: 'All categories',
        options: [
          for (final category in categories)
            FilterOption(value: category.id, label: category.name),
        ],
        selected: filter.categoryId,
        onSelected: viewModel.setCategory,
      ),
      FilterMenuButton<StockStatus>(
        name: 'Stock',
        allLabel: 'Any stock',
        options: [
          for (final status in StockStatus.values)
            FilterOption(value: status, label: status.label),
        ],
        selected: filter.stockStatus,
        onSelected: viewModel.setStockStatus,
      ),
      FilterMenuButton<VisibilityFilter>(
        name: 'Visibility',
        allLabel: 'Visible and hidden',
        options: [
          for (final option in VisibilityFilter.values)
            FilterOption(value: option, label: option.label),
        ],
        selected: filter.visibility,
        onSelected: viewModel.setVisibility,
      ),
    ];

    // Filters in one row. Scrolls sideways if they do not fit.
    final filterRow = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final button in filters)
            Padding(padding: const EdgeInsets.only(right: 8), child: button),
        ],
      ),
    );

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 8),
              addButton,
            ],
          ),
          const SizedBox(height: 8),
          filterRow,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inventory', style: textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    branchName == null
                        ? 'Products, prices and stock'
                        : 'Prices and stock at $branchName',
                    style: textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            addButton,
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 280, child: search),
            const SizedBox(width: 12),
            Expanded(child: filterRow),
          ],
        ),
      ],
    );
  }
}
