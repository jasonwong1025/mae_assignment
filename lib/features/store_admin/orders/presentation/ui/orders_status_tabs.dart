import 'package:flutter/material.dart';

import '../../data/models/order.dart';
import 'order_card.dart';
import 'orders_board.dart';

/// The board for phones: six columns do not fit, so the statuses become
/// a row of tabs and only the chosen status is listed.
class OrdersStatusTabs extends StatelessWidget {
  const OrdersStatusTabs({
    super.key,
    required this.orders,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.onOrderTap,
  });

  final List<Order> orders;

  /// The tab that is open.
  final OrderStatus selectedStatus;
  final ValueChanged<OrderStatus> onStatusSelected;
  final ValueChanged<Order> onOrderTap;

  @override
  Widget build(BuildContext context) {
    final shownOrders = ordersWithStatus(orders, selectedStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scrolls sideways because six tabs are wider than a phone.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final status in OrderStatus.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    // Status name with how many orders it has.
                    label: Text(
                      '${status.label} '
                      '${ordersWithStatus(orders, status).length}',
                    ),
                    selected: status == selectedStatus,
                    showCheckmark: false,
                    onSelected: (_) => onStatusSelected(status),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: shownOrders.isEmpty
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'No ${selectedStatus.label.toLowerCase()} orders.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.separated(
                  itemCount: shownOrders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = shownOrders[index];
                    return OrderCard(
                      order: order,
                      isSelected: false,
                      onTap: () => onOrderTap(order),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
