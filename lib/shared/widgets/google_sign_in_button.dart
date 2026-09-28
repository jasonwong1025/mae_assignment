import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Outlined "Continue with Google" button, shared by sign-up and login.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      icon: const Icon(Icons.g_mobiledata_rounded, size: 32),
      label: const Text('Continue with Google'),
    );
  }
}
