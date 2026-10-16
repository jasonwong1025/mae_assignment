import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../../../shared/ui/fulfilment_tag.dart';
import '../../data/models/order.dart';

/// One order on the board. Tapping it opens the order's details.
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onTap,
  });

  final Order order;

  /// True while this order's details are open; draws a green border.
  final bool isSelected;
  final VoidCallback onTap;

  /// "1 item" or "4 items".
  String get _itemCountText {
    return order.itemCount == 1 ? '1 item' : '${order.itemCount} items';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      // Cuts the tap ripple to the rounded corners.
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.darkGreen : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number, and how long it has been in this column.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.number}',
                      style: textTheme.titleMedium,
                    ),
                  ),
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.minutes(order.minutesInStatus(DateTime.now())),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                order.customerName,
                style: textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '$_itemCountText · ${Formatters.money(order.total)}',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FulfilmentTag(isDelivery: order.isDelivery),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      order.assignedWorker ?? 'Unassigned',
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
