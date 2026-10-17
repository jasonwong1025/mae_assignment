import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_thumbnail.dart';
import 'package:mae_assignment/features/customer/shell/customer_routes.dart';
import 'package:mae_assignment/features/customer/shell/presentation/ui/customer_scaffold.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Customer Cart tab (wireframe 2): the chosen items with quantity steppers,
/// a delivery-vs-pickup toggle, promo, the price breakdown, and Place order.
class CartView extends ConsumerWidget {
  const CartView({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what is not connected yet.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartViewModelProvider);

    return CustomerScaffold(
      currentTab: CustomerTab.cart,
      cartCount: cart.itemCount,
      child: cart.isEmpty
          ? const _EmptyCart()
          : _CartContent(
              cart: cart,
              onPlaceOrder: () => _comingSoon(context, 'Checkout'),
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
  const _CartContent({required this.cart, required this.onPlaceOrder});

  final Cart cart;
  final VoidCallback onPlaceOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

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
                const SizedBox(height: AppSpacing.l),
                _PromoRow(cart: cart),
                const SizedBox(height: AppSpacing.l),
                _Totals(cart: cart),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: FilledButton(
              onPressed: onPlaceOrder,
              child: Text('Place order — ${Formatters.money(cart.total)}'),
            ),
          ),
        ],
      ),
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
          SizedBox(
            width: 56,
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
  const _Totals({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _TotalRow(label: 'Subtotal', amount: cart.subtotal),
        if (cart.fulfilment == FulfilmentMethod.delivery)
          _TotalRow(label: 'Delivery fee', amount: cart.deliveryFee),
        if (cart.discount > 0)
          _TotalRow(label: 'Discount', amount: -cart.discount),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: textTheme.titleLarge),
            Text(Formatters.money(cart.total), style: textTheme.titleLarge),
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
