import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/qr_scanner_page.dart';
import 'package:mae_assignment/features/store_worker/orders/data/order_due_time.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/bag_label_screen.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/product_details_sheet.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/ui/pickup_order_card.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/view_models/pickup_handover_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_notice.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Handover screen for one self-pickup order: who it is for, what is in
/// the bag (read-only), the manual check, and Complete pickup.
/// Any packer at the branch can hand the order over, not only the one who
/// packed it. Orders that can no longer be handed over are read-only.
class PickupHandoverView extends ConsumerStatefulWidget {
  const PickupHandoverView({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<PickupHandoverView> createState() => _PickupHandoverViewState();
}

class _PickupHandoverViewState extends ConsumerState<PickupHandoverView> {
  /// True once this packer handed the order over. The order then leaves
  /// this packer's scope, so [_lastOrder] keeps the screen (and the tick
  /// on the slider) showing until it closes, instead of "not available".
  bool _isLeaving = false;

  /// The last version of the order shown, for while the screen closes.
  Order? _lastOrder;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.workerPickup);
    }
  }

  /// The customer shows a QR code on their phone; the packer scans it. A
  /// code that belongs to this order hands it over straight away; any other
  /// code is explained and nothing changes. This is the only way to hand
  /// over a pickup order, so the right customer always collects it.
  Future<void> _scanCustomerQr() async {
    final order = _lastOrder;
    if (order == null) return;
    final code = await ref.read(qrScannerProvider)(
      context,
      title: 'Scan customer QR',
      hint: "Point the camera at the QR code on the customer's phone.",
    );
    if (code == null || !mounted) return;
    final error = await ref
        .read(pickupHandoverViewModelProvider(widget.orderId).notifier)
        .completePickup(method: VerificationMethod.qr, code: code);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _isLeaving = true);
    _afterHandover(order);
  }

  /// After the handover: back to Ready for Pickup with a success message.
  void _afterHandover(Order order) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Order #${order.number} handed over to ${order.customerName}.',
          ),
        ),
      );
    _goBack();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(
      pickupHandoverViewModelProvider(widget.orderId),
    );
    final worker = ref.watch(workerSessionProvider);
    final order = orderState.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        title: Text(
          order == null
              ? 'Pickup'
              : '${order.isDelivery ? 'Delivery' : 'Pickup'} #${order.number}',
        ),
        // Reprint the bag label while the order waits to be collected.
        actions: [
          if (order != null && order.status == OrderStatus.ready)
            IconButton(
              tooltip: 'Print label',
              icon: const Icon(Icons.print_outlined),
              onPressed: () => showBagLabelScreen(context, order),
            ),
          const SizedBox(width: 4),
        ],
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: orderState.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => ErrorState(
                message: 'This order could not be loaded.',
                onRetry: () => ref.invalidate(
                  pickupHandoverViewModelProvider(widget.orderId),
                ),
              ),
              data: (current) {
                // While closing, keep showing the order as it was.
                final order = _isLeaving && _lastOrder != null
                    ? _lastOrder
                    : current;
                if (order != null && !_isLeaving) _lastOrder = order;
                // Delivery orders open read-only (waiting for their driver).
                if (order == null || worker == null) {
                  return EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Order not available',
                    message:
                        'This order is no longer waiting at the store. It may '
                        'have been handed over or collected.',
                    action: OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.workerPickup),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back to Ready for Pickup'),
                    ),
                  );
                }
                return _HandoverContent(
                  order: order,
                  workerId: worker.id,
                  onScanQr: _scanCustomerQr,
                  onBack: () => context.go(AppRoutes.workerPickup),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HandoverContent extends StatelessWidget {
  const _HandoverContent({
    required this.order,
    required this.workerId,
    required this.onScanQr,
    required this.onBack,
  });

  final Order order;
  final String workerId;

  /// Scans the customer's QR code, which hands the order over.
  final VoidCallback onScanQr;
  final VoidCallback onBack;

  /// Only ready self-pickup orders. Delivery bags are collected by their
  /// driver, so they are shown read-only.
  bool get _canHandOver => order.status == OrderStatus.ready && order.isPickup;

  /// A delivery bag still waiting for its driver: nothing to explain, the
  /// header already shows the driver and delivery time.
  bool get _isWaitingForDriver =>
      order.isDelivery &&
      order.status == OrderStatus.ready &&
      order.collectionVerifiedBy != order.driverId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              _CustomerHeader(order: order, workerId: workerId),
              // Why it can no longer be handed over (handed over,
              // cancelled, still being packed).
              if (!_canHandOver && !_isWaitingForDriver) ...[
                const SizedBox(height: AppSpacing.l),
                _StatusNotice(order: order, workerId: workerId),
              ],
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  bottom: AppSpacing.s,
                ),
                child: Text(
                  'In the bag (${order.itemCount} '
                  '${order.itemCount == 1 ? 'item' : 'items'})',
                  style: textTheme.titleMedium,
                ),
              ),
              // A plain read-only list: everything is already packed.
              // Tapping a product shows its details.
              Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    for (final (index, item)
                        in order.effectiveItems.indexed) ...[
                      if (index > 0) const Divider(height: 1),
                      _ItemRow(
                        item: item,
                        onTap: () => showProductDetailsSheet(
                          context,
                          item: item,
                          isPacked: order.isPacked(item.lineId),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_canHandOver)
          BottomActionBar(
            children: [
              FilledButton.icon(
                onPressed: onScanQr,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan customer QR code'),
              ),
            ],
          )
        else
          BottomActionBar(
            children: [
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Ready for Pickup'),
              ),
            ],
          ),
      ],
    );
  }
}

/// Large order number and customer name: what gets matched at the counter.
class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({required this.order, required this.workerId});

  final Order order;
  final String workerId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isReady = order.status == OrderStatus.ready;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap, so the badge moves under the number on narrow screens or
        // with large text instead of overflowing.
        Wrap(
          spacing: AppSpacing.m,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('#${order.number}', style: textTheme.headlineMedium),
            OrderStatusBadge(
              status: order.status,
              label: isReady
                  ? (order.isDelivery ? 'Ready for driver' : 'Ready for pickup')
                  : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(order.customerName, style: textTheme.titleLarge),
        // The customer's phone is only for pickups; drivers contact
        // delivery customers themselves.
        if (order.isPickup) ...[
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s),
              Flexible(
                child: Text(order.customerPhone, style: textTheme.bodyLarge),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        _IconLine(
          icon: Icons.person_outline_rounded,
          text: packedByText(order, workerId),
        ),
        if (order.isDelivery) ...[
          const SizedBox(height: AppSpacing.xs),
          _IconLine(
            icon: Icons.local_shipping_outlined,
            text: 'Driver: ${order.driverName ?? 'not assigned'}',
          ),
        ],
        if (isReady && order.promisedAt != null) ...[
          const SizedBox(height: AppSpacing.xs),
          _IconLine(
            icon: Icons.schedule_rounded,
            text:
                '${order.isDelivery ? 'Deliver by' : 'Pickup by'} '
                '${Formatters.time(order.promisedAt!)}',
            color: _dueColor(order.promisedAt!),
            bold: true,
          ),
        ],
      ],
    );
  }
}

/// Grey normally, amber within 15 minutes, red once late, like the due
/// times on the other worker screens.
Color _dueColor(DateTime dueAt) {
  final minutesLeft = dueAt.difference(DateTime.now()).inMinutes;
  if (minutesLeft < 0) return AppColors.error;
  if (minutesLeft <= 15) return AppColors.warning;
  return AppColors.textSecondary;
}

/// Small icon and one line of text, e.g. a clock and "Pickup by 4:03am".
class _IconLine extends StatelessWidget {
  const _IconLine({
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
    this.bold = false,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Why the order can no longer be handed over.
class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.order, required this.workerId});

  final Order order;
  final String workerId;

  @override
  Widget build(BuildContext context) {
    if (order.isDelivery) return _deliveryNotice();
    final (icon, color, text) = switch (order.status) {
      OrderStatus.completed => (
        Icons.task_alt_rounded,
        AppColors.success,
        _handedOverText(),
      ),
      OrderStatus.cancelled => (
        Icons.block_rounded,
        AppColors.error,
        'This order was cancelled. Do not hand it over.',
      ),
      _ => (
        Icons.hourglass_top_rounded,
        AppColors.info,
        'This order is not ready for pickup yet. It is still being packed.',
      ),
    };

    return WorkerNotice(icon: icon, color: color, text: text);
  }

  /// Delivery bags: the packer only watches; the driver collects.
  Widget _deliveryNotice() {
    final driver = order.driverName ?? 'the driver';
    final verifiedAt = order.collectionVerifiedAt;
    final collected =
        verifiedAt != null && order.collectionVerifiedBy == order.driverId;

    final (icon, color, text) = switch (order.status) {
      OrderStatus.ready when collected => (
        Icons.task_alt_rounded,
        AppColors.success,
        'Collected by $driver at ${Formatters.time(verifiedAt)}.',
      ),
      // Not shown while waiting (see _HandoverContent).
      OrderStatus.ready => (
        Icons.local_shipping_outlined,
        AppColors.info,
        'Waiting for $driver to collect.',
      ),
      OrderStatus.outForDelivery => (
        Icons.local_shipping_outlined,
        AppColors.darkGreen,
        'Collected. $driver is delivering it.',
      ),
      OrderStatus.completed => (
        Icons.task_alt_rounded,
        AppColors.success,
        'Delivered to the customer.',
      ),
      OrderStatus.cancelled => (
        Icons.block_rounded,
        AppColors.error,
        'This order was cancelled. Do not give it to the driver.',
      ),
      _ => (
        Icons.hourglass_top_rounded,
        AppColors.info,
        'This order is still being packed.',
      ),
    };
    return WorkerNotice(icon: icon, color: color, text: text);
  }

  String _handedOverText() {
    final by = order.pickupCompletedBy == workerId
        ? 'you'
        : (order.pickupCompletedByName ?? 'another packer');
    final at = order.completedAt;
    final method = order.pickupVerification;
    return [
      'Handed over by $by',
      if (at != null) ' at ${Formatters.time(at)}',
      if (method != null) ' (${method.label.toLowerCase()})',
      '.',
    ].join();
  }
}

/// One line in the bag: name, brand and size, quantity, and a chevron
/// because tapping it opens the product's details.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.onTap});

  final OrderItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: textTheme.bodyLarge),
                  Text(
                    '${item.brand} · ${item.packSize}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Text('×${item.quantity}', style: textTheme.titleMedium),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
