import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/product_form.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/product_labels.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/product_photo_carousel.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/stock_editor.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/view_models/inventory_view_model.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/ui/side_panel_frame.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';

/// Details of one product at the selected branch.
/// Edit shows the form in the same panel.
class ProductDetailPanel extends ConsumerStatefulWidget {
  const ProductDetailPanel({
    required this.productId,
    required this.onClose,
    super.key,
  });

  final String productId;
  final VoidCallback onClose;

  @override
  ConsumerState<ProductDetailPanel> createState() => _ProductDetailPanelState();
}

class _ProductDetailPanelState extends ConsumerState<ProductDetailPanel> {
  bool _isEditing = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _onToggleHidden(InventoryItem item) async {
    final error = await ref
        .read(inventoryViewModelProvider.notifier)
        .setHidden(item, hidden: !item.isHidden);
    if (!mounted) return;
    _showMessage(
      error ??
          (item.isHidden
              ? '${item.product.name} is visible again.'
              : '${item.product.name} is now hidden.'),
    );
  }

  Future<void> _onSaveStock(InventoryItem item, int stock) async {
    final error = await ref
        .read(inventoryViewModelProvider.notifier)
        .setStock(item, stock);
    if (!mounted) return;
    _showMessage(error ?? 'Stock updated to $stock.');
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryViewModelProvider).value;
    final item = inventory?.page.items
        .where((item) => item.product.id == widget.productId)
        .firstOrNull;
    final branchName =
        ref.watch(branchViewModelProvider).value?.selected.name ?? '';

    if (inventory == null || item == null) {
      return SidePanelFrame(
        title: 'Product',
        onClose: widget.onClose,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'This product is not in the list any more.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (_isEditing) {
      return SidePanelFrame(
        title: 'Edit product',
        onClose: widget.onClose,
        child: ProductForm(
          item: item,
          branchName: branchName,
          onCancel: () => setState(() => _isEditing = false),
          onSaved: (name) {
            setState(() => _isEditing = false);
            _showMessage('$name was saved.');
          },
        ),
      );
    }

    return SidePanelFrame(
      title: item.product.name,
      onClose: widget.onClose,
      child: _ProductDetails(
        item: item,
        categoryName: inventory.categoryName(item.product.categoryId),
        branchName: branchName,
        onEdit: () => setState(() => _isEditing = true),
        onToggleHidden: () => _onToggleHidden(item),
        onSaveStock: (stock) => _onSaveStock(item, stock),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({
    required this.item,
    required this.categoryName,
    required this.branchName,
    required this.onEdit,
    required this.onToggleHidden,
    required this.onSaveStock,
  });

  final InventoryItem item;
  final String categoryName;
  final String branchName;
  final VoidCallback onEdit;
  final VoidCallback onToggleHidden;
  final ValueChanged<int> onSaveStock;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = item.product;
    // Smaller than the theme's buttons so two fit in a row.
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 44),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ProductPhotoCarousel(
          photos: product.photos,
          categoryId: product.categoryId,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.brand} · ${product.packSize}',
                    style: textTheme.titleMedium,
                  ),
                  Text(categoryName, style: textTheme.bodyMedium),
                ],
              ),
            ),
            StockStatusChip(status: item.stockStatus),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: buttonStyle,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: buttonStyle,
                onPressed: onToggleHidden,
                icon: Icon(
                  item.isHidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                label: Text(item.isHidden ? 'Unhide' : 'Hide'),
              ),
            ),
          ],
        ),
        if (item.isHidden) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hidden from customers at $branchName.',
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],

        const _SectionTitle('Description'),
        Text(
          product.description.isEmpty ? 'No description.' : product.description,
          style: textTheme.bodyMedium,
        ),

        _SectionTitle('Price at $branchName'),
        Text(Formatters.money(item.price), style: textTheme.titleLarge),

        _SectionTitle('Stock at $branchName'),
        // The key resets the editor after stock is saved.
        StockEditor(
          key: ValueKey('${product.id}-${item.stock}'),
          stock: item.stock,
          onSave: onSaveStock,
        ),
        const SizedBox(height: 8),
        Text(
          'Shows as "Low" at ${product.lowStockLevel} or below.',
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Small uppercase section heading.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
