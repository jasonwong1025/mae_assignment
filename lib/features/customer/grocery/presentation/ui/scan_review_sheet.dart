import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';

/// Shows what the scanner read from a written list so the customer can fix
/// it before anything is added: untick lines that are not items (a title, a
/// date), correct a misread word, change a quantity.
///
/// Returns the lines to add, or null if the sheet is closed.
Future<List<ParsedLine>?> showScanReviewSheet(
  BuildContext context, {
  required List<ParsedLine> lines,
}) {
  return showModalBottomSheet<List<ParsedLine>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => _ScanReviewSheet(lines: lines),
  );
}

class _Entry {
  _Entry(ParsedLine line)
    : controller = TextEditingController(text: line.name),
      quantity = line.quantity;

  final TextEditingController controller;
  int quantity;
  bool selected = true;
}

class _ScanReviewSheet extends StatefulWidget {
  const _ScanReviewSheet({required this.lines});

  final List<ParsedLine> lines;

  @override
  State<_ScanReviewSheet> createState() => _ScanReviewSheetState();
}

class _ScanReviewSheetState extends State<_ScanReviewSheet> {
  late final List<_Entry> _entries = [
    for (final line in widget.lines) _Entry(line),
  ];

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  List<ParsedLine> get _chosen => [
    for (final entry in _entries)
      if (entry.selected && entry.controller.text.trim().isNotEmpty)
        (name: entry.controller.text.trim(), quantity: entry.quantity),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = _chosen.length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            0,
            AppSpacing.l,
            AppSpacing.l,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Check your list', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Untick anything that is not an item, and fix any word that '
                'was misread.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.m),
              Expanded(
                child: ListView.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Row(
                      children: [
                        Checkbox(
                          value: entry.selected,
                          onChanged: (value) =>
                              setState(() => entry.selected = value ?? false),
                        ),
                        Expanded(
                          child: TextField(
                            controller: entry.controller,
                            enabled: entry.selected,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fewer',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: entry.selected && entry.quantity > 1
                              ? () => setState(() => entry.quantity--)
                              : null,
                        ),
                        Text('${entry.quantity}', style: textTheme.titleMedium),
                        IconButton(
                          tooltip: 'More',
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed:
                              entry.selected &&
                                  entry.quantity < GroceryTextParser.maxQuantity
                              ? () => setState(() => entry.quantity++)
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              FilledButton(
                key: const Key('scan_review_add_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                ),
                onPressed: count == 0
                    ? null
                    : () => Navigator.of(context).pop(_chosen),
                child: Text(
                  count == 1 ? 'Add 1 item to my list' : 'Add $count items',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
