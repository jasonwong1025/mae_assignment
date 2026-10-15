import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../orders/data/models/worker_order.dart';

/// One product on the packing checklist: photo, name, brand and pack size,
/// a large quantity, and a checkbox. The whole row can be tapped, so it is
/// easy to hit while holding groceries.
class PackingItemTile extends StatelessWidget {
  const PackingItemTile({
    super.key,
    required this.item,
    required this.isPacked,
    required this.onChanged,
  });

  final WorkerOrderItem item;
  final bool isPacked;

  /// Null makes the row read-only (e.g. before Start packing).
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = onChanged != null;

    return Card(
      elevation: 0,
      color: isPacked ? AppColors.greenTint : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPacked ? AppColors.green : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: enabled ? () => onChanged!(!isPacked) : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              _ProductImage(imageUrl: item.imageUrl),
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
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              _QuantityBadge(quantity: item.quantity),
              Checkbox(
                value: isPacked,
                onChanged: enabled
                    ? (value) => onChanged!(value ?? false)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Product photo, or a basket icon when there is none (or it fails).
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  static const double _size = 64;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: _size,
      height: _size,
      color: AppColors.softWhite,
      child: const Icon(
        Icons.shopping_basket_outlined,
        color: AppColors.textSecondary,
        size: 30,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl == null
          ? placeholder
          : Image.network(
              imageUrl!,
              width: _size,
              height: _size,
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
