import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../orders/data/models/worker_order.dart';

/// Orders waiting at least this long are highlighted, so they get handed
/// over (or followed up) first.
const int _longWaitMinutes = 30;

/// Who packed [order], as shown to the worker with [workerId].
String packedByText(WorkerOrder order, String workerId) {
  return order.packerId == workerId
      ? 'Packed by you'
      : 'Packed by ${order.packerName}';
}

/// Minutes since [order] became ready, never negative.
int minutesReady(WorkerOrder order) {
  final readyAt = order.readyAt;
  return readyAt == null ? 0 : Formatters.minutesSince(readyAt);
}

/// One order in Ready for Pickup. The customer's name is large because
/// that is what the packer matches against the person at the counter.
class PickupOrderCard extends StatelessWidget {
  const PickupOrderCard({
    super.key,
    required this.order,
    required this.workerId,
    required this.onTap,
  });

  final WorkerOrder order;

  /// The signed-in packer, to show "Packed by you".
  final String workerId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final waited = minutesReady(order);
    final longWait = waited >= _longWaitMinutes;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.number}', style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      order.customerName,
                      style: textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${order.lineCount} products · ${order.itemCount} items'
                      ' · ${packedByText(order, workerId)}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: longWait ? AppColors.warning : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.minutes(waited),
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: longWait
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text('waiting', style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
