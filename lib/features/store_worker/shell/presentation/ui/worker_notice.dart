import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_spacing.dart';

/// Tinted box with an icon and one or two lines telling the worker what to
/// do next, or why an order is read-only. Shared by the packing, pickup
/// and delivery screens so the notices look the same everywhere.
class WorkerNotice extends StatelessWidget {
  const WorkerNotice({
    required this.icon,
    required this.color,
    required this.text,
    super.key,
  });

  final IconData icon;

  /// Status colour, e.g. AppColors.success; used for the icon and tint.
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
