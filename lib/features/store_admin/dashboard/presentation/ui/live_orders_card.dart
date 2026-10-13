import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../data/models/dashboard_summary.dart';
import 'dashboard_card.dart';

/// "Right now" card: every order that is not finished yet.
/// Orders with a problem are highlighted.
class LiveOrdersCard extends StatelessWidget {
  const LiveOrdersCard({super.key, required this.orders});

  final List<LiveOrder> orders;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: 'Right now',
      child: orders.isEmpty
          ? Text(
              'No open orders at the moment.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Narrow screens have no room for five columns, so the
                // status moves under the name and Delivery / Pickup is
                // left out.
                final isCompact = constraints.maxWidth < 480;
                return Column(
                  children: [
                    for (final order in orders) ...[
                      _OrderRow(order: order, isCompact: isCompact),
                      if (order != orders.last) const Divider(),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order, required this.isCompact});

  final LiveOrder order;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Customer name, with a warning icon if the order has a problem.
    final customer = Row(
      children: [
        Flexible(
          child: Text(
            order.customerName,
            style: textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (order.needsAttention) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.warning,
          ),
        ],
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: order.needsAttention
          ? BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text('#${order.number}', style: textTheme.titleMedium),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customer,
                if (isCompact) ...[
                  const SizedBox(height: 2),
                  _StatusLabel(status: order.status),
                ],
              ],
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 12),
            Expanded(flex: 3, child: _StatusLabel(status: order.status)),
            Expanded(
              flex: 2,
              child: Text(
                order.isDelivery ? 'Delivery' : 'Pickup',
                style: textTheme.bodyMedium,
              ),
            ),
          ],
          SizedBox(
            width: 56,
            child: Text(
              Formatters.minutes(order.minutesInStatus),
              style: textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloured dot followed by the status name.
class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final LiveOrderStatus status;

  Color get _color {
    switch (status) {
      case LiveOrderStatus.pending:
        return AppColors.textSecondary;
      case LiveOrderStatus.packing:
        return AppColors.info;
      case LiveOrderStatus.ready:
        return AppColors.success;
      case LiveOrderStatus.outForDelivery:
        return AppColors.darkGreen;
      case LiveOrderStatus.missingItem:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            status.label,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
