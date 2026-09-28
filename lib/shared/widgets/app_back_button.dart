import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

/// Square back button with a thin border (the "<" box in the wireframes).
/// Use this at the top of full-screen pages instead of an AppBar back arrow
/// so every page looks the same.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  /// Defaults to popping the current page.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed ?? () => context.pop(),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
        ),
        child: const Icon(Icons.chevron_left_rounded, size: 28),
      ),
    );
  }
}
