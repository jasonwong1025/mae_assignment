import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../../../shared/models/order_status.dart';
import '../../../../../shared/ui/button_loading_indicator.dart';
import '../../../../../shared/ui/fulfilment_tag.dart';
import '../../../../../shared/ui/order_status_label.dart';
import '../../../orders/data/models/worker_order.dart';
import 'packing_progress_bar.dart';

/// One order on My Tasks. Tapping the card opens the order.
///
/// The first order in the list is shown as "Up next" ([isNext]): bigger,
/// with a full-width Start packing or Continue packing button.
class PackingTaskCard extends StatelessWidget {
  const PackingTaskCard({
    super.key,
    required this.order,
    required this.isNext,
    required this.isStarting,
    required this.onOpen,
    required this.onStart,
  });

  final WorkerOrder order;
  final bool isNext;

  /// True while Start packing is running for this order.
  final bool isStarting;
  final VoidCallback onOpen;

  /// Null while another order is starting, which disables the button.
  final VoidCallback? onStart;

  bool get _isPacking => order.status == OrderStatus.packing;

  String get _assignedAgo {
    final minutes = Formatters.minutesSince(order.packerAssignedAt);
    return 'Assigned ${Formatters.minutes(minutes)} ago';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: isNext ? 2 : 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isNext ? 16 : 12),
        side: BorderSide(
          color: isNext ? AppColors.darkGreen : AppColors.border,
          width: isNext ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: EdgeInsets.all(isNext ? AppSpacing.l : AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isNext) ...[
                Text(
                  'UP NEXT',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              // Wrap, so the tags move to a second line on narrow screens or
              // with large text instead of overflowing.
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '#${order.number}',
                    style: isNext ? textTheme.titleLarge : textTheme.titleMedium,
                  ),
                  OrderStatusBadge(status: order.status),
                  FulfilmentTag(isDelivery: order.isDelivery),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                order.customerName,
                style: textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${order.lineCount} products · ${order.itemCount} items · '
                '$_assignedAgo',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.m),
              PackingProgressBar(order: order),
              if (isNext) ...[
                const SizedBox(height: AppSpacing.l),
                FilledButton.icon(
                  onPressed: _isPacking ? onOpen : onStart,
                  icon: isStarting
                      ? const ButtonLoadingIndicator()
                      : Icon(
                          _isPacking
                              ? Icons.arrow_forward_rounded
                              : Icons.play_arrow_rounded,
                        ),
                  label: Text(_isPacking ? 'Continue packing' : 'Start packing'),
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.s),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _isPacking ? onOpen : onStart,
                    icon: isStarting
                        ? const ButtonLoadingIndicator()
                        : Icon(
                            _isPacking
                                ? Icons.arrow_forward_rounded
                                : Icons.play_arrow_rounded,
                          ),
                    label: Text(_isPacking ? 'Continue' : 'Start'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
