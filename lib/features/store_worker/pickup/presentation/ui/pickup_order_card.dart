import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../orders/data/models/worker_order.dart';

/// Orders due within this many minutes are highlighted in amber.
const int _dueSoonMinutes = 15;

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

/// One order on Ready for Pickup, used for all three lists (waiting for
/// pickup, waiting for drivers, handed over): order number, the customer's
/// name in large text (what the packer matches at the counter), one detail
/// line, and a time on the right.
class PickupOrderCard extends StatelessWidget {
  const PickupOrderCard({
    super.key,
    required this.order,
    required this.detail,
    required this.timeLabel,
    required this.time,
    this.highlightTime = false,
    this.onTap,
  });

  final WorkerOrder order;

  /// Line under the name, e.g. "Packed by you" or "For Amir Hamzah".
  final String detail;

  /// Small word above the time, e.g. "Pickup", "Deliver" or "Handed over".
  final String timeLabel;
  final DateTime? time;

  /// True to colour the time by how soon it is (amber soon, red late).
  final bool highlightTime;

  /// Null for read-only cards (no tap, no arrow).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final time = this.time;
    var timeColor = AppColors.textSecondary;
    if (highlightTime && time != null) {
      final minutesLeft = time.difference(DateTime.now()).inMinutes;
      if (minutesLeft < 0) {
        timeColor = AppColors.error;
      } else if (minutesLeft <= _dueSoonMinutes) {
        timeColor = AppColors.warning;
      }
    }

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
                    Text(detail, style: textTheme.bodySmall),
                  ],
                ),
              ),
              if (time != null) ...[
                const SizedBox(width: AppSpacing.s),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.schedule_rounded, size: 18, color: timeColor),
                    const SizedBox(height: 2),
                    Text(timeLabel, style: textTheme.bodySmall),
                    Text(
                      Formatters.time(time),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
