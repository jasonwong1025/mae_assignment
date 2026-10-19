import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/account/presentation/views/saved_addresses_view.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/selected_address_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/data/models/catalogue_product.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/branch_picker_sheet.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_card.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_thumbnail.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/catalogue_filter_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/catalogue_view_model.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Customer Home: the catalogue for the selected store. Deliver-to header,
/// search, category tabs, a promo banner, a "Going fast today" row, and a
/// grid of products to add to the cart.
class CatalogueView extends ConsumerWidget {
  const CatalogueView({super.key});

  void _addToCart(
    BuildContext context,
    WidgetRef ref,
    CatalogueProduct product,
  ) {
    ref.read(cartViewModelProvider.notifier).add(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogueViewModelProvider);

    return CustomerScaffold(
      currentTab: CustomerTab.home,
      child: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(catalogueViewModelProvider),
          ),
          data: (data) => _Catalogue(
            data: data,
            onAdd: (product) => _addToCart(context, ref, product),
            onOpen: (product) =>
                context.push(AppRoutes.customerProduct(product.id)),
          ),
        ),
      ),
    );
  }
}

class _Catalogue extends ConsumerWidget {
  const _Catalogue({
    required this.data,
    required this.onAdd,
    required this.onOpen,
  });

  final CatalogueState data;
  final void Function(CatalogueProduct product) onAdd;
  final void Function(CatalogueProduct product) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(catalogueFilterViewModelProvider);
    final goingFast = data.goingFast();
    final showExtras = filter.searchText.trim().isEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(branch: data.branch)),
        _CategoryTabs(
          categories: data.categories,
          selectedId: filter.categoryId,
        ),
        if (showExtras) ...[
          const SliverToBoxAdapter(child: _PromoBanner()),
          if (goingFast.isNotEmpty)
            SliverToBoxAdapter(
              child: _GoingFast(products: goingFast, onOpen: onOpen),
            ),
        ],
        if (data.products.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No products found',
              message: filter.categoryId == null && !showExtras
                  ? 'Try another search term, or another store.'
                  : filter.categoryId == null
                  ? 'This store has no products yet. Try another store.'
                  : 'Try another category, search term, or store.',
              action: OutlinedButton.icon(
                onPressed: () => showBranchPicker(context),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Change store'),
              ),
            ),
          )
        else
          _ProductGrid(products: data.products, onAdd: onAdd, onOpen: onOpen),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
      ],
    );
  }
}

/// The cart, opened as a page over Home. The badge counts the items in it.
class _CartButton extends ConsumerWidget {
  const _CartButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return IconButton.filledTonal(
      key: const Key('cart_button'),
      tooltip: count == 0 ? 'Cart' : 'Cart, $count items',
      style: IconButton.styleFrom(
        backgroundColor: AppColors.greenTint,
        foregroundColor: AppColors.darkGreen,
      ),
      onPressed: () => context.push(AppRoutes.customerCart),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}

/// Deliver-to address, cart button, search box, and the store line.
class _Header extends ConsumerWidget {
  const _Header({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final selected = await Navigator.of(context)
                        .push<CustomerAddress>(
                          MaterialPageRoute(
                            builder: (_) =>
                                const SavedAddressesView(selectable: true),
                          ),
                        );
                    if (selected != null) {
                      ref
                          .read(selectedAddressProvider.notifier)
                          .select(selected);
                    }
                    ref.invalidate(savedAddressesProvider);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVER TO',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Consumer(
                        builder: (context, ref, _) {
                          final address = ref
                              .watch(effectiveDeliveryAddressProvider)
                              .value;
                          return Row(
                            children: [
                              Flexible(
                                child: Text(
                                  address?.line ?? 'Choose a delivery address',
                                  style: textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              const _CartButton(),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          _SearchField(
            onChanged: (text) => ref
                .read(catalogueFilterViewModelProvider.notifier)
                .setSearchText(text),
          ),
          const SizedBox(height: AppSpacing.s),
          Semantics(
            button: true,
            label: 'Change store',
            child: InkWell(
              onTap: () => showBranchPicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 18,
                      color: AppColors.darkGreen,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        _storeLine(branch),
                        style: textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _storeLine(Branch branch) {
    final hours = branch.hoursOn(DateTime.now());
    if (branch.isTemporarilyClosed || hours.isClosed) {
      return '${branch.name} — closed';
    }
    final closes = Formatters.hour(hours.closesAt ~/ 60);
    return '${branch.name} — open, closes $closes';
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded),
        hintText: 'Search "chicken breast", "milk"...',
      ),
    );
  }
}

/// Horizontal, scrollable category tabs. The first chip is "All".
class _CategoryTabs extends ConsumerWidget {
  const _CategoryTabs({required this.categories, required this.selectedId});

  final List<CatalogueCategory> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void select(String? id) =>
        ref.read(catalogueFilterViewModelProvider.notifier).setCategory(id);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          children: [
            _CategoryChip(
              label: 'All',
              selected: selectedId == null,
              onTap: () => select(null),
            ),
            for (final category in categories)
              _CategoryChip(
                label: category.name,
                selected: category.id == selectedId,
                onTap: () => select(category.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s),
      child: Center(
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      ),
    );
  }
}

/// First-order promo banner from the wireframe.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, color: AppColors.orange),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                'RM5 off your first delivery — code FRESH5',
                style: textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Going fast today" — a horizontal row of low-stock products.
class _GoingFast extends StatelessWidget {
  const _GoingFast({required this.products, required this.onOpen});

  final List<CatalogueProduct> products;
  final void Function(CatalogueProduct product) onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.m,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Text(
            'GOING FAST TODAY',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        SizedBox(
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: products.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.m),
            itemBuilder: (context, index) {
              final product = products[index];
              final remaining = product.lowStockRemaining;
              return SizedBox(
                width: 120,
                child: InkWell(
                  onTap: () => onOpen(product),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fixed-size image, so a two-line name below never
                      // overflows the row.
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ProductThumbnail(
                          imageUrl: product.coverImageUrl,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          product.name,
                          style: textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (remaining != null)
                        Text(
                          'Only $remaining left',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The main product grid, two columns.
class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.onAdd,
    required this.onOpen,
  });

  final List<CatalogueProduct> products;
  final void Function(CatalogueProduct product) onAdd;
  final void Function(CatalogueProduct product) onOpen;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.s,
      ),
      sliver: SliverGrid(
        // A fixed cell height (not an aspect ratio) so the card has the same
        // vertical space on every phone width; an aspect ratio made narrow
        // phones too short and the card overflowed.
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: AppSpacing.m,
          crossAxisSpacing: AppSpacing.m,
          mainAxisExtent: 288,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return CustomerProductCard(
            product: product,
            onTap: () => onOpen(product),
            onAdd: product.isOutOfStock ? null : () => onAdd(product),
          );
        }, childCount: products.length),
      ),
    );
  }
}
