import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_state.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

/// Free drivers are green, busy blue, offline grey.
Color driverColor(DispatchDriver driver) {
  if (driver.isFree) return AppColors.success;
  if (driver.isBusy) return AppColors.info;
  return AppColors.textSecondary;
}

/// Orders without a driver are orange, the rest blue.
Color deliveryColor(Order order) {
  return order.driverId == null ? AppColors.orange : AppColors.info;
}

/// Where a delivery is at, e.g. "Needs a driver".
String deliveryStatusText(Order order, DispatchDriver? driver) {
  if (driver == null) return 'Needs a driver';
  if (order.status == OrderStatus.outForDelivery) return 'Out for delivery';

  final atBranch = driver.location?.stops.isEmpty ?? false;
  return atBranch ? 'Driver at branch' : 'Driver going to branch';
}

/// Small coloured dot.
class StatusDot extends StatelessWidget {
  const StatusDot({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Small heading such as "NEEDS A DRIVER (2)".
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
