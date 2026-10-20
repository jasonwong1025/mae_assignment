import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/order_due_time.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_progress_bar.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/fulfilment_tag.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Orders due within this many minutes are highlighted as urgent.
const int _dueSoonMinutes = 15;

/// One order on My Tasks: number, status, pickup or delivery, customer,
/// when it is due, and packing progress.
///
/// Tapping a pending order (or its Start button) starts packing it;
/// tapping an order already being packed opens it.
class PackingTaskCard extends StatelessWidget {
  const PackingTaskCard({
    required this.order,
    required this.isStarting,
    required this.onTap,
    super.key,
  });

  final Order order;

  /// True while Start packing is running for this order.
  final bool isStarting;

  /// Null while another order is starting, which disables the card.
  final VoidCallback? onTap;

  bool get _isPending => order.status == OrderStatus.pending;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap, so the status badge drops under the number on
                  // narrow screens or with large text.
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.s,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('#${order.number}', style: textTheme.titleLarge),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  FulfilmentTag(isDelivery: order.isDelivery),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.customerName,
                style: textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
              if (order.promisedAt != null) ...[
                const SizedBox(height: AppSpacing.xs),
                _DueTime(order: order),
              ],
              const SizedBox(height: AppSpacing.m),
              // Pending: the order size and Start on one row, in exactly the
              // space the progress bar takes on a packing card (an invisible
              // copy of it sets the height), so every card is the same size.
              if (_isPending)
                Stack(
                  children: [
                    Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: PackingProgressBar(order: order),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${order.lineCount} products · '
                              '${order.itemCount} items',
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: onTap,
                            // Small enough to fit the progress bar's height;
                            // the whole card is tappable as well.
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s,
                                vertical: AppSpacing.xs,
                              ),
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: isStarting
                                ? const ButtonLoadingIndicator()
                                : const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                PackingProgressBar(order: order),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Pickup by 1:30pm", amber when due soon, red when overdue.
class _DueTime extends StatelessWidget {
  const _DueTime({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final dueAt = order.promisedAt!;
    final minutesLeft = dueAt.difference(DateTime.now()).inMinutes;
    final isLate = minutesLeft < 0;
    final color = isLate
        ? AppColors.error
        : (minutesLeft <= _dueSoonMinutes
              ? AppColors.warning
              : AppColors.textSecondary);
    final verb = order.isDelivery ? 'Deliver by' : 'Pickup by';

    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            '$verb ${Formatters.time(dueAt)}',
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
