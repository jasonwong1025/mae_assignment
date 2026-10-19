import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/orders/presentation/ui/order_actions.dart';
import 'package:mae_assignment/features/customer/orders/presentation/view_models/customer_orders_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';
import 'package:mae_assignment/shared/ui/location_map.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Live tracking for one order (wireframe 3): a status timeline, the items,
/// the price breakdown, and the fulfilment details. Pushed over the Orders
/// tab, so it has its own app bar with a back button.
class CustomerOrderTrackingView extends ConsumerWidget {
  const CustomerOrderTrackingView({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(customerOrderProvider(orderId));

    // This screen can be reached by replacing the stack (right after
    // checkout), so there may be nothing to pop. Send "back" to the Orders
    // tab, which carries the bottom navigation, rather than relying on pop.
    void goToOrders() => context.go(AppRoutes.customerOrders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to orders',
          onPressed: goToOrders,
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: 'Could not load this order. Please check your connection.',
          onRetry: () => ref.invalidate(customerOrderProvider(orderId)),
        ),
        data: (order) {
          if (order == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Order not found',
              message: 'This order may have been removed.',
              action: OutlinedButton(
                onPressed: goToOrders,
                child: const Text('Back to orders'),
              ),
            );
          }
          return _OrderBody(order: order);
        },
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _OrderHeader(order: order),
          const SizedBox(height: AppSpacing.l),
          _StatusTimeline(order: order),
          const SizedBox(height: AppSpacing.l),
          if (order.isPickup && order.status == OrderStatus.ready) ...[
            _PickupQrCard(order: order),
            const SizedBox(height: AppSpacing.l),
          ],
          _FulfilmentSummary(order: order),
          const SizedBox(height: AppSpacing.l),
          _ItemsCard(order: order),
          const SizedBox(height: AppSpacing.l),
          _TotalsCard(order: order),
          const SizedBox(height: AppSpacing.l),
          OrderActions(order: order),
        ],
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${order.number}', style: textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.placedAt == null
                    ? 'Placing…'
                    : 'Placed ${Formatters.dayMonth(order.placedAt!)}, '
                          '${Formatters.time(order.placedAt!)}',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        _StatusChip(status: order.status),
      ],
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
        style: textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}

/// The stages an order moves through, with the ones reached filled in. The
/// path depends on delivery vs pickup; a cancelled order shows a single
/// cancelled row instead.
class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.order});

  final Order order;

  List<OrderStatus> get _path {
    if (order.status == OrderStatus.cancelled) {
      return const [OrderStatus.cancelled];
    }
    return [
      OrderStatus.pending,
      OrderStatus.packing,
      OrderStatus.ready,
      if (order.isDelivery) OrderStatus.outForDelivery,
      OrderStatus.completed,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final path = _path;
    final currentIndex = path.indexOf(order.status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < path.length; i++)
            _TimelineRow(
              label: path[i].label,
              reached: currentIndex >= 0 && i <= currentIndex,
              isCurrent: i == currentIndex,
              isLast: i == path.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.reached,
    required this.isCurrent,
    required this.isLast,
  });

  final String label;
  final bool reached;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = reached ? AppColors.darkGreen : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                reached
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: color,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: color)),
            ],
          ),
          const SizedBox(width: AppSpacing.m),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.l),
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: reached ? null : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The QR code a customer shows at the counter to collect a ready pickup
/// order. The packer scans it, which proves the right person is collecting
/// the right order.
class _PickupQrCard extends StatelessWidget {
  const _PickupQrCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text('Ready for pickup', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Show this QR code at the counter of ${order.branchName}.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.m),
          // White behind the code, whatever the theme, so it scans.
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: order.handoverQrPayload,
              size: 200,
              semanticsLabel: 'Pickup QR code for order ${order.number}',
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text('Order #${order.number}', style: textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _FulfilmentSummary extends StatelessWidget {
  const _FulfilmentSummary({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
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
            children: [
              Icon(
                order.isDelivery
                    ? Icons.local_shipping_outlined
                    : Icons.storefront_outlined,
                size: 20,
                color: AppColors.darkGreen,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                order.isDelivery ? 'Delivery' : 'Self pickup',
                style: textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(order.branchName, style: textTheme.bodyMedium),
          if (order.isDelivery &&
              order.address != null &&
              order.address!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(order.address!, style: textTheme.bodyMedium),
          ],
          if (order.isDelivery && order.addressLocation != null) ...[
            const SizedBox(height: AppSpacing.s),
            LocationMap(location: order.addressLocation!),
          ],
          if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Note: ${order.customerNote}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.itemCount == 1 ? '1 item' : '${order.itemCount} items',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text('${item.quantity}×', style: textTheme.bodyMedium),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      item.brand.isEmpty
                          ? item.name
                          : '${item.name} — ${item.brand}',
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    Formatters.money(item.lineTotal),
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _row(textTheme, 'Subtotal', Formatters.money(order.subtotal)),
          if (order.isDelivery)
            _row(
              textTheme,
              'Delivery fee',
              Formatters.money(order.deliveryFee),
            ),
          if (order.discount > 0)
            _row(
              textTheme,
              'Discount',
              '−${Formatters.money(order.discount)}',
              highlight: true,
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: textTheme.titleLarge),
              Text(Formatters.money(order.total), style: textTheme.titleLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    TextTheme textTheme,
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyLarge),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              color: highlight ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}
