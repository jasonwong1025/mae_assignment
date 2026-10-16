import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_item_tile.dart';

/// Shows one product's details in a sheet: a large photo, name,
/// description, brand, category, pack size, price and (highlighted) the
/// quantity to pack, so the packer can tell similar products apart.
///
/// If [onChanged] is given (the checklist can be ticked), the sheet also
/// has a button to mark the product packed or not packed.
Future<void> showProductDetailsSheet(
  BuildContext context, {
  required WorkerOrderItem item,
  required bool isPacked,
  ValueChanged<bool>? onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Drawn below together with the close button, so the X can sit in the
    // sheet's top-right corner.
    showDragHandle: false,
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.s,
          AppSpacing.s,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle in the middle, close (X) in the top-right corner.
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ),
              ],
            ),
            // The rest keeps the normal right margin (the header uses less,
            // so the X sits close to the corner).
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ProductImage(imageUrl: item.imageUrl, size: 160),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(item.name, style: textTheme.headlineSmall),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s),
                    Text(item.description, style: textTheme.bodyMedium),
                  ],
                  const SizedBox(height: AppSpacing.l),
                  _DetailRow(label: 'Brand', value: item.brand),
                  if (item.category.isNotEmpty)
                    _DetailRow(label: 'Category', value: item.category),
                  _DetailRow(label: 'Pack size', value: item.packSize),
                  _DetailRow(
                    label: 'Price',
                    value: '${Formatters.money(item.unitPrice)} each',
                  ),
                  // Last and highlighted: the number the packer must get right.
                  _DetailRow(
                    label: 'Quantity to pack',
                    trailing: _QuantityBadge(quantity: item.quantity),
                  ),
                  if (onChanged != null) ...[
                    const SizedBox(height: AppSpacing.xl),
                    if (isPacked)
                      OutlinedButton.icon(
                        onPressed: () {
                          onChanged(false);
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Mark as not packed'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () {
                          onChanged(true);
                          Navigator.of(sheetContext).pop();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Mark as packed'),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// "Brand" on the left, "Farm Fresh" on the right, with a line under it.
/// [trailing] replaces the value text, e.g. with a badge.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value = '', this.trailing});

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          const SizedBox(width: AppSpacing.m),
          Flexible(
            child: trailing == null
                ? Text(
                    value,
                    textAlign: TextAlign.end,
                    style: textTheme.titleMedium,
                  )
                // Same position as the other values.
                : Align(alignment: Alignment.centerLeft, child: trailing),
          ),
        ],
      ),
    );
  }
}

/// "×2" in white on dark green, like the badge on the checklist rows.
class _QuantityBadge extends StatelessWidget {
  const _QuantityBadge({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(6),
      ),
      // Same text size as the other values, so the row keeps their height.
      child: Text(
        '×$quantity',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
