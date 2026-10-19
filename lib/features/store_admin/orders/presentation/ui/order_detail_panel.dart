import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/view_models/orders_view_model.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/confirm_sheet.dart';
import 'package:mae_assignment/shared/ui/delivery_eta_card.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Everything about one order: customer, delivery, items, payment and
/// what has happened so far. The admin monitors orders here; the one thing
/// changed from here is who packs a pending or packing order.
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

class _OrderDetails extends ConsumerWidget {
  const _OrderDetails({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            OrderStatusLabel(status: order.status),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'for '
                '${Formatters.minutes(order.minutesInStatus(DateTime.now()))}',
                style: textTheme.bodySmall,
              ),
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
        if (_canAssignPacker(order)) _PackerRow(order: order),
        if (order.customerNote != null)
          _InfoRow(
            icon: Icons.sticky_note_2_outlined,
            text: 'Note: ${order.customerNote}',
          ),

        if (DeliveryEtaCard.isShownFor(order)) ...[
          const _SectionTitle('Delivery'),
          DeliveryEtaCard(order: order),
        ],

        if (order.hasOpenShortage) ...[
          const _SectionTitle('Awaiting customer'),
          _AwaitingCustomer(order: order),
        ],

        const _SectionTitle('Items'),
        for (final item in order.items) ..._itemRows(order, item),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(),
        ),
        _AmountRow(label: 'Subtotal', amount: order.subtotal),
        _AmountRow(label: 'Delivery fee', amount: order.deliveryFee),
        _AmountRow(
          label: order.shortages.isEmpty ? 'Total' : 'Paid at checkout',
          amount: order.total,
          isBold: order.shortages.isEmpty,
        ),
        if (order.shortages.isNotEmpty) ...[
          _AmountRow(
            label: order.adjustment <= 0
                ? 'Refund for unavailable items'
                : 'Extra for replacements',
            amount: order.adjustment.abs(),
          ),
          _AmountRow(
            label: 'Adjusted total',
            amount: order.adjustedTotal,
            isBold: true,
          ),
        ],

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

/// The rows for one ordered line. A line with a shortage is struck through,
/// followed by its replacement if the customer accepted one.
List<Widget> _itemRows(Order order, OrderItem item) {
  final shortage = order.shortageOf(item.lineId);
  final replacement = shortage?.status == ShortageStatus.accepted
      ? shortage?.replacement
      : null;
  final note = switch (shortage?.status) {
    ShortageStatus.proposed => 'Unavailable, waiting for the customer',
    ShortageStatus.accepted => 'Unavailable, replaced',
    ShortageStatus.removed => 'Unavailable, removed',
    null => null,
  };
  return [
    _ItemRow(
      item: item,
      struck: shortage != null && shortage.status != ShortageStatus.proposed,
      note: note,
    ),
    if (replacement != null) _ItemRow(item: replacement, note: 'Replacement'),
    if (shortage?.status == ShortageStatus.proposed &&
        shortage?.replacement != null)
      _ItemRow(
        item: shortage!.replacement!,
        note: 'Offered, not yet accepted',
        muted: true,
      ),
  ];
}

/// Tells the admin the order is stuck on the customer, with a way out.
class _AwaitingCustomer extends ConsumerWidget {
  const _AwaitingCustomer({required this.order});

  final Order order;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.cancel_outlined,
      title: 'Cancel order #${order.number}?',
      message:
          'The customer has not replied about an unavailable item. '
          'Cancelling cannot be undone.',
      confirmLabel: 'Cancel order',
      cancelLabel: 'Keep order',
    );
    if (!confirmed || !context.mounted) return;
    final error = await ref
        .read(ordersViewModelProvider.notifier)
        .cancelOrder(order);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(error ?? 'Order #${order.number} cancelled.')),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = order.openShortageCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.hourglass_top_rounded,
          text:
              'Packing is paused until the customer replies about '
              '${count == 1 ? '1 item' : '$count items'}.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('cancel_waiting_order_button'),
            onPressed: () => _cancel(context, ref),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel order'),
          ),
        ),
      ],
    );
  }
}

/// Packers can be assigned until the order is packed.
bool _canAssignPacker(Order order) {
  return order.status == OrderStatus.pending ||
      order.status == OrderStatus.packing;
}

/// The packer of the order, with a button to choose or change them.
class _PackerRow extends ConsumerWidget {
  const _PackerRow({required this.order});

  final Order order;

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final packers = await ref.read(packersProvider(order.branchId).future);
    if (!context.mounted) return;
    final chosen = await showModalBottomSheet<Worker>(
      context: context,
      showDragHandle: true,
      builder: (context) => _PackerList(packers: packers, order: order),
    );
    if (chosen == null || !context.mounted) return;

    final error = await ref
        .read(ordersViewModelProvider.notifier)
        .assignPacker(order, chosen);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? '${chosen.name} will pack #${order.number}.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packerName = order.packerName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              packerName == null ? 'No packer assigned' : 'Packer: $packerName',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          TextButton(
            onPressed: () => _choose(context, ref),
            child: Text(packerName == null ? 'Assign packer' : 'Change'),
          ),
        ],
      ),
    );
  }
}

/// The branch's active packers; picking one closes the sheet with them.
class _PackerList extends StatelessWidget {
  const _PackerList({required this.packers, required this.order});

  final List<Worker> packers;
  final Order order;

  @override
  Widget build(BuildContext context) {
    if (packers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Text(
          'No active packers at ${order.branchName}. Add one in the Staff '
          'tab.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final packer in packers)
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: Text(packer.name),
              subtitle: Text(packer.phone),
              trailing: packer.id == order.packerId
                  ? const Icon(Icons.check_rounded, color: AppColors.green)
                  : null,
              onTap: () => Navigator.of(context).pop(packer),
            ),
        ],
      ),
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
  const _ItemRow({
    required this.item,
    this.struck = false,
    this.note,
    this.muted = false,
  });

  final OrderItem item;

  /// Crossed out: the line is unavailable.
  final bool struck;
  final String? note;

  /// Lighter, for an offer that is not part of the order yet.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = struck || muted ? AppColors.textSecondary : null;
    final decoration = struck ? TextDecoration.lineThrough : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${item.quantity} x',
              style: textTheme.bodyMedium?.copyWith(
                color: color,
                decoration: decoration,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.bodyLarge?.copyWith(
                    color: color,
                    decoration: decoration,
                  ),
                ),
                if (note != null) Text(note!, style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Formatters.money(item.lineTotal),
            style: textTheme.bodyMedium?.copyWith(
              color: color,
              decoration: decoration,
            ),
          ),
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
