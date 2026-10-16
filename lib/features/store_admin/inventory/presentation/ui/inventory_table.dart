import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/product_labels.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/view_models/inventory_view_model.dart';

/// Product table for tablet and web. Scrolls sideways if too narrow.
class InventoryTable extends StatelessWidget {
  const InventoryTable({
    required this.items,
    required this.inventory,
    required this.selectedProductId,
    required this.onItemTap,
    super.key,
  });

  /// Narrowest the table can be.
  static const double _minWidth = 760;

  final List<InventoryItem> items;

  /// Used to show category names.
  final InventoryState inventory;

  /// Product open in the side panel.
  final String? selectedProductId;
  final ValueChanged<InventoryItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(_minWidth, constraints.maxWidth),
            height: constraints.maxHeight,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _RowLayout(
                      product: Text('PRODUCT', style: headingStyle),
                      category: Text('CATEGORY', style: headingStyle),
                      price: Text('PRICE', style: headingStyle),
                      stock: Text('STOCK', style: headingStyle),
                      status: Text('STATUS', style: headingStyle),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _ProductRow(
                          item: item,
                          categoryName: inventory.categoryName(
                            item.product.categoryId,
                          ),
                          isSelected: item.product.id == selectedProductId,
                          onTap: () => onItemTap(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One widget per column. Used by the heading and every row so the
/// columns line up.
class _RowLayout extends StatelessWidget {
  const _RowLayout({
    required this.product,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
  });

  final Widget product;
  final Widget category;
  final Widget price;
  final Widget stock;
  final Widget status;

  /// Adds a gap after a cell.
  Widget _spaced(Widget cell) {
    return Padding(padding: const EdgeInsets.only(right: 12), child: cell);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(flex: 6, child: _spaced(product)),
          Expanded(flex: 4, child: _spaced(category)),
          SizedBox(width: 100, child: price),
          SizedBox(width: 72, child: stock),
          SizedBox(
            width: 116,
            child: Align(alignment: Alignment.centerLeft, child: status),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.item,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  final InventoryItem item;
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = item.product;

    return Material(
      color: isSelected ? AppColors.greenTint : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          // Fade hidden products.
          child: Opacity(
            opacity: item.isHidden ? 0.55 : 1,
            child: _RowLayout(
              product: Row(
                children: [
                  ProductThumbnail(
                    categoryId: product.categoryId,
                    photo: product.cover,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: textTheme.titleMedium?.copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${product.brand} · ${product.packSize}',
                          style: textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              category: Text(
                categoryName,
                style: textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              price: Text(
                Formatters.money(item.price),
                style: textTheme.bodyMedium,
              ),
              stock: Text('${item.stock}', style: textTheme.bodyMedium),
              status: item.isHidden
                  ? const HiddenChip()
                  : StockStatusChip(status: item.stockStatus),
            ),
          ),
        ),
      ),
    );
  }
}
