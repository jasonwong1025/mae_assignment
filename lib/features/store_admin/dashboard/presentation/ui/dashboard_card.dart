import 'package:flutter/material.dart';

/// White card used for each block of the dashboard.
/// [title] is an optional small heading, e.g. "RIGHT NOW".
class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!.toUpperCase(),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
