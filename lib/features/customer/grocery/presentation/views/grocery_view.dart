import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_row.dart';
import 'package:mae_assignment/features/customer/grocery/data/repositories/grocery_list_repository.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/ui/choose_product_sheet.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/ui/scan_review_sheet.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/view_models/grocery_list_view_model.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Customer Grocery tab: a list of things to buy, typed or scanned from a
/// written list. Each item is matched to a product at the customer's store,
/// and the matched ones can be added to the cart in one tap.
class GroceryView extends ConsumerStatefulWidget {
  const GroceryView({super.key});

  @override
  ConsumerState<GroceryView> createState() => _GroceryViewState();
}

class _GroceryViewState extends ConsumerState<GroceryView> {
  final _controller = TextEditingController();
  bool _isScanning = false;
  bool _isAdding = false;

  GroceryListViewModel get _viewModel =>
      ref.read(groceryListViewModelProvider.notifier);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _say(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  Future<void> _addTyped() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final error = await _viewModel.addText(text);
    if (error != null && mounted) _say(error);
  }

  Future<void> _scan() async {
    setState(() => _isScanning = true);
    try {
      final lines = await _viewModel.scan();
      if (!mounted) return;
      // The scanner is done; do not keep the spinner behind the review.
      setState(() => _isScanning = false);
      if (lines == null) return;
      if (lines.isEmpty) {
        _say(
          'No items could be read from that photo. Try again in better '
          'light, or type them instead.',
        );
        return;
      }
      final chosen = await showScanReviewSheet(context, lines: lines);
      if (chosen == null || chosen.isEmpty || !mounted) return;
      final error = await _viewModel.addAll(chosen);
      if (!mounted) return;
      _say(
        error ??
            (chosen.length == 1
                ? '1 item added to your list.'
                : '${chosen.length} items added to your list.'),
      );
    } on AppException catch (error) {
      if (mounted) _say(error.message);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _change(GroceryRow row) async {
    final products = ref.read(groceryCatalogueProvider).value;
    if (products == null) return;
    final chosen = await showChooseProductSheet(
      context,
      query: row.item.name,
      products: products,
      currentId: row.product?.id,
    );
    if (chosen == null || !mounted) return;
    final error = await _viewModel.chooseProduct(row.item.id, chosen.id);
    if (error != null && mounted) _say(error);
  }

  Future<void> _addToCart(List<GroceryRow> rows) async {
    setState(() => _isAdding = true);
    final result = await _viewModel.addMatchedToCart(rows);
    if (!mounted) return;
    setState(() => _isAdding = false);
    final added = result.added == 1
        ? '1 item added to your cart.'
        : '${result.added} items added to your cart.';
    final left = result.left == 0
        ? ''
        : result.left == 1
        ? ' 1 stayed on your list.'
        : ' ${result.left} stayed on your list.';
    final reduced = result.reduced == 0
        ? ''
        : ' ${result.reduced} had less stock than you asked for.';
    _say(
      '$added$left$reduced',
      action: SnackBarAction(
        label: 'View cart',
        onPressed: () => context.push(AppRoutes.customerCart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scanSupported = ref.watch(groceryListRepositoryProvider).canScan;
    final rowsState = ref.watch(groceryRowsProvider);
    final listState = ref.watch(groceryListViewModelProvider);
    final branch = ref.watch(selectedBranchProvider).value;

    return CustomerScaffold(
      currentTab: CustomerTab.grocery,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Grocery list', style: textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    branch == null
                        ? 'Write what you need, then add it to your cart.'
                        : 'Matched to what ${branch.name} has in stock.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('grocery_input'),
                          controller: _controller,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addTyped(),
                          decoration: const InputDecoration(
                            hintText: 'Add items, e.g. 2 fresh milk, eggs',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      IconButton.filled(
                        key: const Key('grocery_add_button'),
                        tooltip: 'Add to list',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                        ),
                        onPressed: _addTyped,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  if (scanSupported) ...[
                    const SizedBox(height: AppSpacing.s),
                    OutlinedButton.icon(
                      key: const Key('grocery_scan_button'),
                      onPressed: _isScanning ? null : _scan,
                      icon: _isScanning
                          ? const ButtonLoadingIndicator()
                          : const Icon(Icons.document_scanner_outlined),
                      label: const Text('Scan a written list'),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: listState.hasError
                  ? ErrorState(
                      message:
                          'Could not load your grocery list. Check your '
                          'connection.',
                      onRetry: () =>
                          ref.invalidate(groceryListViewModelProvider),
                    )
                  : rowsState.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => ErrorState(
                        message:
                            'Could not load the store to match your items.',
                        onRetry: () => ref.invalidate(groceryCatalogueProvider),
                      ),
                      data: (rows) => rows.isEmpty
                          ? EmptyState(
                              icon: Icons.checklist_rtl_rounded,
                              title: 'Your list is empty',
                              message: scanSupported
                                  ? 'Type what you need, or scan a written '
                                        'list. You review it before anything '
                                        'is added.'
                                  : 'Type what you need and add it to '
                                        'your list.',
                            )
                          : _RowsAndAction(
                              rows: rows,
                              isAdding: _isAdding,
                              onAddToCart: () => _addToCart(rows),
                              onChange: _change,
                              onSetQuantity: (row, quantity) =>
                                  _viewModel.setQuantity(row.item.id, quantity),
                              onRemove: (row) => _viewModel.remove(row.item.id),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowsAndAction extends StatelessWidget {
  const _RowsAndAction({
    required this.rows,
    required this.isAdding,
    required this.onAddToCart,
    required this.onChange,
    required this.onSetQuantity,
    required this.onRemove,
  });

  final List<GroceryRow> rows;
  final bool isAdding;
  final VoidCallback onAddToCart;
  final void Function(GroceryRow row) onChange;
  final void Function(GroceryRow row, int quantity) onSetQuantity;
  final void Function(GroceryRow row) onRemove;

  @override
  Widget build(BuildContext context) {
    final matched = rows.where((row) => row.isMatched).length;
    final unmatched = rows.length - matched;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: rows.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _GroceryRowTile(
              row: rows[index],
              onChange: () => onChange(rows[index]),
              onSetQuantity: (quantity) => onSetQuantity(rows[index], quantity),
              onRemove: () => onRemove(rows[index]),
            ),
          ),
        ),
        BottomActionBar(
          children: [
            if (unmatched > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Text(
                  unmatched == 1
                      ? '1 item has no match and will stay on your list.'
                      : '$unmatched items have no match and will stay on '
                            'your list.',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            FilledButton.icon(
              key: const Key('grocery_add_to_cart_button'),
              onPressed: matched == 0 || isAdding ? null : onAddToCart,
              icon: isAdding
                  ? const ButtonLoadingIndicator()
                  : const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                matched == 1
                    ? 'Add 1 item to cart'
                    : 'Add $matched items to cart',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GroceryRowTile extends StatelessWidget {
  const _GroceryRowTile({
    required this.row,
    required this.onChange,
    required this.onSetQuantity,
    required this.onRemove,
  });

  final GroceryRow row;
  final VoidCallback onChange;
  final ValueChanged<int> onSetQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = row.product;
    final (text, color) = switch ((product, row.soldOut)) {
      (final matched?, _) => (
        '${matched.name} · ${matched.brand} · ${matched.packSize} · '
            '${Formatters.money(matched.price)}',
        AppColors.darkGreen,
      ),
      (_, true) => ('Sold out at this store', AppColors.error),
      _ => ('No match at this store', AppColors.error),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onChange,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.item.name, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      text,
                      style: textTheme.bodySmall?.copyWith(color: color),
                    ),
                    Text(
                      product == null
                          ? 'Tap to choose a product'
                          : 'Tap to change',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    if (product != null &&
                        row.quantityToAdd < row.item.quantity)
                      Text(
                        'Only ${product.stock} in stock',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Fewer ${row.item.name}',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: row.item.quantity > 1
                ? () => onSetQuantity(row.item.quantity - 1)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('${row.item.quantity}', style: textTheme.titleMedium),
          ),
          IconButton(
            tooltip: 'More ${row.item.name}',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onSetQuantity(row.item.quantity + 1),
          ),
          IconButton(
            tooltip: 'Remove ${row.item.name}',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
