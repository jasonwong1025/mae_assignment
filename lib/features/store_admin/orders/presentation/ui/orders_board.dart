import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/orders/data/models/order.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/ui/order_card.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Orders of one status, in the order they should be listed:
/// - still in progress: the longest waiting first
/// - completed: the most recent first
List<Order> ordersWithStatus(List<Order> orders, OrderStatus status) {
  final result = orders.where((order) => order.status == status).toList();

  if (status.isFinished) {
    result.sort((a, b) => b.statusSince.compareTo(a.statusSince));
    return result;
  }

  result.sort((a, b) => a.statusSince.compareTo(b.statusSince));
  return result;
}

/// The kanban board for tablet and web: one column per status, side by
/// side. Each column scrolls up and down by itself, and the whole board
/// scrolls sideways when the columns do not all fit.
class OrdersBoard extends StatelessWidget {
  const OrdersBoard({
    required this.orders,
    required this.selectedOrderNumber,
    required this.onOrderTap,
    super.key,
  });

  static const double _minColumnWidth = 200;
  static const double _gap = 12;

  final List<Order> orders;

  /// Order whose details are open, if any.
  final int? selectedOrderNumber;
  final ValueChanged<Order> onOrderTap;

  @override
  Widget build(BuildContext context) {
    const statuses = adminBoardStatuses;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Share the width equally, but never go narrower than the
        // minimum. Below that the board scrolls sideways instead.
        final spaceForColumns =
            constraints.maxWidth - _gap * (statuses.length - 1);
        final columnWidth = math.max(
          _minColumnWidth,
          spaceForColumns / statuses.length,
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: constraints.maxHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final status in statuses) ...[
                  if (status != statuses.first) const SizedBox(width: _gap),
                  SizedBox(
                    width: columnWidth,
                    child: _BoardColumn(
                      status: status,
                      orders: ordersWithStatus(orders, status),
                      selectedOrderNumber: selectedOrderNumber,
                      onOrderTap: onOrderTap,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One column: the status name with a count, then its order cards.
class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.status,
    required this.orders,
    required this.selectedOrderNumber,
    required this.onOrderTap,
  });

  final OrderStatus status;
  final List<Order> orders;
  final int? selectedOrderNumber;
  final ValueChanged<Order> onOrderTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Row(
              children: [
                Expanded(child: OrderStatusLabel(status: status)),
                Text(
                  '${orders.length}',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text('No orders', style: textTheme.bodySmall),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(6),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        isSelected: order.number == selectedOrderNumber,
                        onTap: () => onOrderTap(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
