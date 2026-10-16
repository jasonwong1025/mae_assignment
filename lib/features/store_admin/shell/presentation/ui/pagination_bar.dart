import 'package:flutter/material.dart';

import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

/// Footer under a table: "1-20 of 86 products" and the page buttons.
/// On narrow screens the page numbers become "2 / 5".
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    required this.result,
    required this.itemName,
    required this.onPageChanged,
    super.key,
  });

  /// The page being shown.
  final PageResult<Object?> result;

  /// What the rows are, e.g. "products".
  final String itemName;
  final ValueChanged<int> onPageChanged;

  /// Page numbers to show. Null stands for a "..." gap.
  /// Always the first, the last, and the pages next to the current one.
  List<int?> get _pageNumbers {
    final last = result.pageCount;
    if (last <= 7) return [for (var page = 1; page <= last; page++) page];

    final current = result.page;
    return [
      1,
      if (current > 3) null,
      for (var page = current - 1; page <= current + 1; page++)
        if (page > 1 && page < last) page,
      if (current < last - 2) null,
      last,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final page = result.page;
    final lastPage = result.pageCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        return Row(
          children: [
            Expanded(
              child: Text(
                '${result.firstRow}-${result.lastRow} of '
                '${result.totalCount} $itemName',
                style: textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // One page needs no buttons.
            if (lastPage > 1) ...[
              IconButton(
                tooltip: 'Previous page',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
              ),
              if (isCompact)
                Text('$page / $lastPage', style: textTheme.labelLarge)
              else
                for (final number in _pageNumbers)
                  if (number == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('...'),
                    )
                  else
                    _PageButton(
                      number: number,
                      isCurrent: number == page,
                      onPressed: () => onPageChanged(number),
                    ),
              IconButton(
                tooltip: 'Next page',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: page < lastPage
                    ? () => onPageChanged(page + 1)
                    : null,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Small square button with a page number.
class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.number,
    required this.isCurrent,
    required this.onPressed,
  });

  final int number;
  final bool isCurrent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        // The current page is highlighted and cannot be pressed.
        onPressed: isCurrent ? null : onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(36, 36),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: isCurrent ? AppColors.greenTint : null,
          disabledForegroundColor: AppColors.darkGreen,
          foregroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('$number'),
      ),
    );
  }
}
