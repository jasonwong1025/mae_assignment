import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';

/// Small "Active" or "Deactivated" tag.
/// Used by the admin Staff tab and the Store Worker app.
class WorkerStatusChip extends StatelessWidget {
  const WorkerStatusChip({required this.isActive, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.greenTint
            : AppColors.border.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isActive ? 'Active' : 'Deactivated',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.darkGreen : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Circle with the first letter of the name.
class WorkerAvatar extends StatelessWidget {
  const WorkerAvatar({required this.name, super.key, this.radius = 16});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.greenTint,
      foregroundColor: AppColors.darkGreen,
      child: Text(
        name.isEmpty ? '' : name[0].toUpperCase(),
        style: TextStyle(fontSize: radius * 0.9, fontWeight: FontWeight.w800),
      ),
    );
  }
}
