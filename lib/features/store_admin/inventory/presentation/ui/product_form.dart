import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/validators.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/inventory_item.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/models/product.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/ui/product_photos_field.dart';
import 'package:mae_assignment/features/store_admin/inventory/presentation/view_models/inventory_view_model.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/labeled_text_field.dart';

/// Form to add or edit a product.
/// - [item] is null: add (also asks for the starting stock)
/// - [item] is given: edit that product
class ProductForm extends ConsumerStatefulWidget {
  const ProductForm({
    required this.branchName,
    required this.onCancel,
    required this.onSaved,
    super.key,
    this.item,
  });

  final InventoryItem? item;

  /// Branch the price and stock are for.
  final String branchName;
  final VoidCallback onCancel;

  /// Called with the saved name after saving.
  final ValueChanged<String> onSaved;

  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _packSizeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _lowStockController;
  final _stockController = TextEditingController(text: '0');

  String? _categoryId;

  /// Photos in the form. Saved on Save.
  late List<ProductPhoto> _photos;
  bool _isSaving = false;

  bool get _isAdding => widget.item == null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final product = item?.product;
    _nameController = TextEditingController(text: product?.name);
    _brandController = TextEditingController(text: product?.brand);
    _packSizeController = TextEditingController(text: product?.packSize);
    _descriptionController = TextEditingController(text: product?.description);
    _priceController = TextEditingController(
      text: item?.price.toStringAsFixed(2),
    );
    _lowStockController = TextEditingController(
      text: '${product?.lowStockLevel ?? 10}',
    );
    _categoryId = product?.categoryId;
    _photos = [...?product?.photos];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _packSizeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _lowStockController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Picks photos and adds them to the form.
  Future<void> _onAddPhotos() async {
    final spaceLeft = Product.maxPhotos - _photos.length;
    final picked = await ref
        .read(inventoryViewModelProvider.notifier)
        .pickPhotos(spaceLeft);
    if (!mounted) return;

    if (picked == null) {
      _showMessage('Could not open your photos.');
      return;
    }
    setState(() {
      _photos = [
        ..._photos,
        for (final bytes in picked) ProductPhoto.picked(bytes),
      ];
    });
  }

  /// Creates a category and selects it.
  Future<void> _onNewCategory() async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _NewCategoryDialog(),
    );
    if (name == null || name.trim().isEmpty) return;

    final category = await ref
        .read(inventoryViewModelProvider.notifier)
        .addCategory(name);
    if (!mounted) return;

    if (category == null) {
      _showMessage('This category already exists.');
      return;
    }
    setState(() => _categoryId = category.id);
  }

  Future<void> _onSave() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _isSaving = true);
    final viewModel = ref.read(inventoryViewModelProvider.notifier);
    final item = widget.item;
    final price = double.parse(_priceController.text.trim());
    final lowStockLevel = int.parse(_lowStockController.text.trim());

    final String? error;
    if (item == null) {
      error = await viewModel.addProduct(
        name: _nameController.text,
        brand: _brandController.text,
        categoryId: _categoryId!,
        packSize: _packSizeController.text,
        description: _descriptionController.text,
        lowStockLevel: lowStockLevel,
        photos: _photos,
        price: price,
        stock: int.parse(_stockController.text.trim()),
      );
    } else {
      error = await viewModel.saveDetails(
        item,
        name: _nameController.text,
        brand: _brandController.text,
        categoryId: _categoryId!,
        packSize: _packSizeController.text,
        description: _descriptionController.text,
        lowStockLevel: lowStockLevel,
        photos: _photos,
        price: price,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      _showMessage(error);
      return;
    }
    widget.onSaved(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(inventoryViewModelProvider).value?.categories ??
        const <ProductCategory>[];

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LabeledTextField(
            label: 'Photos',
            field: ProductPhotosField(
              photos: _photos,
              onAdd: _onAddPhotos,
              onRemove: (index) {
                setState(() => _photos = [..._photos]..removeAt(index));
              },
            ),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Product name',
            hint: 'Fresh milk',
            controller: _nameController,
            validator: Validators.required('Please enter the product name'),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Brand',
            hint: 'Farm Fresh',
            controller: _brandController,
            validator: Validators.required('Please enter the brand'),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Pack size',
            hint: '1L, 500g, 10 pcs',
            controller: _packSizeController,
            validator: Validators.required('Please enter the pack size'),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Category',
            labelTrailing: TextButton(
              onPressed: _isSaving ? null : _onNewCategory,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('New category'),
            ),
            field: DropdownButtonFormField<String>(
              // The key refreshes the dropdown when the category changes.
              key: ValueKey(_categoryId),
              initialValue: _categoryId,
              // Stops long names from overflowing.
              isExpanded: true,
              hint: const Text('Choose a category'),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (id) => setState(() => _categoryId = id),
              validator: (id) {
                return id == null ? 'Please choose a category' : null;
              },
            ),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Description (optional)',
            field: TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'What customers read about the product',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AT ${widget.branchName.toUpperCase()}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'Price (RM)',
            hint: '7.90',
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: Validators.price,
          ),
          if (_isAdding) ...[
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'Starting stock',
              controller: _stockController,
              keyboardType: TextInputType.number,
              validator: Validators.wholeNumber,
            ),
            const SizedBox(height: 6),
            Text(
              'Other branches start with the same price and 0 stock.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Low stock level',
            controller: _lowStockController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: Validators.wholeNumber,
          ),
          const SizedBox(height: 6),
          Text(
            'Stock at or below this shows as "Low". Same for every branch.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _isSaving ? null : _onSave,
            child: _isSaving
                ? const ButtonLoadingIndicator()
                : Text(_isAdding ? 'Add product' : 'Save changes'),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _isSaving ? null : widget.onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

/// Asks for a category name and returns it.
class _NewCategoryDialog extends StatefulWidget {
  const _NewCategoryDialog();

  @override
  State<_NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<_NewCategoryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New category'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Category name'),
        onSubmitted: (name) => Navigator.of(context).pop(name),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
