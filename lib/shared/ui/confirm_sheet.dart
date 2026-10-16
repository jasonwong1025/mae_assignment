import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';

/// Asks the user to confirm an action that cannot be undone, in a sheet
/// that slides up from the bottom (easier to reach on a phone than a
/// dialog). Returns true if they confirmed.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.greenTint,
              foregroundColor: AppColors.darkGreen,
              child: Icon(icon, size: 28),
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
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () => Navigator.of(sheetContext).pop(true),
              child: Text(confirmLabel),
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(false),
              child: Text(cancelLabel),
            ),
          ],
        ),
      );
    },
  );
  return confirmed ?? false;
}
