import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../shell/data/models/branch.dart';
import '../../data/models/worker.dart';

/// Worker's branch name. Drivers show "All branches".
String workerBranchName(Worker worker, List<Branch> branches) {
  if (worker.isDriver) return 'All branches';
  for (final branch in branches) {
    if (branch.id == worker.branchId) return branch.name;
  }
  return 'No branch';
}

/// Small "Active" or "Deactivated" tag.
class WorkerStatusChip extends StatelessWidget {
  const WorkerStatusChip({super.key, required this.isActive});

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
  const WorkerAvatar({super.key, required this.name, this.radius = 16});

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
