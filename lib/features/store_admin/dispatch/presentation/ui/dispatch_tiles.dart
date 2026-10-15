import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../orders/data/models/order.dart';
import '../view_models/dispatch_state.dart';
import 'dispatch_labels.dart';

/// One driver in the drivers list, e.g. "● Amir Hamzah · Delivering #2290".
class DriverTile extends StatelessWidget {
  const DriverTile({
    super.key,
    required this.driver,
    required this.state,
    required this.isSelected,
    required this.onTap,
  });

  final DispatchDriver driver;
  final DispatchState state;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Free drivers show how far they are from the branch.
    final metres = driver.isFree
        ? driver.metresTo(state.branch.location)
        : null;
    final detail = metres == null
        ? driver.statusText
        : '${driver.statusText} · ${Formatters.distance(metres)} away';

    return Material(
      color: isSelected ? AppColors.greenTint : Colors.transparent,
      child: InkWell(
        onTap: driver.isOffline ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Opacity(
            opacity: driver.isOffline ? 0.55 : 1,
            child: Row(
              children: [
                StatusDot(color: driverColor(driver)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.worker.name,
                        style: textTheme.titleMedium?.copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        detail,
                        style: textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One delivery order, e.g. "#2292 · Ooi Hui Min" with its status.
class DeliveryTile extends StatelessWidget {
  const DeliveryTile({
    super.key,
    required this.order,
    required this.driver,
    required this.isSelected,
    required this.onTap,
  });

  final Order order;

  /// Null if the order has no driver.
  final DispatchDriver? driver;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final driver = this.driver;
    final minutes = order.minutesInStatus(DateTime.now());
    final status = deliveryStatusText(order, driver);

    return Material(
      color: isSelected ? AppColors.greenTint : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              StatusDot(color: deliveryColor(order)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.number} · ${order.customerName}',
                      style: textTheme.titleMedium?.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      driver == null
                          ? '$status · waiting ${Formatters.minutes(minutes)}'
                          : '$status · ${driver.firstName}',
                      style: textTheme.bodySmall?.copyWith(
                        color: driver == null ? AppColors.orange : null,
                        fontWeight: driver == null ? FontWeight.w700 : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
