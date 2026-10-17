import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_thumbnail.dart';

/// One product in the catalogue grid: image, name, price, a scarcity hint,
/// and an add-to-cart button. Tapping the card opens the product details.
class CustomerProductCard extends StatelessWidget {
  const CustomerProductCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
    super.key,
  });

  final CatalogueProduct product;
  final VoidCallback onTap;

  /// Adds one to the cart. Null disables the button (out of stock).
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final outOfStock = product.isOutOfStock;
    final remaining = product.lowStockRemaining;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ProductThumbnail(
                    imageUrl: product.coverImageUrl,
                    aspectRatio: 4 / 3,
                  ),
                  if (outOfStock)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Out of stock',
                            style: textTheme.labelLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Flexible(
                child: Text(
                  product.name,
                  style: textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (product.brand.isNotEmpty)
                Text(
                  product.brand,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppSpacing.xs),
              if (remaining != null)
                Text(
                  'Only $remaining left',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      Formatters.money(product.price),
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _AddButton(onPressed: onAdd),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small square "+" button, disabled (and greyed) when out of stock.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Add to cart',
      child: Material(
        color: enabled ? AppColors.darkGreen : AppColors.border,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.add_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
