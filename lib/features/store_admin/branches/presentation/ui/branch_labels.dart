import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/shared/models/branch.dart';

const dayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// [minutes] after midnight as "8:30am".
String timeText(int minutes) {
  return Formatters.time(DateTime(2000, 1, 1, minutes ~/ 60, minutes % 60));
}

/// "8:00am - 9:00pm" or "Closed".
String hoursText(DayHours hours) {
  if (hours.isClosed) return 'Closed';
  return '${timeText(hours.opensAt)} - ${timeText(hours.closesAt)}';
}

/// "Up to 8 km · RM 3.00 + RM 0.50/km".
String deliveryText(Branch branch) {
  final km = branch.maxDeliveryKm.toStringAsFixed(
    branch.maxDeliveryKm % 1 == 0 ? 0 : 1,
  );
  return 'Up to $km km · ${Formatters.money(branch.baseDeliveryFee)} + '
      '${Formatters.money(branch.feePerKm)}/km';
}

/// Small "Open" or "Temporarily closed" tag.
class BranchStatusChip extends StatelessWidget {
  const BranchStatusChip({required this.branch, super.key});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final isOpen = !branch.isTemporarilyClosed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.greenTint
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isOpen ? 'Open' : 'Temporarily closed',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isOpen ? AppColors.darkGreen : AppColors.error,
        ),
      ),
    );
  }
}
