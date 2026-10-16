import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';

/// "3 of 5 packed" with a progress bar under it. Worked out from the
/// order's checklist, so it is always up to date.
class PackingProgressBar extends StatelessWidget {
  const PackingProgressBar({
    required this.order,
    super.key,
    this.large = false,
  });

  final WorkerOrder order;

  /// Bigger text, for the top of the packing screen.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label =
        '${order.packedLineCount} of ${order.lineCount} '
        '${large ? 'products packed' : 'packed'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: large
              ? textTheme.titleMedium
              : textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: order.packingProgress,
            minHeight: large ? 10 : 6,
          ),
        ),
      ],
    );
  }
}
