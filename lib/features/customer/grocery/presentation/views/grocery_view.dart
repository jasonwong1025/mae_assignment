import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/features/customer/grocery/data/grocery_text_parser.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_list.dart';
import 'package:mae_assignment/features/customer/grocery/data/models/grocery_row.dart';
import 'package:mae_assignment/features/customer/grocery/data/repositories/grocery_list_repository.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/ui/choose_product_sheet.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/ui/recipe_sheet.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/ui/scan_review_sheet.dart';
import 'package:mae_assignment/features/customer/grocery/presentation/view_models/grocery_list_view_model.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Customer Grocery tab: lists of things to buy, shown as tabs. Items are
/// typed, scanned from a written list or suggested from a recipe; a scan or
/// recipe can become its own list. Each item is matched to a product at the
/// customer's store, and the open list's matched items can be added to the
/// cart in one tap.
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
      await _saveChosen(
        chosen,
        suggestedName: 'Scanned ${Formatters.dayMonth(DateTime.now())}',
      );
    } on AppException catch (error) {
      if (mounted) _say(error.message);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _recipe() async {
    var dish = '';
    final lines = await showRecipeSheet(
      context,
      suggest: (name, servings) {
        dish = name;
        return _viewModel.suggestFromRecipe(name, servings);
      },
    );
    if (lines == null || !mounted) return;
    final chosen = await showScanReviewSheet(
      context,
      lines: lines,
      title: 'Suggested ingredients',
      hint:
          'An AI model suggested these and it can be wrong. Untick what you '
          'do not need, and change any amount.',
    );
    if (chosen == null || chosen.isEmpty || !mounted) return;
    await _saveChosen(chosen, suggestedName: _titleCase(dish));
  }

  /// Asks whether reviewed items become a new list or join the open one,
  /// then saves them there.
  Future<void> _saveChosen(
    List<ParsedLine> chosen, {
    required String suggestedName,
  }) async {
    final lists = ref.read(groceryListViewModelProvider).value;
    if (lists == null) return;
    final choice = await showDialog<_Destination>(
      context: context,
      builder: (_) => _DestinationDialog(
        suggestedName: suggestedName,
        currentName: lists.selected.name,
        canCreate: !lists.isFull,
      ),
    );
    if (choice == null || !mounted) return;
    final newName = choice.newListName;
    final error = newName == null
        ? await _viewModel.addAll(chosen)
        : await _viewModel.createList(newName, chosen);
    if (!mounted) return;
    final count = chosen.length == 1 ? '1 item' : '${chosen.length} items';
    _say(
      error ??
          (newName == null
              ? '$count added to ${lists.selected.name}.'
              : '$count saved to a new list, $newName.'),
    );
  }

  /// "nasi lemak" becomes "Nasi lemak".
  static String _titleCase(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Recipe';
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  Future<void> _newList() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const _NameDialog(title: 'New list', confirmLabel: 'Create'),
    );
    if (name == null || !mounted) return;
    final error = await _viewModel.createList(name, const []);
    if (error != null && mounted) _say(error);
  }

  /// Rename or delete a list (the default list can only be cleared).
  Future<void> _manage(GroceryList list) async {
    final action = await showModalBottomSheet<_ListAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename list'),
              onTap: () => Navigator.of(sheetContext).pop(_ListAction.rename),
            ),
            ListTile(
              leading: Icon(
                list.isDefault
                    ? Icons.clear_all_rounded
                    : Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              title: Text(
                list.isDefault ? 'Clear list' : 'Delete list',
                style: const TextStyle(color: AppColors.error),
              ),
              onTap: () => Navigator.of(sheetContext).pop(_ListAction.delete),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case _ListAction.rename:
        final name = await showDialog<String>(
          context: context,
          builder: (_) => _NameDialog(
            title: 'Rename list',
            confirmLabel: 'Save',
            initial: list.name,
          ),
        );
        if (name == null || !mounted) return;
        final error = await _viewModel.renameList(list.id, name);
        if (error != null && mounted) _say(error);
      case _ListAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(
              list.isDefault ? 'Clear ${list.name}?' : 'Delete ${list.name}?',
            ),
            content: Text(
              list.isDefault
                  ? 'Every item on this list will be removed.'
                  : 'This list and its items will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(list.isDefault ? 'Clear' : 'Delete'),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
        final error = await _viewModel.deleteList(list.id);
        if (error != null && mounted) _say(error);
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
    final lists = listState.value;
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
                  const SizedBox(height: AppSpacing.s),
                  // Side by side; the scan button only on phones that can
                  // scan.
                  Row(
                    children: [
                      if (scanSupported) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const Key('grocery_scan_button'),
                            onPressed: _isScanning ? null : _scan,
                            icon: _isScanning
                                ? const ButtonLoadingIndicator()
                                : const Icon(Icons.document_scanner_outlined),
                            label: const Text('Scan a list'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s),
                      ],
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('grocery_recipe_button'),
                          onPressed: _recipe,
                          icon: const Icon(Icons.auto_awesome_outlined),
                          label: const Text('From a recipe'),
                        ),
                      ),
                    ],
                  ),
                  if (lists != null) ...[
                    const SizedBox(height: AppSpacing.m),
                    _ListTabs(
                      lists: lists,
                      onSelect: _viewModel.select,
                      onManage: _manage,
                      onNew: _newList,
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
                              title:
                                  '${lists?.selected.name ?? 'Your list'} '
                                  'is empty',
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

enum _ListAction { rename, delete }

/// Where reviewed items go: a new list called [newListName], or the open
/// list when it is null.
class _Destination {
  const _Destination(this.newListName);

  final String? newListName;
}

/// One chip per list, then "New list". Tap to open a list; long-press to
/// rename or delete it.
class _ListTabs extends StatelessWidget {
  const _ListTabs({
    required this.lists,
    required this.onSelect,
    required this.onManage,
    required this.onNew,
  });

  final GroceryLists lists;
  final ValueChanged<String> onSelect;
  final ValueChanged<GroceryList> onManage;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final list in lists.lists) ...[
            GestureDetector(
              onLongPress: () => onManage(list),
              child: ChoiceChip(
                key: ValueKey('grocery_tab_${list.id}'),
                label: Text('${list.name} (${list.items.length})'),
                selected: list.id == lists.selectedId,
                showCheckmark: false,
                onSelected: (_) => list.id == lists.selectedId
                    ? onManage(list)
                    : onSelect(list.id),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
          ],
          ActionChip(
            key: const Key('grocery_new_list'),
            avatar: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New list'),
            onPressed: lists.isFull ? null : onNew,
          ),
        ],
      ),
    );
  }
}

/// Asks for a list name.
class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.confirmLabel,
    this.initial = '',
  });

  final String title;
  final String confirmLabel;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: GroceryList.maxNameLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'e.g. Weekly groceries'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// After a scan or recipe review: save the items as a new list (named after
/// the dish or the scan date, editable) or add them to the open list.
class _DestinationDialog extends StatefulWidget {
  const _DestinationDialog({
    required this.suggestedName,
    required this.currentName,
    required this.canCreate,
  });

  final String suggestedName;
  final String currentName;
  final bool canCreate;

  @override
  State<_DestinationDialog> createState() => _DestinationDialogState();
}

class _DestinationDialogState extends State<_DestinationDialog> {
  late final _controller = TextEditingController(
    text: widget.suggestedName.length > GroceryList.maxNameLength
        ? widget.suggestedName.substring(0, GroceryList.maxNameLength)
        : widget.suggestedName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save these items'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.canCreate)
            TextField(
              controller: _controller,
              maxLength: GroceryList.maxNameLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'New list name'),
            )
          else
            Text(
              'You already have ${GroceryList.maxLists} lists, so these '
              'items can only be added to ${widget.currentName}.',
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(const _Destination(null)),
          child: Text('Add to ${widget.currentName}'),
        ),
        if (widget.canCreate)
          FilledButton(
            onPressed: () {
              final name = _controller.text.trim();
              Navigator.of(
                context,
              ).pop(_Destination(name.isEmpty ? widget.suggestedName : name));
            },
            child: const Text('Save as new list'),
          ),
      ],
    );
  }
}
