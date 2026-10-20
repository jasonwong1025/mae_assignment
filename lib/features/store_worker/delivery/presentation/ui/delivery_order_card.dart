import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/order_due_time.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Minutes before the due time when it turns amber.
const int _dueSoonMinutes = 15;

/// Status in the driver's words, e.g. "Ready to collect".
String deliveryStatusLabel(Order order) {
  switch (order.status) {
    case OrderStatus.pending:
    case OrderStatus.packing:
      return 'Being packed';
    case OrderStatus.ready:
      return 'Ready to collect';
    case OrderStatus.outForDelivery:
      return 'Out for delivery';
    case OrderStatus.completed:
      return 'Delivered';
    case OrderStatus.cancelled:
      return 'Cancelled';
  }
}

/// Status the badge is coloured by. Pending and packing both read
/// "Being packed" to the driver, so both use the packing colour.
OrderStatus deliveryBadgeStatus(Order order) {
  return order.status == OrderStatus.pending
      ? OrderStatus.packing
      : order.status;
}

/// One delivery on My Deliveries: number, status, customer and address.
class DeliveryOrderCard extends StatelessWidget {
  const DeliveryOrderCard({
    required this.order,
    required this.onTap,
    super.key,
  });

  final Order order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isActive = order.status == OrderStatus.outForDelivery;
    final completedAt = order.completedAt;

    return Card(
      elevation: isActive ? 2 : 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? AppColors.darkGreen : AppColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('#${order.number}', style: textTheme.titleMedium),
                        OrderStatusBadge(
                          status: deliveryBadgeStatus(order),
                          label: deliveryStatusLabel(order),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  // Drivers deliver for any branch: where to collect it.
                  _BranchTag(branchName: order.branchName),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.customerName,
                style: textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      order.address ?? 'No address given',
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // When it is due, so the driver can plan the run. Not shown
              // once delivered (the delivered time replaces it).
              if (order.promisedAt != null &&
                  order.status != OrderStatus.completed &&
                  order.status != OrderStatus.cancelled) ...[
                const SizedBox(height: AppSpacing.xs),
                _DueTime(dueAt: order.promisedAt!),
              ],
              if (order.status == OrderStatus.completed &&
                  completedAt != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Delivered at ${Formatters.time(completedAt)}',
                  style: textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Deliver by 1:30pm", amber when due soon, red when overdue.
class _DueTime extends StatelessWidget {
  const _DueTime({required this.dueAt});

  final DateTime dueAt;

  @override
  Widget build(BuildContext context) {
    final minutesLeft = dueAt.difference(DateTime.now()).inMinutes;
    final color = minutesLeft < 0
        ? AppColors.error
        : (minutesLeft <= _dueSoonMinutes
              ? AppColors.warning
              : AppColors.textSecondary);

    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            'Deliver by ${Formatters.time(dueAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small tag with the branch the bag is collected from.
class _BranchTag extends StatelessWidget {
  const _BranchTag({required this.branchName});

  final String branchName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            branchName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
