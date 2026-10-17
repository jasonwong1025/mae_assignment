import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';

/// Square product image with rounded corners. Shows a basket placeholder
/// while loading, when there is no image, or if the image fails to load.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    required this.imageUrl,
    super.key,
    this.borderRadius = 12,
    this.aspectRatio = 1,
  });

  final String? imageUrl;
  final double borderRadius;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.greenTint,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: imageUrl == null
              ? const _Placeholder()
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const _Placeholder();
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const _Placeholder(),
                ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.shopping_basket_outlined,
        color: AppColors.darkGreen,
        size: 32,
      ),
    );
  }
}
