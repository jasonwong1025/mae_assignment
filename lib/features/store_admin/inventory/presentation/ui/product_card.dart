import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../data/models/inventory_item.dart';
import 'product_labels.dart';

/// One product, for the phone layout.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.item, required this.onTap});

  final InventoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = item.product;

    return Card(
      elevation: 0,
      // Keeps the tap ripple inside the rounded corners.
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ProductThumbnail(
                categoryId: product.categoryId,
                photo: product.cover,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${product.brand} · ${product.packSize}',
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Formatters.money(item.price)} · ${item.stock} in stock',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.isHidden)
                const HiddenChip()
              else
                StockStatusChip(status: item.stockStatus),
            ],
          ),
        ),
      ),
    );
  }
}
