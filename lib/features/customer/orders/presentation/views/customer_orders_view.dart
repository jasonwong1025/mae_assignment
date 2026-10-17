import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/customer_orders_view_model.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Customer Orders tab: the signed-in customer's orders, newest first, with
/// live status. Tapping one opens its tracking screen.
class CustomerOrdersView extends ConsumerWidget {
  const CustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(customerOrdersProvider);

    return CustomerScaffold(
      currentTab: CustomerTab.orders,
      cartCount: ref.watch(cartCountProvider),
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
          return _OrdersList(orders: orders);
        },
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Text('Your orders', style: textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.m),
          for (final order in orders) ...[
            _OrderTile(order: order),
            const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final Order order;

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
                _StatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${order.isDelivery ? 'Delivery' : 'Pickup'} · '
              '${order.itemCount == 1 ? '1 item' : '${order.itemCount} items'}'
              ' · ${Formatters.money(order.total)}',
              style: textTheme.bodyMedium,
            ),
            if (order.placedAt != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${Formatters.dayMonth(order.placedAt!)}, '
                '${Formatters.time(order.placedAt!)}',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cancelled = status == OrderStatus.cancelled;
    final background = cancelled ? AppColors.border : AppColors.greenTint;
    final foreground = cancelled
        ? AppColors.textSecondary
        : AppColors.darkGreen;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: textTheme.labelMedium?.copyWith(color: foreground),
      ),
    );
  }
}
