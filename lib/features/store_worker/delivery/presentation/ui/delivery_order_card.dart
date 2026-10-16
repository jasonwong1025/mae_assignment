import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_progress_bar.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Status in the driver's words, e.g. "Ready to collect".
String deliveryStatusLabel(WorkerOrder order) {
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

/// One delivery on My Deliveries: number, status, customer and address.
/// Orders still being packed show their packing progress and a note that
/// they cannot be collected yet.
class DeliveryOrderCard extends StatelessWidget {
  const DeliveryOrderCard({
    required this.order,
    required this.onTap,
    super.key,
  });

  final WorkerOrder order;
  final VoidCallback onTap;

  bool get _isBeingPacked =>
      order.status == OrderStatus.pending ||
      order.status == OrderStatus.packing;

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
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('#${order.number}', style: textTheme.titleMedium),
                  OrderStatusBadge(
                    status: order.status,
                    label: deliveryStatusLabel(order),
                  ),
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
              if (_isBeingPacked) ...[
                const SizedBox(height: AppSpacing.m),
                PackingProgressBar(order: order),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'You can collect it once it is ready.',
                  style: textTheme.bodySmall,
                ),
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
