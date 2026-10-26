import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// Final check before an order is marked ready: every product and
/// quantity, then Mark as ready. The X in the top-right corner closes the
/// sheet and keeps packing.
/// Returns true if they marked it ready.
Future<bool> showPackingReviewSheet(BuildContext context, Order order) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Drawn below together with the close button, like the product
    // details sheet.
    showDragHandle: false,
    builder: (context) => _PackingReviewSheet(order: order),
  ).then((confirmed) => confirmed ?? false);
}

class _PackingReviewSheet extends StatelessWidget {
  const _PackingReviewSheet({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      // Leave the top of the order screen visible behind the sheet.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle in the middle, close (X) in the top-right corner.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.s,
              AppSpacing.s,
              0,
            ),
            child: Stack(
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
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.l,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Review order #${order.number}',
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Check every product and quantity in the bag before '
                    'marking the order ready.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: order.effectiveItems.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = order.effectiveItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: textTheme.bodyLarge),
                                    Text(
                                      '${item.brand} · ${item.packSize}',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.m),
                              Text(
                                '×${item.quantity}',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('Mark as ready'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
