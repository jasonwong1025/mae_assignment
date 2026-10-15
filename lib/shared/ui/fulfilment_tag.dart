import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Small "Delivery" or "Pickup" tag.
/// Used by the admin order cards and the Store Worker app.
class FulfilmentTag extends StatelessWidget {
  const FulfilmentTag({super.key, required this.isDelivery});

  final bool isDelivery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDelivery
            ? AppColors.greenTint
            : AppColors.orange.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isDelivery ? 'Delivery' : 'Pickup',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
