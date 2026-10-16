import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../data/models/dashboard_summary.dart';

/// Top card of the dashboard: today's order count, the orders-by-hour
/// chart, and a one-line revenue and driver summary.
class OrdersTodayCard extends StatelessWidget {
  const OrdersTodayCard({
    super.key,
    required this.summary,
    required this.openingHour,
  });

  final DashboardSummary summary;

  /// Hour of the first bar in the chart (24-hour clock).
  final int openingHour;

  /// "up 12 vs yesterday", "down 3 vs yesterday" or "same as yesterday".
  String get _comparedToYesterday {
    final difference = summary.ordersToday - summary.ordersYesterday;
    if (difference == 0) return 'same as yesterday';
    final direction = difference > 0 ? 'up' : 'down';
    return '$direction ${difference.abs()} vs yesterday';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final orderCount = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${summary.ordersToday}',
          style: const TextStyle(
            fontSize: 56,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'orders today · $_comparedToYesterday',
          style: textTheme.bodyMedium,
        ),
      ],
    );

    final chart = _OrdersByHourChart(
      ordersByHour: summary.ordersByHour,
      openingHour: openingHour,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Side by side when there is room, stacked on narrow screens.
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 520) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [orderCount, const SizedBox(height: 20), chart],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    orderCount,
                    const SizedBox(width: 48),
                    Expanded(child: chart),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              '${Formatters.ringgit(summary.revenue)} revenue today. '
              '${summary.driversOnRoad} of ${summary.totalDrivers} '
              'drivers on the road.',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple bar chart, one bar per hour. The last bar (the current hour)
/// is dark so it stands out.
class _OrdersByHourChart extends StatelessWidget {
  const _OrdersByHourChart({
    required this.ordersByHour,
    required this.openingHour,
  });

  final List<int> ordersByHour;
  final int openingHour;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // At least 1 so we never divide by zero on a day with no orders.
    final highest = math.max(1, ordersByHour.fold(0, math.max));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < ordersByHour.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Tooltip(
                      message:
                          '${Formatters.hour(openingHour + i)}: '
                          '${ordersByHour[i]} orders',
                      child: FractionallySizedBox(
                        // Hours with no orders still get a thin bar.
                        heightFactor: math.max(0.06, ordersByHour[i] / highest),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: i == ordersByHour.length - 1
                                ? AppColors.darkGreen
                                : AppColors.greenTint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Orders by hour, since open',
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
