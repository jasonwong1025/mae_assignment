import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/assign_driver_box.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/batch_suggestion_card.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/deliveries_table.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/dispatch_labels.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/dispatch_map.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/dispatch_tiles.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_state.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_scaffold.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/admin_sidebar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/pagination_bar.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

/// Tabs on phones.
enum _PhoneTab { map, list, drivers }

/// Dispatch tab: live map of drivers and deliveries. The admin assigns a
/// driver to ready orders, or a backup driver to orders on the road.
class DispatchView extends ConsumerStatefulWidget {
  const DispatchView({super.key});

  @override
  ConsumerState<DispatchView> createState() => _DispatchViewState();
}

class _DispatchViewState extends ConsumerState<DispatchView> {
  /// Page width where the side column appears.
  static const double _wideWidth = 1000;

  /// Order in the assign box.
  int? _selectedOrderNumber;

  /// Driver highlighted on the map.
  String? _selectedDriverId;

  /// Wide screens: true for the table, false for the map.
  bool _showList = false;
  _PhoneTab _phoneTab = _PhoneTab.map;
  int _listPage = 1;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _selectOrder(Order order, {required bool isWide}) {
    setState(() {
      _selectedOrderNumber = order.number;
      _selectedDriverId = order.driverId;
    });
    if (!isWide) _openAssignSheet(order.number);
  }

  void _selectDriver(DispatchDriver driver, {required bool isWide}) {
    final order = driver.order;
    setState(() {
      _selectedDriverId = driver.id;
      // Busy with this branch's order: pick it for reassigning.
      if (order != null) _selectedOrderNumber = order.number;
    });
    if (!isWide && order != null) _openAssignSheet(order.number);
  }

  Future<String?> _assign(Order order, DispatchDriver driver) async {
    final error = await ref
        .read(dispatchViewModelProvider.notifier)
        .assignDriver(order, driver);
    if (error == null && mounted) {
      setState(() {
        _selectedOrderNumber = null;
        _selectedDriverId = driver.id;
      });
      _showMessage('#${order.number} assigned to ${driver.worker.name}.');
    }
    return error;
  }

  Future<String?> _assignBatch(
    DeliveryBatch batch,
    DispatchDriver driver,
  ) async {
    final error = await ref
        .read(dispatchViewModelProvider.notifier)
        .assignBatch(batch, driver);
    if (error == null && mounted) {
      setState(() {
        _selectedOrderNumber = null;
        _selectedDriverId = driver.id;
      });
      final numbers = batch.orders.map((order) => '#${order.number}');
      _showMessage('${numbers.join(', ')} assigned to ${driver.worker.name}.');
    }
    return error;
  }

  /// Phones: the assign box in a bottom sheet.
  void _openAssignSheet(int orderNumber) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          return Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(dispatchViewModelProvider).value;
              final order = state?.orderByNumber(orderNumber);
              if (state == null || order == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('This order is no longer waiting for a driver.'),
                );
              }

              return SafeArea(
                child: AssignDriverBox(
                  key: ValueKey(orderNumber),
                  state: state,
                  order: order,
                  onAssign: (driver) async {
                    final error = await _assign(order, driver);
                    if (error == null && sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    return error;
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dispatch = ref.watch(dispatchViewModelProvider);

    // A new branch starts with nothing picked.
    ref.listen(branchViewModelProvider, (previous, next) {
      if (previous?.value?.selected.id != next.value?.selected.id) {
        setState(() {
          _selectedOrderNumber = null;
          _selectedDriverId = null;
          _listPage = 1;
        });
      }
    });

    return AdminScaffold(
      currentPage: AdminPage.dispatch,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideWidth;

          return Padding(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: dispatch.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Could not load dispatch.',
                  style: textTheme.bodyMedium,
                ),
              ),
              data: (state) =>
                  isWide ? _wideLayout(state) : _phoneLayout(state),
            ),
          );
        },
      ),
    );
  }

  Widget _map(DispatchState state, {required bool isWide}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: DispatchMap(
        // New branch: new map, fitted to that branch.
        key: ValueKey(state.branch.id),
        state: state,
        selectedOrderNumber: _selectedOrderNumber,
        selectedDriverId: _selectedDriverId,
        onOrderTap: (order) => _selectOrder(order, isWide: isWide),
        onDriverTap: (driver) => _selectDriver(driver, isWide: isWide),
      ),
    );
  }

  /// One page of deliveries with the page buttons under it.
  Widget _pagedDeliveries(
    DispatchState state,
    Widget Function(PageResult<Order> page) builder,
  ) {
    final page = PageResult.fromList(state.deliveries, page: _listPage);
    if (page.items.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Text(
          'No deliveries right now.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: KeyedSubtree(key: ValueKey(page.page), child: builder(page)),
        ),
        const SizedBox(height: 8),
        PaginationBar(
          result: page,
          itemName: 'deliveries',
          onPageChanged: (number) => setState(() => _listPage = number),
        ),
      ],
    );
  }

  Widget _wideLayout(DispatchState state) {
    final selectedOrder = state.orderByNumber(_selectedOrderNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          state: state,
          trailing: SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Map'),
                icon: Icon(Icons.map_outlined),
              ),
              ButtonSegment(
                value: true,
                label: Text('List view'),
                icon: Icon(Icons.list_rounded),
              ),
            ],
            selected: {_showList},
            onSelectionChanged: (value) {
              setState(() => _showList = value.first);
            },
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 340,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _sideLists(state, isWide: true)),
                      const Divider(),
                      if (selectedOrder == null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Pick an order on the list or map to assign '
                            'a driver.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      else
                        AssignDriverBox(
                          // Starts again for another order or driver.
                          key: ValueKey(
                            '${selectedOrder.number}-$_selectedDriverId',
                          ),
                          state: state,
                          order: selectedOrder,
                          preselectedDriverId: _selectedDriverId,
                          onAssign: (driver) => _assign(selectedOrder, driver),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _showList
                    ? _pagedDeliveries(
                        state,
                        (page) => DeliveriesTable(
                          orders: page.items,
                          state: state,
                          selectedOrderNumber: _selectedOrderNumber,
                          onOrderTap: (order) {
                            _selectOrder(order, isWide: true);
                          },
                        ),
                      )
                    : _map(state, isWide: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Suggested trips, "Needs a driver" orders, then every driver.
  Widget _sideLists(DispatchState state, {required bool isWide}) {
    final needsDriver = state.needsDriver;
    final batches = state.batchSuggestions;

    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        // Nearby ready orders one driver could take in one trip.
        if (batches.isNotEmpty) ...[
          SectionHeading('Deliver together (${batches.length})'),
          for (final batch in batches)
            BatchSuggestionCard(
              // Starts again when the orders in it change.
              key: ValueKey(batch.key),
              state: state,
              batch: batch,
              onAssign: (driver) => _assignBatch(batch, driver),
            ),
        ],
        SectionHeading('Needs a driver (${needsDriver.length})'),
        if (needsDriver.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Every ready order has a driver.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        for (final order in needsDriver)
          DeliveryTile(
            order: order,
            driver: null,
            isSelected: order.number == _selectedOrderNumber,
            onTap: () => _selectOrder(order, isWide: isWide),
          ),
        SectionHeading('Drivers (${state.drivers.length})'),
        ..._driverTiles(state, isWide: isWide),
      ],
    );
  }

  List<Widget> _driverTiles(DispatchState state, {required bool isWide}) {
    return [
      for (final driver in state.drivers)
        DriverTile(
          driver: driver,
          state: state,
          isSelected: driver.id == _selectedDriverId,
          onTap: () => _selectDriver(driver, isWide: isWide),
        ),
    ];
  }

  Widget _phoneLayout(DispatchState state) {
    final Widget body;
    switch (_phoneTab) {
      case _PhoneTab.map:
        body = _map(state, isWide: false);
      case _PhoneTab.list:
        body = _pagedDeliveries(
          state,
          (page) => Card(
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              itemCount: page.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final order = page.items[index];
                return DeliveryTile(
                  order: order,
                  driver: state.driverOf(order),
                  isSelected: order.number == _selectedOrderNumber,
                  onTap: () => _selectOrder(order, isWide: false),
                );
              },
            ),
          ),
        );
      case _PhoneTab.drivers:
        body = Card(
          clipBehavior: Clip.antiAlias,
          child: ListView(children: _driverTiles(state, isWide: false)),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(state: state),
        const SizedBox(height: 12),
        SegmentedButton<_PhoneTab>(
          showSelectedIcon: false,
          segments: [
            const ButtonSegment(value: _PhoneTab.map, label: Text('Map')),
            ButtonSegment(
              value: _PhoneTab.list,
              label: Text('Orders (${state.deliveries.length})'),
            ),
            const ButtonSegment(
              value: _PhoneTab.drivers,
              label: Text('Drivers'),
            ),
          ],
          selected: {_phoneTab},
          onSelectionChanged: (value) {
            setState(() => _phoneTab = value.first);
          },
        ),
        const SizedBox(height: 12),
        Expanded(child: body),
      ],
    );
  }
}

/// Title and driver counts. Phones show the counts only (the app bar
/// shows the title).
class _Header extends StatelessWidget {
  const _Header({required this.state, this.trailing});

  final DispatchState state;

  /// Wide screens: the Map / List view switch.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final counts =
        '${state.freeCount} free · ${state.busyCount} busy · '
        '${state.offlineCount} offline';
    final trailing = this.trailing;

    if (trailing == null) {
      return Text(
        '${state.branch.name} · $counts',
        style: textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dispatch', style: textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                '${state.branch.name} · drivers: $counts',
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        trailing,
      ],
    );
  }
}
