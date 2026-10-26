import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

/// Colour that stands for each order status, used wherever a status is
/// shown (admin board and Store Worker app) so the same status always has
/// the same colour.
Color orderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return AppColors.textSecondary;
    case OrderStatus.packing:
      return AppColors.info;
    case OrderStatus.ready:
      return AppColors.success;
    case OrderStatus.outForDelivery:
      // Orange, so it stands apart from the greens of ready and completed.
      return AppColors.orange;
    case OrderStatus.completed:
      return AppColors.green;
    case OrderStatus.cancelled:
      return AppColors.error;
  }
}

/// Coloured dot followed by the status name in small capital letters,
/// e.g. "● PACKING". Used as the column heading and in the detail panel.
class OrderStatusLabel extends StatelessWidget {
  const OrderStatusLabel({required this.status, super.key});

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

/// Status as a small rounded tag in the status colour, e.g. "Packing".
/// Sized for mobile cards and headers.
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key, this.label});

  final OrderStatus status;

  /// Text to show instead of the status name, e.g. "Ready for pickup".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label ?? status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          // Grey text on its own tint is hard to read, so pending uses the
          // main text colour.
          // Pending text is dark grey; orange text is darkened so it stays
          // readable on its light orange background.
          color: switch (status) {
            OrderStatus.pending => AppColors.textPrimary,
            OrderStatus.outForDelivery => const Color(0xFFB45309),
            _ => color,
          },
        ),
      ),
    );
  }
}
