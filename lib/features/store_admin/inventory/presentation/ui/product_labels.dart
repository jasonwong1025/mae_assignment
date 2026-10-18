import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/product_photo_image.dart';

/// Icon for a category. New categories get a general one.
IconData categoryIcon(String categoryId) {
  switch (categoryId) {
    case 'fruits-vegetables':
    case 'produce':
      return Icons.eco_outlined;
    case 'meat-seafood':
      return Icons.set_meal_outlined;
    case 'dairy-eggs':
    case 'dairy':
      return Icons.egg_outlined;
    case 'bakery':
      return Icons.bakery_dining_outlined;
    case 'pantry':
      return Icons.kitchen_outlined;
    case 'drinks':
      return Icons.local_drink_outlined;
    case 'snacks':
      return Icons.cookie_outlined;
    case 'frozen':
      return Icons.ac_unit_rounded;
    case 'household':
      return Icons.cleaning_services_outlined;
    case 'baby':
      return Icons.child_friendly_outlined;
    default:
      return Icons.category_outlined;
  }
}

/// Cover photo, or the category icon if there is none.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    required this.categoryId,
    super.key,
    this.photo,
    this.size = 40,
  });

  final String categoryId;

  /// Cover photo. Null shows the category icon.
  final ProductPhoto? photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    if (photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 4),
        child: ProductPhotoImage(photo: photo, width: size, height: size),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        categoryIcon(categoryId),
        size: size * 0.55,
        color: AppColors.darkGreen,
      ),
    );
  }
}

/// Small "In stock", "Low" or "Out of stock" tag.
class StockStatusChip extends StatelessWidget {
  const StockStatusChip({required this.status, super.key});

  final StockStatus status;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color text;
    switch (status) {
      case StockStatus.inStock:
        background = AppColors.greenTint;
        text = AppColors.darkGreen;
      case StockStatus.low:
        background = AppColors.yellow.withValues(alpha: 0.25);
        text = AppColors.textPrimary;
      case StockStatus.out:
        background = AppColors.error.withValues(alpha: 0.12);
        text = AppColors.error;
    }

    return _Tag(label: status.label, background: background, text: text);
  }
}

/// Small "Hidden" tag.
class HiddenChip extends StatelessWidget {
  const HiddenChip({super.key});

  @override
  Widget build(BuildContext context) {
    return _Tag(
      label: 'Hidden',
      background: AppColors.border.withValues(alpha: 0.6),
      text: AppColors.textSecondary,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.text,
  });

  final String label;
  final Color background;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
