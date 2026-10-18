import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/account/presentation/views/saved_addresses_view.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/checkout_view_model.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/selected_address_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_thumbnail.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';
import 'package:mae_assignment/shared/repositories/order_repository.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Customer Cart tab (wireframe 2): the chosen items with quantity steppers,
/// a delivery-vs-pickup toggle, promo, the price breakdown, and Place order.
class CartView extends ConsumerStatefulWidget {
  const CartView({super.key});

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final order = await ref
          .read(checkoutViewModelProvider.notifier)
          .placeOrder(note: _noteController.text);
      if (order == null || !mounted) return;
      router.go(AppRoutes.customerOrder(order.id));
    } on OrderException catch (error) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartViewModelProvider);
    final isPlacing = ref.watch(checkoutViewModelProvider);

    return CustomerScaffold(
      currentTab: CustomerTab.cart,
      cartCount: cart.itemCount,
      child: cart.isEmpty
          ? const _EmptyCart()
          : _CartContent(
              cart: cart,
              noteController: _noteController,
              isPlacing: isPlacing,
              onPlaceOrder: _placeOrder,
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: EmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        message: 'Add items from the Home tab to get started.',
      ),
    );
  }
}

class _CartContent extends ConsumerWidget {
  const _CartContent({
    required this.cart,
    required this.noteController,
    required this.isPlacing,
    required this.onPlaceOrder,
  });

  final Cart cart;
  final TextEditingController noteController;
  final bool isPlacing;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isDelivery = cart.fulfilment == FulfilmentMethod.delivery;
    final quote = ref.watch(deliveryQuoteProvider).value;
    // The fee shown and charged: the distance quote once ready, otherwise
    // the flat fallback so the button has a sensible number.
    final fee = quote?.fee ?? cart.deliveryFee;
    final total = cart.totalWith(fee);

    return SafeArea(
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
                Text('Your cart', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  cart.itemCount == 1 ? '1 item' : '${cart.itemCount} items',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              children: [
                for (final line in cart.lines) ...[
                  _CartLineTile(line: line),
                  const Divider(height: 1),
                ],
                const SizedBox(height: AppSpacing.l),
                _FulfilmentPicker(selected: cart.fulfilment),
                if (isDelivery) ...[
                  const SizedBox(height: AppSpacing.l),
                  const _DeliveryAddressSection(),
                ],
                const SizedBox(height: AppSpacing.l),
                _NoteField(controller: noteController),
                const SizedBox(height: AppSpacing.l),
                _PromoRow(cart: cart),
                const SizedBox(height: AppSpacing.l),
                _Totals(cart: cart, deliveryFee: fee, quote: quote),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: FilledButton(
              onPressed: isPlacing ? null : onPlaceOrder,
              child: isPlacing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Place order — ${Formatters.money(total)}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Delivery address picker, shown only for delivery orders. Shows the chosen
/// (or default) saved address with a "Change" button, or a prompt to add one
/// when the customer has none.
class _DeliveryAddressSection extends ConsumerWidget {
  const _DeliveryAddressSection();

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final selected = await Navigator.of(context).push<CustomerAddress>(
      MaterialPageRoute(
        builder: (_) => const SavedAddressesView(selectable: true),
      ),
    );
    if (selected != null) {
      ref.read(selectedAddressProvider.notifier).select(selected);
    }
    // A new address may have been added/edited inside the chooser.
    ref.invalidate(savedAddressesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final addressAsync = ref.watch(effectiveDeliveryAddressProvider);
    final quote = ref.watch(deliveryQuoteProvider).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DELIVER TO',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        addressAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.m),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => _AddressPrompt(
            message: 'Could not load your addresses.',
            onTap: () => _choose(context, ref),
          ),
          data: (address) {
            if (address == null) {
              return _AddressPrompt(
                message: 'Add a delivery address',
                onTap: () => _choose(context, ref),
              );
            }
            final outOfRange = quote != null && !quote.inRange;
            return Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: outOfRange ? AppColors.error : AppColors.border,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.darkGreen,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.label, style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          address.line,
                          style: textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (outOfRange) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Outside this store’s delivery area.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _choose(context, ref),
                    child: const Text('Change'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AddressPrompt extends StatelessWidget {
  const _AddressPrompt({required this.message, required this.onTap});

  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_location_alt_outlined),
      label: Text(message),
    );
  }
}

/// Optional note for the store (e.g. substitution preferences).
class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTE FOR THE STORE (OPTIONAL)',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: controller,
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'e.g. leave at the door, no plastic bags',
            isDense: true,
          ),
        ),
      ],
    );
  }
}

/// One cart line: image, name/brand, price or a low-stock hint, and a
/// quantity stepper.
class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final product = line.product;
    final remaining = product.lowStockRemaining;
    final notifier = ref.read(cartViewModelProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A fixed 56x56 box gives ProductThumbnail (an AspectRatio) a height
          // in this top-aligned row, preventing the cart from collapsing when
          // a product has an image.
          SizedBox(
            width: 56,
            height: 56,
            child: ProductThumbnail(
              imageUrl: product.coverImageUrl,
              borderRadius: 10,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand.isEmpty
                      ? product.name
                      : '${product.name} — ${product.brand}',
                  style: textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (remaining != null)
                  Text(
                    'Only $remaining left',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Text(
                    Formatters.money(product.price),
                    style: textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          _QuantityStepper(
            quantity: line.quantity,
            canAdd: !line.atStockLimit,
            onRemove: () => notifier.removeOne(product),
            onAdd: () => notifier.add(product),
          ),
        ],
      ),
    );
  }
}

/// Minus / count / plus control for a cart line.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.canAdd,
    required this.onRemove,
    required this.onAdd,
  });

  final int quantity;
  final bool canAdd;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        _StepperButton(
          icon: Icons.remove_rounded,
          tooltip: 'Remove one',
          onPressed: onRemove,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
        ),
        _StepperButton(
          icon: Icons.add_rounded,
          tooltip: 'Add one',
          onPressed: canAdd ? onAdd : null,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: enabled ? AppColors.greenTint : AppColors.border,
        foregroundColor: enabled
            ? AppColors.darkGreen
            : AppColors.textSecondary,
      ),
      icon: Icon(icon, size: 18),
    );
  }
}

/// Delivery vs self-pickup, as two selectable cards.
class _FulfilmentPicker extends ConsumerWidget {
  const _FulfilmentPicker({required this.selected});

  final FulfilmentMethod selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(cartViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW DO YOU WANT IT?',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            Expanded(
              child: _FulfilmentCard(
                title: 'Delivery',
                subtitle: 'Today, 6:30–7:30pm',
                selected: selected == FulfilmentMethod.delivery,
                onTap: () => notifier.setFulfilment(FulfilmentMethod.delivery),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _FulfilmentCard(
                title: 'Self pickup',
                subtitle: 'Ready in ~25 min',
                selected: selected == FulfilmentMethod.pickup,
                onTap: () => notifier.setFulfilment(FulfilmentMethod.pickup),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FulfilmentCard extends StatelessWidget {
  const _FulfilmentCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenTint : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.darkGreen : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Promo code row: shows the applied discount or a field to enter a code.
class _PromoRow extends ConsumerStatefulWidget {
  const _PromoRow({required this.cart});

  final Cart cart;

  @override
  ConsumerState<_PromoRow> createState() => _PromoRowState();
}

class _PromoRowState extends ConsumerState<_PromoRow> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final applied = ref
        .read(cartViewModelProvider.notifier)
        .applyPromo(_controller.text);
    setState(() => _error = applied ? null : 'That code is not valid.');
    if (applied) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final applied = widget.cart.promoCode;

    if (applied != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text('$applied applied', style: textTheme.titleMedium),
            ),
            TextButton(
              onPressed: ref.read(cartViewModelProvider.notifier).removePromo,
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: const Key('cart_promo_field'),
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Promo code',
              errorText: _error,
              isDense: true,
            ),
            onSubmitted: (_) => _apply(),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        OutlinedButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }
}

/// Subtotal, delivery fee, discount and total.
class _Totals extends StatelessWidget {
  const _Totals({
    required this.cart,
    required this.deliveryFee,
    required this.quote,
  });

  final Cart cart;

  /// The fee being charged (distance quote if ready, else flat fallback).
  final double deliveryFee;

  /// The distance quote, for showing how far the delivery is. Null while it
  /// is still being worked out.
  final DeliveryQuote? quote;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDelivery = cart.fulfilment == FulfilmentMethod.delivery;
    final feeLabel = isDelivery && quote != null && quote!.inRange
        ? 'Delivery fee (${quote!.distanceKm.toStringAsFixed(1)} km)'
        : 'Delivery fee';

    return Column(
      children: [
        _TotalRow(label: 'Subtotal', amount: cart.subtotal),
        if (isDelivery) _TotalRow(label: feeLabel, amount: deliveryFee),
        if (cart.discount > 0)
          _TotalRow(label: 'Discount', amount: -cart.discount),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: textTheme.titleLarge),
            Text(
              Formatters.money(cart.totalWith(deliveryFee)),
              style: textTheme.titleLarge,
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDiscount = amount < 0;
    final text = isDiscount
        ? '−${Formatters.money(-amount)}'
        : Formatters.money(amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyLarge),
          Text(
            text,
            style: textTheme.bodyLarge?.copyWith(
              color: isDiscount ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}
