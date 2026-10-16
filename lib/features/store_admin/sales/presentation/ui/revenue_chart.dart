import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../data/models/sales_period.dart';
import '../../data/models/sales_report.dart';

/// Bar chart of revenue over the period. Hover or long-press a bar to
/// see its amount.
class RevenueChart extends StatelessWidget {
  const RevenueChart({
    super.key,
    required this.report,
    this.fillHeight = false,
  });

  static const double _chartHeight = 180;

  final SalesReport report;

  /// True to make the bars taller when the card is given more height.
  final bool fillHeight;

  String get _title {
    return switch (report.period.grouping) {
      SalesGrouping.hour => 'Revenue by hour',
      SalesGrouping.day => 'Revenue by day',
      SalesGrouping.week => 'Revenue by week',
    };
  }

  /// Name of a bar, e.g. "2pm", "12 Oct" or "week of 5 Oct".
  String _barName(SalesPoint point) {
    return switch (report.period.grouping) {
      SalesGrouping.hour => Formatters.hour(point.start.hour),
      SalesGrouping.day => Formatters.dayMonth(point.start),
      SalesGrouping.week => 'Week of ${Formatters.dayMonth(point.start)}',
    };
  }

  /// Short label under a bar, e.g. "2pm" or "12 Oct".
  String _axisLabel(SalesPoint point) {
    if (report.period.grouping == SalesGrouping.hour) {
      return Formatters.hour(point.start.hour);
    }
    return Formatters.dayMonth(point.start);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final points = report.points;
    // At least 1 so we never divide by zero.
    final highest = math.max(
      1.0,
      points.fold(0.0, (max, point) => math.max(max, point.revenue)),
    );

    final bars = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final point in points)
          Expanded(
            child: Padding(
              // Thinner gaps when there are many bars.
              padding: EdgeInsets.symmetric(
                horizontal: points.length > 20 ? 1 : 3,
              ),
              child: Tooltip(
                message:
                    '${_barName(point)}: '
                    '${Formatters.money(point.revenue)}',
                child: FractionallySizedBox(
                  // Empty bars still show a thin line.
                  heightFactor: math.max(0.02, point.revenue / highest),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _title.toUpperCase(),
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Highest: ${Formatters.money(highest)}',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (points.isEmpty)
              SizedBox(
                height: _chartHeight,
                child: Center(
                  child: Text('No sales yet.', style: textTheme.bodyMedium),
                ),
              )
            else ...[
              // Taller bars when the card is given more height.
              if (fillHeight)
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: _chartHeight),
                    child: bars,
                  ),
                )
              else
                SizedBox(height: _chartHeight, child: bars),
              const SizedBox(height: 8),
              // Labels for the first, middle and last bars only, so they fit.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_axisLabel(points.first), style: textTheme.bodySmall),
                  if (points.length > 2)
                    Text(
                      _axisLabel(points[points.length ~/ 2]),
                      style: textTheme.bodySmall,
                    ),
                  if (points.length > 1)
                    Text(_axisLabel(points.last), style: textTheme.bodySmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
