import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../data/models/order.dart';

/// Colour that stands for each order status, used wherever a status is
/// shown so the same status always has the same colour.
Color orderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return AppColors.textSecondary;
    case OrderStatus.packing:
      return AppColors.info;
    case OrderStatus.ready:
      return AppColors.success;
    case OrderStatus.outForDelivery:
      return AppColors.darkGreen;
    case OrderStatus.completed:
      return AppColors.green;
    case OrderStatus.cancelled:
      return AppColors.error;
  }
}

/// Coloured dot followed by the status name in small capital letters,
/// e.g. "● PACKING". Used as the column heading and in the detail panel.
class OrderStatusLabel extends StatelessWidget {
  const OrderStatusLabel({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: orderStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            status.label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}
