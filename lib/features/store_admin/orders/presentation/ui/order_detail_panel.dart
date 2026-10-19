import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/view_models/orders_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Everything about one order: customer, delivery, items, payment and
/// what has happened so far. Read only; the admin monitors orders here
/// and does not change them.
///
/// It looks the order up by number every time the board updates, so the
/// details stay current while the panel is open.
class OrderDetailPanel extends ConsumerWidget {
  const OrderDetailPanel({
    required this.orderNumber,
    required this.onClose,
    super.key,
  });

  final int orderNumber;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final orders = ref.watch(ordersViewModelProvider).value ?? const <Order>[];
    final order = orders
        .where((order) => order.number == orderNumber)
        .firstOrNull;

    return Material(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #$orderNumber',
                    style: textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: order == null
                // For example after switching to another branch.
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'This order is no longer on the board.',
                      style: textTheme.bodyMedium,
                    ),
                  )
                : _OrderDetails(order: order),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  const _OrderDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            OrderStatusLabel(status: order.status),
            const SizedBox(width: 8),
            Text(
              'for '
              '${Formatters.minutes(order.minutesInStatus(DateTime.now()))}',
              style: textTheme.bodySmall,
            ),
          ],
        ),

        const _SectionTitle('Customer and delivery'),
        _InfoRow(icon: Icons.person_outline_rounded, text: order.customerName),
        _InfoRow(icon: Icons.phone_outlined, text: order.customerPhone),
        _InfoRow(
          icon: order.isDelivery
              ? Icons.local_shipping_outlined
              : Icons.storefront_outlined,
          text: order.isDelivery
              ? 'Deliver to ${order.address ?? 'address not given'}'
              : 'Pickup at the store',
        ),
        _InfoRow(
          icon: Icons.badge_outlined,
          text: order.handledBy == null
              ? 'No staff assigned yet'
              : 'Handled by ${order.handledBy}',
        ),
        if (order.customerNote != null)
          _InfoRow(
            icon: Icons.sticky_note_2_outlined,
            text: 'Note: ${order.customerNote}',
          ),

        const _SectionTitle('Items'),
        for (final item in order.items) _ItemRow(item: item),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        _AmountRow(label: 'Subtotal', amount: order.subtotal),
        _AmountRow(label: 'Delivery fee', amount: order.deliveryFee),
        _AmountRow(label: 'Total', amount: order.total, isBold: true),

        const _SectionTitle('Payment'),
        // Every order is paid from the wallet at checkout.
        const _InfoRow(
          icon: Icons.account_balance_wallet_outlined,
          text: 'Paid by Grocerly Wallet',
        ),

        const _SectionTitle('Timeline'),
        for (final event in order.timeline) _TimelineRow(event: event),
      ],
    );
  }
}

/// Small uppercase heading above each block of the panel.
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

/// An icon with a line of text beside it.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

/// "2 x Fresh milk 1L ... RM 15.80".
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text('${item.quantity} x', style: textTheme.bodyMedium),
          ),
          Expanded(child: Text(item.name, style: textTheme.bodyLarge)),
          const SizedBox(width: 12),
          Text(Formatters.money(item.lineTotal), style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// A label on the left and an amount of money on the right.
class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  final String label;
  final double amount;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = isBold ? textTheme.titleMedium : textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(Formatters.money(amount), style: style),
        ],
      ),
    );
  }
}

/// One step of the order's history: the time, what happened, and who.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event});

  final OrderEvent event;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              Formatters.time(event.time),
              style: textTheme.bodySmall,
            ),
          ),
          // Pushed down a little to sit beside the first line of text.
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 12),
            child: CircleAvatar(radius: 4, backgroundColor: AppColors.green),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: textTheme.bodyLarge),
                if (event.by != null)
                  Text('by ${event.by}', style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
