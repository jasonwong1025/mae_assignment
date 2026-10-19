import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// One product on the packing checklist: photo, name, brand and pack size,
/// a large quantity, and a checkbox. Tapping the row opens the product's
/// details ([onTap]); the checkbox ticks it.
class PackingItemTile extends StatelessWidget {
  const PackingItemTile({
    required this.item,
    required this.isPacked,
    required this.onChanged,
    super.key,
    this.onTap,
    this.showCheckbox = true,
    this.note,
    this.noteColor,
    this.faded = false,
    this.onMarkUnavailable,
  });

  final OrderItem item;
  final bool isPacked;

  /// Null makes the row read-only (e.g. before Start packing).
  final ValueChanged<bool>? onChanged;

  /// Opens the product's details. Null: the row does nothing when tapped.
  final VoidCallback? onTap;

  /// False hides the checkbox, e.g. on the pickup handover screen where
  /// everything is already packed and nothing can be ticked.
  final bool showCheckbox;

  /// A line under the product, e.g. "Waiting for the customer".
  final String? note;
  final Color? noteColor;

  /// Greyed out, for a line that is no longer part of the order.
  final bool faded;

  /// Shows an "Unavailable?" button under the product. Null hides it.
  final VoidCallback? onMarkUnavailable;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = onChanged != null;

    final tile = Card(
      elevation: 0,
      color: isPacked ? AppColors.greenTint : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isPacked ? AppColors.green : AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              ProductImage(imageUrl: item.imageUrl),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${item.brand} · ${item.packSize}',
                      style: textTheme.bodyMedium,
                    ),
                    if (note != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        note!,
                        style: textTheme.bodySmall?.copyWith(
                          color: noteColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (onMarkUnavailable != null)
                      TextButton.icon(
                        onPressed: onMarkUnavailable,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 36),
                          alignment: Alignment.centerLeft,
                          foregroundColor: AppColors.error,
                        ),
                        icon: const Icon(Icons.report_gmailerrorred_rounded),
                        label: const Text('Item unavailable?'),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              _QuantityBadge(quantity: item.quantity),
              if (!showCheckbox) const SizedBox(width: AppSpacing.xs),
              // Scaled up (it does not change the layout) and round.
              if (showCheckbox)
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: isPacked,
                    shape: const CircleBorder(),
                    onChanged: enabled
                        ? (value) => onChanged!(value ?? false)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return faded ? Opacity(opacity: 0.55, child: tile) : tile;
  }
}

/// Product photo, or a basket icon when there is none (or it fails).
class ProductImage extends StatelessWidget {
  const ProductImage({required this.imageUrl, super.key, this.size = 64});

  final String? imageUrl;

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.softWhite,
      child: Icon(
        Icons.shopping_basket_outlined,
        color: AppColors.textSecondary,
        size: size * 0.47,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl == null
          ? placeholder
          : Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }
}

/// "×2" in white on dark green, big enough to read at arm's length.
class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '×$quantity',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}
