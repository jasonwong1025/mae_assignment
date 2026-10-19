import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_item_tile.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// What the packer chose in the replacement sheet.
class ReplacementChoice {
  const ReplacementChoice(this.replacement);

  /// The product to offer, or null to remove the item with no replacement.
  final OrderItem? replacement;
}

/// Asks the packer what to do about an unavailable [item]: offer one of the
/// [loadOptions] (products in stock at the branch), or remove the item.
/// Returns null if the sheet is closed without choosing.
Future<ReplacementChoice?> showReplacementSheet(
  BuildContext context, {
  required OrderItem item,
  required Future<List<OrderItem>> Function() loadOptions,
}) {
  return showModalBottomSheet<ReplacementChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return _ReplacementSheet(item: item, loadOptions: loadOptions);
    },
  );
}

class _ReplacementSheet extends StatefulWidget {
  const _ReplacementSheet({required this.item, required this.loadOptions});

  final OrderItem item;
  final Future<List<OrderItem>> Function() loadOptions;

  @override
  State<_ReplacementSheet> createState() => _ReplacementSheetState();
}

class _ReplacementSheetState extends State<_ReplacementSheet> {
  late Future<List<OrderItem>> _options = widget.loadOptions();
  String _search = '';

  void _retry() {
    setState(() => _options = widget.loadOptions());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;

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
              Text('${item.name} is unavailable', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Offer a replacement from this branch. The customer decides '
                'whether to accept it.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.m),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search products',
                ),
                onChanged: (value) =>
                    setState(() => _search = value.trim().toLowerCase()),
              ),
              const SizedBox(height: AppSpacing.s),
              Expanded(
                child: FutureBuilder<List<OrderItem>>(
                  future: _options,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      final error = snapshot.error;
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              error is AppException
                                  ? error.message
                                  : 'Could not load the products.',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _retry,
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final options = [
                      for (final option in snapshot.data!)
                        if (_search.isEmpty ||
                            option.name.toLowerCase().contains(_search) ||
                            option.brand.toLowerCase().contains(_search))
                          option,
                    ];
                    if (options.isEmpty) {
                      return const Center(
                        child: Text('No products in stock match.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.s),
                      itemBuilder: (context, index) => _OptionTile(
                        original: item,
                        option: options[index],
                        onTap: () => Navigator.of(
                          context,
                        ).pop(ReplacementChoice(options[index])),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pop(const ReplacementChoice(null)),
                icon: const Icon(Icons.remove_circle_outline_rounded),
                label: const Text('No replacement, remove item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One product that could be offered, with how its price compares.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.original,
    required this.option,
    required this.onTap,
  });

  final OrderItem original;
  final OrderItem option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final difference =
        (option.unitPrice - original.unitPrice) * option.quantity;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              ProductImage(imageUrl: option.imageUrl, size: 52),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.name, style: textTheme.titleMedium),
                    Text(
                      '${option.brand} · ${option.packSize}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.money(option.unitPrice),
                    style: textTheme.titleMedium,
                  ),
                  Text(_differenceText(difference), style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _differenceText(double difference) {
    if (difference.abs() < 0.005) return 'Same total';
    final amount = Formatters.money(difference.abs());
    return difference > 0 ? '+$amount' : '-$amount';
  }
}
