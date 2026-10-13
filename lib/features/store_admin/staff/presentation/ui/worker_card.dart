import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../data/models/worker.dart';
import 'worker_labels.dart';

/// One worker, for the phone layout.
class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.worker,
    required this.branchName,
    required this.onTap,
  });

  final Worker worker;
  final String branchName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      // Keeps the tap ripple inside the rounded corners.
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              WorkerAvatar(name: worker.name, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${worker.role.label} · $branchName',
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${worker.rightNow} · '
                      '${worker.ordersToday.length} today',
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              WorkerStatusChip(isActive: worker.isActive),
            ],
          ),
        ),
      ),
    );
  }
}
