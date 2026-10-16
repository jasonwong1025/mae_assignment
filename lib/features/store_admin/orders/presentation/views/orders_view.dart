import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/store_admin/orders/data/models/order.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/ui/order_detail_panel.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/ui/orders_board.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/ui/orders_status_tabs.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/view_models/orders_filter_view_model.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/view_models/orders_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_scaffold.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_sidebar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

/// Store admin Orders tab: a live board of today's orders for the
/// selected branch, one column per status. Tapping an order shows its
/// details. The admin only monitors here and cannot change an order.
class OrdersView extends ConsumerStatefulWidget {
  const OrdersView({super.key});

  @override
  ConsumerState<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends ConsumerState<OrdersView> {
  /// Page widths (without the sidebar) at which the layout changes.
  static const double _boardWidth = 720;
  static const double _sidePanelWidth = 1000;

  final _searchController = TextEditingController();

  /// Order shown in the side panel. Null when the panel is closed.
  int? _selectedOrderNumber;

  /// Tab that is open on phones.
  OrderStatus _phoneStatus = OrderStatus.pending;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Opens the order's details: beside the board when there is room,
  /// otherwise as a full page on top of it.
  void _openOrder(Order order, {required bool inSidePanel}) {
    if (inSidePanel) {
      setState(() => _selectedOrderNumber = order.number);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (pageContext) => Scaffold(
          body: SafeArea(
            child: OrderDetailPanel(
              orderNumber: order.number,
              onClose: () => Navigator.of(pageContext).pop(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final orders = ref.watch(ordersViewModelProvider);
    final filter = ref.watch(ordersFilterViewModelProvider);
    final branch = ref.watch(branchViewModelProvider).value?.selected;

    return AdminScaffold(
      currentPage: AdminPage.orders,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Based on the space left for the page, not the whole screen,
          // because the sidebar takes some of it.
          final showBoard = constraints.maxWidth >= _boardWidth;
          final hasRoomForPanel = constraints.maxWidth >= _sidePanelWidth;
          final showPanel = hasRoomForPanel && _selectedOrderNumber != null;

          final page = Padding(
            padding: EdgeInsets.all(showBoard ? 32 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  branchName: branch?.name,
                  isWide: showBoard,
                  searchController: _searchController,
                  filter: filter,
                ),
                SizedBox(height: showBoard ? 24 : 12),
                Expanded(
                  child: orders.when(
                    // Keep showing the old branch while the new one
                    // loads, instead of flashing a spinner.
                    skipLoadingOnReload: true,
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Could not load the orders.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    data: (allOrders) {
                      final shown = allOrders.where(filter.matches).toList();

                      if (!showBoard) {
                        return OrdersStatusTabs(
                          orders: shown,
                          selectedStatus: _phoneStatus,
                          onStatusSelected: (status) {
                            setState(() => _phoneStatus = status);
                          },
                          onOrderTap: (order) {
                            _openOrder(order, inSidePanel: false);
                          },
                        );
                      }

                      return OrdersBoard(
                        orders: shown,
                        selectedOrderNumber: showPanel
                            ? _selectedOrderNumber
                            : null,
                        onOrderTap: (order) {
                          _openOrder(order, inSidePanel: hasRoomForPanel);
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
                child: OrderDetailPanel(
                  orderNumber: _selectedOrderNumber!,
                  onClose: () => setState(() => _selectedOrderNumber = null),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Page title with the search box and Filter menu.
/// On phones the title is left out because the app bar already shows it.
class _Header extends ConsumerWidget {
  const _Header({
    required this.branchName,
    required this.isWide,
    required this.searchController,
    required this.filter,
  });

  final String? branchName;
  final bool isWide;
  final TextEditingController searchController;
  final OrdersFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final viewModel = ref.read(ordersFilterViewModelProvider.notifier);

    final search = TextField(
      controller: searchController,
      onChanged: viewModel.setSearchText,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search order or name',
        prefixIcon: Icon(Icons.search_rounded),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12),
      ),
    );

    final filterMenu = _FilterMenu(
      selected: filter.fulfilment,
      onSelected: viewModel.setFulfilment,
    );

    if (!isWide) {
      return Row(
        children: [
          Expanded(child: search),
          const SizedBox(width: 8),
          filterMenu,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Orders', style: textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                branchName == null
                    ? 'Live board'
                    : 'Live board · $branchName · today',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 260, child: search),
        const SizedBox(width: 12),
        filterMenu,
      ],
    );
  }
}

/// "Filter" button that opens a menu to show all orders, only delivery
/// or only pickup. The button shows the choice when it is not "all".
class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.selected, required this.onSelected});

  final FulfilmentFilter selected;
  final ValueChanged<FulfilmentFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final isFiltering = selected != FulfilmentFilter.all;

    return PopupMenuButton<FulfilmentFilter>(
      tooltip: 'Filter orders',
      position: PopupMenuPosition.under,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in FulfilmentFilter.values)
          PopupMenuItem(
            value: option,
            child: Row(
              children: [
                // Hidden (not removed) for the other options, so every
                // label starts at the same place.
                Opacity(
                  opacity: option == selected ? 1 : 0,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(option.label),
              ],
            ),
          ),
      ],
      // Styled like the search box next to it.
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isFiltering ? AppColors.greenTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: isFiltering ? AppColors.darkGreen : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              isFiltering ? selected.label : 'Filter',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
