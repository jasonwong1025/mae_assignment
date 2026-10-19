import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/history/presentation/view_models/worker_history_view_model.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/ui/pickup_order_card.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// How far back My history looks.
enum _HistoryRange {
  today('Today'),
  yesterday('Yesterday'),
  last7Days('Last 7 days'),
  last30Days('Last 30 days'),
  all('All time');

  const _HistoryRange(this.label);

  final String label;

  /// True if [day] (midnight) falls in this range, counted back from
  /// [today] (midnight).
  bool contains(DateTime day, DateTime today) {
    final daysAgo = today.difference(day).inDays;
    switch (this) {
      case _HistoryRange.today:
        return daysAgo == 0;
      case _HistoryRange.yesterday:
        return daysAgo == 1;
      case _HistoryRange.last7Days:
        return daysAgo < 7;
      case _HistoryRange.last30Days:
        return daysAgo < 30;
      case _HistoryRange.all:
        return true;
    }
  }
}

/// My history, opened from Account: the orders the worker packed (Packing
/// Staff) or delivered (Delivery Drivers), grouped by day, newest first.
/// A date filter and a search (in the header) narrow it down. Read-only;
/// tapping an order opens it.
class WorkerHistoryView extends ConsumerStatefulWidget {
  const WorkerHistoryView({super.key});

  @override
  ConsumerState<WorkerHistoryView> createState() => _WorkerHistoryViewState();
}

class _WorkerHistoryViewState extends ConsumerState<WorkerHistoryView> {
  _HistoryRange _range = _HistoryRange.last7Days;

  final _searchController = TextEditingController();
  String _search = '';

  /// True while the search field is open in the header.
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.workerAccount);
    }
  }

  /// Closes the search field and clears the search.
  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _search = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(workerHistoryViewModelProvider);
    final isPacker = ref.watch(workerSessionProvider)?.isPackingStaff ?? true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        // The search icon opens a search field in place of the title, the
        // same way as on Ready for Pickup.
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.horizontal,
              alignment: Alignment.centerRight,
              child: child,
            ),
          ),
          child: _isSearching
              ? TextField(
                  key: const ValueKey('history-search'),
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (text) => setState(() => _search = text),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Order number or customer',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    prefixIconConstraints: BoxConstraints(minWidth: 40),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                )
              : const Text('My history', key: ValueKey('history-title')),
        ),
        actions: [
          if (_isSearching)
            IconButton(
              tooltip: 'Close search',
              icon: const Icon(Icons.close_rounded),
              onPressed: _closeSearch,
            )
          else
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => setState(() => _isSearching = true),
            ),
          const SizedBox(width: 4),
        ],
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: history.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => ErrorState(
                message: 'Your history could not be loaded.',
                onRetry: () => ref.invalidate(workerHistoryViewModelProvider),
              ),
              data: (orders) => _HistoryList(
                orders: orders,
                isPacker: isPacker,
                range: _range,
                search: _search,
                onRangeChanged: (range) => setState(() => _range = range),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.orders,
    required this.isPacker,
    required this.range,
    required this.search,
    required this.onRangeChanged,
  });

  final List<Order> orders;
  final bool isPacker;
  final _HistoryRange range;

  /// Text in the header's search field.
  final String search;
  final ValueChanged<_HistoryRange> onRangeChanged;

  /// When the worker finished the order: packed (ready) or delivered.
  DateTime? _doneAt(Order order) {
    return isPacker ? order.readyAt : order.completedAt;
  }

  /// True if [order] matches the search: by order number (a leading "#" is
  /// ignored) or customer name, ignoring capital letters.
  bool _matches(Order order) {
    final text = search.trim().toLowerCase().replaceFirst('#', '');
    if (text.isEmpty) return true;
    return order.number.toString().contains(text) ||
        order.customerName.toLowerCase().contains(text);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isSearching = search.trim().isNotEmpty;

    final shown = orders.where((order) {
      final at = _doneAt(order);
      if (at == null || !_matches(order)) return false;
      return range.contains(DateTime(at.year, at.month, at.day), today);
    }).toList();

    // Group by day, keeping newest first.
    final byDay = <DateTime, List<Order>>{};
    for (final order in shown) {
      final at = _doneAt(order)!;
      byDay
          .putIfAbsent(DateTime(at.year, at.month, at.day), () => [])
          .add(order);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        // The date filter, with how many orders it shows.
        Row(
          children: [
            _RangeFilter(range: range, onChanged: onRangeChanged),
            const Spacer(),
            Text(
              isPacker ? '${shown.length} packed' : '${shown.length} delivered',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: EmptyState(
              icon: isSearching
                  ? Icons.search_off_rounded
                  : Icons.history_rounded,
              title: isSearching ? 'No matches' : 'Nothing here',
              message: isSearching
                  ? 'No orders match "${search.trim()}" in this period.'
                  : (isPacker
                        ? 'No orders packed in this period.'
                        : 'No deliveries completed in this period.'),
            ),
          ),
        for (final entry in byDay.entries) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.l,
              bottom: AppSpacing.s,
            ),
            child: Text(
              '${_dayLabel(entry.key, today)} (${entry.value.length})',
              style: textTheme.titleMedium,
            ),
          ),
          for (final order in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: PickupOrderCard(
                order: order,
                detail: order.isDelivery ? 'Delivery' : 'Pickup',
                detailIcon: order.isDelivery
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
                timeLabel: isPacker ? 'Packed at' : 'Delivered at',
                time: _doneAt(order),
                onTap: () => context.push(
                  isPacker
                      ? AppRoutes.workerPackingOrder(order.id)
                      : AppRoutes.workerDeliveryOrder(order.id),
                ),
              ),
            ),
        ],
      ],
    );
  }

  /// "Today", "Yesterday", or a date like "12 Mar 2026".
  static String _dayLabel(DateTime day, DateTime today) {
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return Formatters.date(day);
  }
}

/// A rounded "calendar · Last 7 days · ▾" button that opens a menu of date
/// ranges.
class _RangeFilter extends StatelessWidget {
  const _RangeFilter({required this.range, required this.onChanged});

  final _HistoryRange range;
  final ValueChanged<_HistoryRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_HistoryRange>(
      tooltip: 'Filter by date',
      initialValue: range,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final value in _HistoryRange.values)
          CheckedPopupMenuItem(
            value: value,
            checked: value == range,
            child: Text(value.label),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.s,
          AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: AppColors.greenTint,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.darkGreen,
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              range.label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.darkGreen),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.darkGreen,
            ),
          ],
        ),
      ),
    );
  }
}
