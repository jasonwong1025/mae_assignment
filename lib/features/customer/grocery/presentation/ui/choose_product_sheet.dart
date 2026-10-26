import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_thumbnail.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_matcher.dart';

/// Lets the customer pick the product a list item means, from the store's
/// products. Starts with the best guesses for [query] and searches as they
/// type. Returns the chosen product, or null if closed.
Future<CatalogueProduct?> showChooseProductSheet(
  BuildContext context, {
  required String query,
  required List<CatalogueProduct> products,
  String? currentId,
}) {
  return showModalBottomSheet<CatalogueProduct>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    builder: (sheetContext) => _ChooseProductSheet(
      query: query,
      products: products,
      currentId: currentId,
    ),
  );
}

class _ChooseProductSheet extends StatefulWidget {
  const _ChooseProductSheet({
    required this.query,
    required this.products,
    required this.currentId,
  });

  final String query;
  final List<CatalogueProduct> products;
  final String? currentId;

  @override
  State<_ChooseProductSheet> createState() => _ChooseProductSheetState();
}

class _ChooseProductSheetState extends State<_ChooseProductSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<CatalogueProduct> get _results => [
    for (final match in GroceryMatcher.rank(
      _controller.text,
      widget.products,
      limit: 30,
    ))
      match.product,
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final results = _results;

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
              // Drag handle in the middle, close (X) in the top-right
              // corner, like the app's other sheets.
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s),
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
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              Text('Choose a product', style: textTheme.titleLarge),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search this store',
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Expanded(
                child: results.isEmpty
                    ? const Center(child: Text('No products match.'))
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = results[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: SizedBox(
                              width: 48,
                              child: ProductThumbnail(
                                imageUrl: product.coverImageUrl,
                              ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              product.isOutOfStock
                                  ? '${product.brand} · ${product.packSize} · '
                                        'Sold out'
                                  : '${product.brand} · ${product.packSize}',
                            ),
                            trailing: product.id == widget.currentId
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.green,
                                  )
                                : Text(Formatters.money(product.price)),
                            enabled: !product.isOutOfStock,
                            onTap: () => Navigator.of(context).pop(product),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
