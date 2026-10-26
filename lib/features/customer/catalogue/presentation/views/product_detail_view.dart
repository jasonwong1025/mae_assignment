import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_thumbnail.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/product_detail_view_model.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Product details: photos, name, price, stock at the selected branch,
/// description, and a quantity picker with an add-to-cart button. Pushed
/// over Home, so it has its own app bar with a back button.
class ProductDetailView extends ConsumerWidget {
  const ProductDetailView({required this.productId, super.key});

  final String productId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.customerCatalogue);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => _back(context),
        ),
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: 'Could not load this product. Please check your connection.',
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (product) {
          if (product == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Product not available',
              message: 'This product is not sold at your store right now.',
              action: OutlinedButton.icon(
                onPressed: () => _back(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
              ),
            );
          }
          return _ProductDetail(product: product);
        },
      ),
    );
  }
}

class _ProductDetail extends ConsumerStatefulWidget {
  const _ProductDetail({required this.product});

  final CatalogueProduct product;

  @override
  ConsumerState<_ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<_ProductDetail> {
  int _quantity = 1;

  CatalogueProduct get _product => widget.product;

  void _addToCart(int inCart) {
    ref
        .read(cartViewModelProvider.notifier)
        .setQuantity(_product, inCart + _quantity);
    final added = _quantity;
    setState(() => _quantity = 1);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$added × ${_product.name} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inCart = ref.watch(
      cartViewModelProvider.select((cart) => cart.quantityOf(_product.id)),
    );
    // How many more can still be added without passing the stock.
    final room = (_product.stock - inCart).clamp(0, _product.stock);
    final quantity = _quantity.clamp(1, room < 1 ? 1 : room);
    final remaining = _product.lowStockRemaining;

    final String buttonLabel;
    if (_product.isOutOfStock) {
      buttonLabel = 'Out of stock';
    } else if (room == 0) {
      buttonLabel = 'All available stock is in your cart';
    } else {
      buttonLabel =
          'Add to cart · ${Formatters.money(_product.price * quantity)}';
    }

    return Column(
      children: [
        Expanded(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                _ProductPhotos(imageUrls: _product.imageUrls),
                const SizedBox(height: AppSpacing.l),
                Text(_product.name, style: textTheme.headlineSmall),
                if (_product.brand.isNotEmpty || _product.packSize.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      [
                        _product.brand,
                        _product.packSize,
                      ].where((part) => part.isNotEmpty).join(' · '),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  Formatters.money(_product.price),
                  style: textTheme.headlineSmall?.copyWith(
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                _StockLabel(
                  isOutOfStock: _product.isOutOfStock,
                  remaining: remaining,
                  stock: _product.stock,
                ),
                if (inCart > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      'In your cart: $inCart',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                if (_product.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('About this product', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.s),
                  Text(_product.description, style: textTheme.bodyLarge),
                ],
              ],
            ),
          ),
        ),
        BottomActionBar(
          children: [
            if (room > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: _QuantityStepper(
                  quantity: quantity,
                  onDecrease: quantity > 1
                      ? () => setState(() => _quantity = quantity - 1)
                      : null,
                  onIncrease: quantity < room
                      ? () => setState(() => _quantity = quantity + 1)
                      : null,
                ),
              ),
            FilledButton.icon(
              onPressed: room > 0 ? () => _addToCart(inCart) : null,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ],
    );
  }
}

class _StockLabel extends StatelessWidget {
  const _StockLabel({
    required this.isOutOfStock,
    required this.remaining,
    required this.stock,
  });

  final bool isOutOfStock;
  final int? remaining;
  final int stock;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (isOutOfStock) {
      return Text(
        'Out of stock at this store',
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    if (remaining != null) {
      return Text(
        'Only $remaining left',
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return Text('In stock', style: textTheme.bodyMedium);
  }
}

/// Swipeable photos with dots. Shows the placeholder when there are none.
class _ProductPhotos extends StatefulWidget {
  const _ProductPhotos({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_ProductPhotos> createState() => _ProductPhotosState();
}

class _ProductPhotosState extends State<_ProductPhotos> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.length <= 1) {
      return ProductThumbnail(
        imageUrl: urls.isEmpty ? null : urls.first,
        aspectRatio: 4 / 3,
      );
    }
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: PageView.builder(
            itemCount: urls.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) =>
                ProductThumbnail(imageUrl: urls[index], aspectRatio: 4 / 3),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < urls.length; i++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? AppColors.darkGreen : AppColors.border,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: onDecrease,
          tooltip: 'Decrease quantity',
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 56,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton.outlined(
          onPressed: onIncrease,
          tooltip: 'Increase quantity',
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
