import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../orders/data/models/worker_order.dart';

/// Final check before an order is marked ready: every product and
/// quantity, and a box the packer must tick to confirm.
/// Returns true if they confirmed.
Future<bool> showPackingReviewSheet(BuildContext context, WorkerOrder order) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _PackingReviewSheet(order: order),
  ).then((confirmed) => confirmed ?? false);
}

class _PackingReviewSheet extends StatefulWidget {
  const _PackingReviewSheet({required this.order});

  final WorkerOrder order;

  @override
  State<_PackingReviewSheet> createState() => _PackingReviewSheetState();
}

class _PackingReviewSheetState extends State<_PackingReviewSheet> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final order = widget.order;

    return ConstrainedBox(
      // Leave the top of the order screen visible behind the sheet.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
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
            Text('Review order #${order.number}', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Check every product and quantity in the bag before marking '
              'the order ready.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(
                            '×${item.quantity}',
                            style: textTheme.titleMedium?.copyWith(
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
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
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            CheckboxListTile(
              value: _checked,
              onChanged: (value) => setState(() => _checked = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text("I've checked all products and quantities"),
            ),
            const SizedBox(height: AppSpacing.s),
            FilledButton(
              onPressed: _checked
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: const Text('Mark as ready'),
            ),
            const SizedBox(height: AppSpacing.s),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep packing'),
            ),
          ],
        ),
      ),
    );
  }
}
