import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/orders/presentation/ui/order_actions.dart';
import 'package:mae_assignment/features/customer/orders/presentation/ui/shortage_replies.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/customer_orders_view_model.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/order_actions_view_model.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/order_review_view_model.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Customer Orders tab: the signed-in customer's orders with live status,
/// split into Active (still being packed or delivered) and Past (completed
/// or cancelled). Tapping one opens its tracking screen.
class CustomerOrdersView extends ConsumerWidget {
  const CustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);

    return CustomerScaffold(
      currentTab: CustomerTab.orders,
      child: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: 'Could not load your orders. Please check your connection.',
          onRetry: () => ref.invalidate(customerOrdersProvider),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const SafeArea(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                message:
                    'Orders you place will show up here with live tracking.',
              ),
            );
          }
          return _OrdersTabs(orders: orders);
        },
      ),
    );
  }
}

/// Active · Past tabs. Opens on Active while any order is on its way, and
/// on Past otherwise.
class _OrdersTabs extends StatelessWidget {
  const _OrdersTabs({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final active = [
      for (final order in orders)
        if (!order.status.isFinished) order,
    ];
    final past = [
      for (final order in orders)
        if (order.status.isFinished) order,
    ];

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        initialIndex: active.isEmpty ? 1 : 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                0,
              ),
              child: Text('Your orders', style: textTheme.headlineSmall),
            ),
            TabBar(
              tabs: [
                Tab(
                  text: active.isEmpty ? 'Active' : 'Active (${active.length})',
                ),
                const Tab(text: 'Past'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OrdersList(
                    orders: active,
                    empty: const EmptyState(
                      icon: Icons.local_shipping_outlined,
                      title: 'No active orders',
                      message: 'Orders being packed or delivered show here.',
                    ),
                    itemBuilder: (order) => _ActiveOrderCard(order: order),
                  ),
                  _OrdersList(
                    orders: past,
                    empty: const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No past orders yet',
                      message: 'Completed and cancelled orders show here.',
                    ),
                    itemBuilder: (order) => _PastOrderCard(order: order),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.empty,
    required this.itemBuilder,
  });

  final List<Order> orders;
  final Widget empty;
  final Widget Function(Order order) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return empty;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: orders.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) => itemBuilder(orders[index]),
    );
  }
}

/// Tappable card frame shared by active and past orders.
class _OrderCardFrame extends StatelessWidget {
  const _OrderCardFrame({required this.order, required this.children});

  final Order order;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go(AppRoutes.customerOrder(order.id)),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.number}', style: textTheme.titleMedium),
                OrderStatusBadge(
                  status: order.status,
                  label: order.status == OrderStatus.ready && order.isPickup
                      ? 'Ready to collect'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${order.isDelivery ? 'Delivery' : 'Pickup'} · '
              '${order.itemCount == 1 ? '1 item' : '${order.itemCount} items'}'
              ' · ${Formatters.money(order.adjustedTotal)}',
              style: textTheme.bodyMedium,
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// An order still on its way: what happens next, how far along it is, and
/// a highlighted note when a replacement is waiting for the customer.
class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});

  final Order order;

  /// Steps the order goes through, so the bar shows how far along it is.
  /// Pickup orders finish at Ready; delivery orders also go out.
  int get _stepCount => order.isDelivery ? 4 : 3;

  int get _step => switch (order.status) {
    OrderStatus.pending => 1,
    OrderStatus.packing => 2,
    OrderStatus.ready => 3,
    _ => 4,
  };

  String _nextStep(DateTime now) {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Waiting for the store to start packing';
      case OrderStatus.packing:
        return 'Being packed · ${order.packedLineCount} of '
            '${order.lineCount} items';
      case OrderStatus.ready:
        if (order.isPickup) return 'Ready to collect at ${order.branchName}';
        final driver = order.driverName;
        return driver == null
            ? 'Packed, waiting for a driver'
            : 'Packed, $driver will pick it up soon';
      case OrderStatus.outForDelivery:
        final eta = order.etaAt(now);
        return eta == null
            ? 'On the way to you'
            : 'On the way, arriving around ${Formatters.time(eta.arrivalAt)}';
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = orderStatusColor(order.status);

    return _OrderCardFrame(
      order: order,
      children: [
        const SizedBox(height: AppSpacing.m),
        Text(
          _nextStep(DateTime.now()),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            for (var i = 1; i <= _stepCount; i++) ...[
              if (i > 1) const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= _step ? color : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (ShortageReplies.isNeeded(order)) ...[
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    'A replacement needs your answer',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (order.placedAt != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            'Placed ${Formatters.dayMonth(order.placedAt!)}, '
            '${Formatters.time(order.placedAt!)}',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// A completed or cancelled order, with shortcuts to order it again and,
/// once completed, to rate it. Cancelled orders are dimmed.
class _PastOrderCard extends ConsumerWidget {
  const _PastOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final busy = ref.watch(orderActionsViewModelProvider);
    final cancelled = order.status == OrderStatus.cancelled;
    final date = cancelled ? order.placedAt : order.completedAt;
    // Only offer Rate once we know the order has no review yet, so it can
    // never be rated twice.
    final canRate =
        order.status == OrderStatus.completed &&
        ref
                .watch(orderReviewProvider(order.id))
                .whenOrNull(data: (review) => review == null) ==
            true;

    return Opacity(
      opacity: cancelled ? 0.6 : 1,
      child: _OrderCardFrame(
        order: order,
        children: [
          if (date != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${cancelled ? 'Placed' : 'Completed'} '
              '${Formatters.dayMonth(date)}, ${Formatters.time(date)}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () => orderAgain(context, ref, order),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Reorder'),
                ),
              ),
              if (canRate) ...[
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => rateOrder(context, order),
                    icon: const Icon(Icons.star_outline_rounded),
                    label: const Text('Rate order'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
