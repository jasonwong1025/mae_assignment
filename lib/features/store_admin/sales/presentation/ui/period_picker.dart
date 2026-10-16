import 'package:flutter/material.dart';

import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/sales/data/models/sales_period.dart';

/// Chips for Today / Last 7 days / Last 30 days, and "Custom" which opens
/// a date range picker.
class PeriodPicker extends StatelessWidget {
  const PeriodPicker({
    required this.period,
    required this.onPresetSelected,
    required this.onCustomSelected,
    super.key,
  });

  final SalesPeriod period;
  final ValueChanged<SalesPreset> onPresetSelected;

  /// Called with the first and last day picked.
  final void Function(DateTime first, DateTime last) onCustomSelected;

  /// "1 Sep - 30 Sep 2026", shown on the Custom chip once picked.
  String get _customLabel {
    final last = DateTime(
      period.end.year,
      period.end.month,
      period.end.day - 1,
    );
    if (period.days == 1) return Formatters.date(last);
    return '${Formatters.dayMonth(period.start)} - ${Formatters.date(last)}';
  }

  Future<void> _pickCustom(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today,
      helpText: 'Pick up to 1 year',
    );
    if (picked == null || !context.mounted) return;

    final days = picked.end.difference(picked.start).inDays + 1;
    if (days > SalesPeriod.maxDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick 1 year or less.')),
      );
      return;
    }
    onCustomSelected(picked.start, picked.end);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = period.preset == null;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final preset in SalesPreset.values)
          ChoiceChip(
            label: Text(preset.label),
            selected: period.preset == preset,
            showCheckmark: false,
            onSelected: (_) => onPresetSelected(preset),
          ),
        ChoiceChip(
          avatar: const Icon(Icons.date_range_rounded, size: 18),
          label: Text(isCustom ? _customLabel : 'Custom'),
          selected: isCustom,
          showCheckmark: false,
          onSelected: (_) => _pickCustom(context),
        ),
      ],
    );
  }
}
