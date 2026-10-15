import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';

/// Card that stands in for a tab whose real content comes in a later phase.
/// Clearly labelled so nobody mistakes it for a finished screen.
class WorkerPlaceholder extends StatelessWidget {
  const WorkerPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.comingIn,
  });

  final IconData icon;
  final String title;
  final String message;

  /// Phase that builds the real screen, e.g. "F3".
  final String comingIn;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.greenTint,
                  foregroundColor: AppColors.darkGreen,
                  child: Icon(icon, size: 32),
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  title,
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  message,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.l),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softWhite,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Placeholder · coming in phase $comingIn',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
