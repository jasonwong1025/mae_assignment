import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/dashboard/data/models/dashboard_summary.dart';
import 'package:mae_assignment/features/store_admin/dashboard/presentation/ui/dashboard_card.dart';

/// "Activity" card: the latest staff actions, newest first.
class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.activity, super.key});

  final List<ActivityEntry> activity;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DashboardCard(
      title: 'Activity',
      child: activity.isEmpty
          ? Text('Nothing has happened yet.', style: textTheme.bodyMedium)
          : Column(
              children: [
                for (final entry in activity)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pushed down a little to sit beside the first
                        // line of text.
                        const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: CircleAvatar(
                            radius: 3,
                            backgroundColor: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.message,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          Formatters.minutes(entry.minutesAgo),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
