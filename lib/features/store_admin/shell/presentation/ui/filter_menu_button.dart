import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_theme.dart';

/// One choice in a [FilterMenuButton].
class FilterOption<T> {
  const FilterOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Button that opens a menu to filter a list by one thing.
/// The first menu item is always "all" and means no filter.
class FilterMenuButton<T> extends StatelessWidget {
  const FilterMenuButton({
    super.key,
    required this.name,
    required this.allLabel,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  /// Shown on the button when nothing is chosen, e.g. "Category".
  final String name;

  /// First menu item, e.g. "All categories".
  final String allLabel;
  final List<FilterOption<T>> options;

  /// Chosen value. Null means "all".
  final T? selected;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    // The menu uses numbers: 0 is "all", 1 is the first option, and so on.
    final selectedIndex =
        options.indexWhere((option) => option.value == selected) + 1;
    final labels = [allLabel, for (final option in options) option.label];
    final isFiltering = selectedIndex > 0;

    return PopupMenuButton<int>(
      tooltip: 'Filter by ${name.toLowerCase()}',
      position: PopupMenuPosition.under,
      onSelected: (index) {
        onSelected(index == 0 ? null : options[index - 1].value);
      },
      itemBuilder: (context) => [
        for (var i = 0; i < labels.length; i++)
          PopupMenuItem(
            value: i,
            child: Row(
              children: [
                // Hidden, not removed, so the labels line up.
                Opacity(
                  opacity: i == selectedIndex ? 1 : 0,
                  child: const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Text(labels[i]),
              ],
            ),
          ),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 14, right: 8),
        decoration: BoxDecoration(
          color: isFiltering ? AppColors.greenTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: isFiltering ? AppColors.darkGreen : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isFiltering ? labels[selectedIndex] : name,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }
}
