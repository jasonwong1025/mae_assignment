import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// Orders due within this many minutes are highlighted in amber.
const int _dueSoonMinutes = 15;

/// Who packed [order], as shown to the worker with [workerId].
String packedByText(Order order, String workerId) {
  return order.packerId == workerId
      ? 'Packed by you'
      : 'Packed by ${order.packerName}';
}

/// Minutes since [order] became ready, never negative.
int minutesReady(Order order) {
  final readyAt = order.readyAt;
  return readyAt == null ? 0 : Formatters.minutesSince(readyAt);
}

/// One order on Ready for Pickup, used for all three lists (waiting for
/// pickup, waiting for drivers, handed over): order number, the customer's
/// name in large text (what the packer matches at the counter), one detail
/// line, and the time under it (e.g. "Pickup by 4:03am").
class PickupOrderCard extends StatelessWidget {
  const PickupOrderCard({
    required this.order,
    required this.timeLabel,
    required this.time,
    this.detail,
    this.detailIcon,
    super.key,
    this.highlightTime = false,
    this.onTap,
  });

  final Order order;

  /// Line under the name, e.g. "Driver: Amir Hamzah". Null: no line.
  final String? detail;

  /// Small icon before [detail], e.g. a truck for the driver.
  final IconData? detailIcon;

  /// Words before the time, e.g. "Pickup by" or "Deliver by".
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
                    if (detail != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (detailIcon != null) ...[
                            Icon(
                              detailIcon,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Expanded(
                            child: Text(detail!, style: textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ],
                    // Same style as the due time on My Tasks cards.
                    if (time != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: timeColor,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              '$timeLabel ${Formatters.time(time)}',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: timeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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
