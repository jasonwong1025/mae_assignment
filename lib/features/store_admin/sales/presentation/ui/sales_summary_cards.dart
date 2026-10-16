import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_report.dart';

/// Revenue, item sales, delivery fees, orders and average order value,
/// each compared with the period before.
class SalesSummaryCards extends StatelessWidget {
  const SalesSummaryCards({required this.report, super.key});

  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final now = report.totals;
    final before = report.previousTotals;

    final cards = [
      _NumberCard(
        label: 'Revenue',
        value: Formatters.money(now.revenue),
        current: now.revenue,
        previous: before.revenue,
        isMain: true,
      ),
      _NumberCard(
        label: 'Item sales',
        value: Formatters.money(now.itemSales),
        current: now.itemSales,
        previous: before.itemSales,
      ),
      _NumberCard(
        label: 'Delivery fees',
        value: Formatters.money(now.deliveryFees),
        current: now.deliveryFees,
        previous: before.deliveryFees,
      ),
      _NumberCard(
        label: 'Orders',
        value: '${now.orderCount}',
        current: now.orderCount.toDouble(),
        previous: before.orderCount.toDouble(),
      ),
      _NumberCard(
        label: 'Average order',
        value: Formatters.money(now.averageOrderValue),
        current: now.averageOrderValue,
        previous: before.averageOrderValue,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 5 in a row when wide, then 3, then 2.
        final width = constraints.maxWidth;
        final perRow = width >= 1000
            ? 5
            : width >= 600
            ? 3
            : 2;
        const gap = 12.0;
        final cardWidth = (width - gap * (perRow - 1)) / perRow;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({
    required this.label,
    required this.value,
    required this.current,
    required this.previous,
    this.isMain = false,
  });

  final String label;
  final String value;

  /// Used for the "+12%" change.
  final double current;
  final double previous;

  /// The revenue card is green to stand out.
  final bool isMain;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: isMain ? AppColors.greenTint : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: textTheme.titleLarge),
            ),
            const SizedBox(height: 4),
            _Change(current: current, previous: previous),
          ],
        ),
      ),
    );
  }
}

/// Change from the period before, e.g. "12% vs before" with an up arrow
/// in green, or a down arrow in red.
class _Change extends StatelessWidget {
  const _Change({required this.current, required this.previous});

  final double current;
  final double previous;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    if (previous == 0) {
      return Text('No sales before', style: style);
    }

    final percent = ((current - previous) / previous * 100).round();
    if (percent == 0) return Text('Same as before', style: style);

    final isUp = percent > 0;
    final color = isUp ? AppColors.success : AppColors.error;
    return Row(
      children: [
        Icon(
          isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            '${percent.abs()}% vs before',
            style: style?.copyWith(color: color, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
