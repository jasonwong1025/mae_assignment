import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/services/launcher_service.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/delivery_map_preview.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/delivery_order_card.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/delivery_stepper.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/expandable_photo.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/proof_of_delivery_sheet.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/ui/verify_order_sheet.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/view_models/delivery_detail_view_model.dart';
import 'package:mae_assignment/features/store_worker/delivery/presentation/view_models/driver_tracking_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_notice.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Full-screen view of one delivery: progress, customer and address with
/// Call and Navigate, the bag's contents (read-only), and the next step:
/// Verify order, Start delivery or Mark as delivered.
class DeliveryDetailView extends ConsumerStatefulWidget {
  const DeliveryDetailView({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<DeliveryDetailView> createState() => _DeliveryDetailViewState();
}

class _DeliveryDetailViewState extends ConsumerState<DeliveryDetailView> {
  /// True while Start delivery or Mark as delivered is running.
  bool _isBusy = false;

  /// True once this driver completed the delivery and the screen is
  /// closing, so it does not flash its read-only state.
  bool _isLeaving = false;

  DeliveryDetailViewModel get _viewModel =>
      ref.read(deliveryDetailViewModelProvider(widget.orderId).notifier);

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.workerDelivery);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// No message on success: the stepper, notice and button already change
  /// to "verified", and a SnackBar would cover the Start delivery button.
  Future<void> _verify(Order order) async {
    await showVerifyOrderSheet(
      context,
      order: order,
      onVerify: _viewModel.verifyByCode,
      onScan: _viewModel.verifyByQr,
    );
  }

  Future<void> _startDelivery() async {
    setState(() => _isBusy = true);
    final error = await _viewModel.startDelivery();
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (error != null) _showMessage(error);
  }

  Future<void> _completeDelivery(Order order) async {
    // A photo is required: proof for disputes and contactless drop-offs.
    final photo = await showProofOfDeliverySheet(context, order: order);
    if (photo == null || !mounted) return;

    setState(() => _isBusy = true);
    final error = await _viewModel.completeDelivery(photo: photo);
    if (!mounted) return;
    if (error != null) {
      setState(() => _isBusy = false);
      _showMessage(error);
      return;
    }
    setState(() => _isLeaving = true);
    _showMessage('Order #${order.number} delivered to ${order.customerName}.');
    _goBack();
  }

  /// True until the driver starts the delivery: Navigate leads to the
  /// branch the bag is collected from, not to the customer.
  bool _collectsFirst(Order order) =>
      order.status == OrderStatus.pending ||
      order.status == OrderStatus.packing ||
      order.status == OrderStatus.ready;

  /// The pickup branch before collection, the customer's address after.
  String? _navigationTarget(Order order) {
    if (_collectsFirst(order)) {
      return order.branchAddress ?? 'Grocerly ${order.branchName}';
    }
    return order.address;
  }

  Future<void> _navigate(String address) async {
    final opened = await ref
        .read(launcherServiceProvider)
        .openDirections(address);
    if (!opened && mounted) {
      _showMessage('Google Maps could not be opened on this device.');
    }
  }

  Future<void> _call(String phone) async {
    final opened = await ref.read(launcherServiceProvider).call(phone);
    if (!opened && mounted) {
      _showMessage('Calls cannot be made from this device.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(
      deliveryDetailViewModelProvider(widget.orderId),
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
        title: Text(order == null ? 'Delivery' : 'Delivery #${order.number}'),
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
                message: 'This delivery could not be loaded.',
                onRetry: () => ref.invalidate(
                  deliveryDetailViewModelProvider(widget.orderId),
                ),
              ),
              data: (order) {
                if (_isLeaving) return const SizedBox.shrink();
                if (order == null || worker == null) {
                  return EmptyState(
                    icon: Icons.local_shipping_outlined,
                    title: 'Delivery not available',
                    message:
                        'This delivery is no longer assigned to you. It may '
                        'have been given to another driver.',
                    action: OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.workerDelivery),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back to My Deliveries'),
                    ),
                  );
                }
                // Shares the position only while the order is on the road;
                // leaving the screen or finishing the delivery stops it.
                final tracking = order.status == OrderStatus.outForDelivery
                    ? ref.watch(driverTrackingViewModelProvider(order.id))
                    : null;
                return _DeliveryContent(
                  order: order,
                  tracking: tracking,
                  workerId: worker.id,
                  isBusy: _isBusy,
                  onCall: () => _call(order.customerPhone),
                  onNavigate: _navigationTarget(order) == null
                      ? null
                      : () => _navigate(_navigationTarget(order)!),
                  navigateLabel: _collectsFirst(order)
                      ? 'Navigate to store'
                      : 'Navigate',
                  onVerify: () => _verify(order),
                  onStart: _startDelivery,
                  onComplete: () => _completeDelivery(order),
                  onBack: () => context.go(AppRoutes.workerDelivery),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryContent extends StatelessWidget {
  const _DeliveryContent({
    required this.order,
    required this.tracking,
    required this.workerId,
    required this.isBusy,
    required this.onCall,
    required this.onNavigate,
    required this.navigateLabel,
    required this.onVerify,
    required this.onStart,
    required this.onComplete,
    required this.onBack,
  });

  final Order order;

  /// Location sharing, while the order is out for delivery; otherwise null.
  final DriverTrackingState? tracking;
  final String workerId;
  final bool isBusy;
  final VoidCallback onCall;

  /// Null if there is nowhere to navigate to.
  final VoidCallback? onNavigate;
  final String navigateLabel;
  final VoidCallback onVerify;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBack;

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
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('#${order.number}', style: textTheme.headlineSmall),
                  OrderStatusBadge(
                    status: deliveryBadgeStatus(order),
                    label: deliveryStatusLabel(order),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              DeliveryStepper(order: order, workerId: workerId),
              // Only when it adds something the stepper and button do not.
              if (_StatusNotice.isShown(order, workerId)) ...[
                const SizedBox(height: AppSpacing.l),
                _StatusNotice(order: order, workerId: workerId),
              ],
              if (tracking != null) ...[
                const SizedBox(height: AppSpacing.l),
                _SharingNotice(order: order, tracking: tracking!),
              ],
              const SizedBox(height: AppSpacing.l),
              // Where the store and customer are, and how far apart.
              DeliveryMapPreview(order: order),
              const SizedBox(height: AppSpacing.l),
              _CustomerCard(
                order: order,
                onCall: onCall,
                onNavigate: onNavigate,
                navigateLabel: navigateLabel,
              ),
              if (order.proofPhotoUrl != null) ...[
                const SizedBox(height: AppSpacing.l),
                _ProofCard(order: order),
              ],
              const SizedBox(height: AppSpacing.l),
              _ItemsSection(order: order),
            ],
          ),
        ),
        _ActionBar(
          order: order,
          workerId: workerId,
          isBusy: isBusy,
          onVerify: onVerify,
          onStart: onStart,
          onComplete: onComplete,
          onBack: onBack,
        ),
      ],
    );
  }
}

/// Tells the driver the customer can see them, with the estimate the
/// customer sees, or what is stopping the sharing.
class _SharingNotice extends StatelessWidget {
  const _SharingNotice({required this.order, required this.tracking});

  final Order order;
  final DriverTrackingState tracking;

  @override
  Widget build(BuildContext context) {
    final error = tracking.error;
    if (error != null) {
      return WorkerNotice(
        icon: Icons.location_off_outlined,
        color: AppColors.error,
        text: error,
      );
    }
    final eta = order.etaAt(DateTime.now());
    return WorkerNotice(
      icon: Icons.my_location_rounded,
      color: AppColors.info,
      text: eta == null
          ? 'Sharing your location with the customer.'
          : 'Sharing your location. About '
                '${Formatters.minutes(eta.remaining.inMinutes)} to the '
                'customer, arriving around ${Formatters.time(eta.arrivalAt)}.',
    );
  }
}

/// A notice only where it adds something the badge, stepper and button
/// do not: where to collect and to verify first, the delivered time, and
/// the cancelled warning.
class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.order, required this.workerId});

  final Order order;
  final String workerId;

  static bool isShown(Order order, String workerId) {
    return switch (order.status) {
      OrderStatus.ready => order.collectionVerifiedBy != workerId,
      OrderStatus.completed || OrderStatus.cancelled => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final completedAt = order.completedAt;

    final (icon, color, text) = switch (order.status) {
      OrderStatus.completed => (
        Icons.task_alt_rounded,
        AppColors.success,
        completedAt == null
            ? 'Delivered.'
            : 'Delivered on ${Formatters.date(completedAt)} at '
                  '${Formatters.time(completedAt)}.',
      ),
      OrderStatus.cancelled => (
        Icons.block_rounded,
        AppColors.error,
        'This order was cancelled. Do not deliver it.',
      ),
      // Ready and not yet verified (see isShown).
      _ => (
        Icons.inventory_2_outlined,
        AppColors.success,
        'Collect at ${order.branchName}. Verify the bag before you leave.',
      ),
    };

    return WorkerNotice(icon: icon, color: color, text: text);
  }
}

/// Name, phone with Call, address with Navigate, and the customer's note.
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.order,
    required this.onCall,
    required this.onNavigate,
    required this.navigateLabel,
  });

  final Order order;
  final VoidCallback onCall;
  final VoidCallback? onNavigate;
  final String navigateLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('CUSTOMER', style: _labelStyle(textTheme)),
            const SizedBox(height: AppSpacing.xs),
            Text(order.customerName, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(order.customerPhone, style: textTheme.bodyLarge),
                ),
              ],
            ),
            // Drivers deliver for any branch, so show where to collect.
            const SizedBox(height: AppSpacing.l),
            _IconLabel(
              icon: Icons.storefront_outlined,
              text: 'COLLECT FROM',
              style: _labelStyle(textTheme),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Grocerly ${order.branchName}', style: textTheme.bodyLarge),
            if (order.branchAddress != null)
              Text(order.branchAddress!, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.l),
            _IconLabel(
              icon: Icons.place_outlined,
              text: 'DELIVER TO',
              style: _labelStyle(textTheme),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              order.address ?? 'No address given',
              style: textTheme.bodyLarge,
            ),
            if (order.customerNote != null) ...[
              const SizedBox(height: AppSpacing.m),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Text(
                        'Note: ${order.customerNote}',
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            // Side by side; each takes half the width so they fit any phone.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNavigate,
                    icon: const Icon(Icons.directions_outlined),
                    label: Text(navigateLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle? _labelStyle(TextTheme textTheme) {
    return textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
  }
}

/// What is in the bag, collapsed by default to keep the screen short.
class _ItemsSection extends StatelessWidget {
  const _ItemsSection({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.shopping_bag_outlined),
        title: Text(
          'Order items (${order.itemCount} '
          '${order.itemCount == 1 ? 'item' : 'items'})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.s,
        ),
        children: [
          // A plain read-only list: the checklist belongs to the packer,
          // and the driver only needs to know what is in the bag.
          for (final (index, item) in order.effectiveItems.indexed) ...[
            if (index > 0) const Divider(height: 1),
            _ItemRow(item: item),
          ],
        ],
      ),
    );
  }
}

/// The proof of delivery photo.
class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 16,
                  color: labelStyle?.color,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('PROOF OF DELIVERY', style: labelStyle),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            ExpandablePhoto(
              image: NetworkImage(order.proofPhotoUrl!),
              borderRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

/// One line of the order: name, brand and size, and quantity.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
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
        ],
      ),
    );
  }
}

/// The next step for the delivery, pinned to the bottom.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.order,
    required this.workerId,
    required this.isBusy,
    required this.onVerify,
    required this.onStart,
    required this.onComplete,
    required this.onBack,
  });

  final Order order;
  final String workerId;
  final bool isBusy;
  final VoidCallback onVerify;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  Widget _button({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return FilledButton.icon(
      onPressed: isBusy ? null : onPressed,
      icon: isBusy ? const ButtonLoadingIndicator() : Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.packing:
        // Visible but disabled, so the driver knows what comes next.
        return BottomActionBar(
          children: [
            Text(
              'You can verify the order once it is ready',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Verify order'),
            ),
          ],
        );
      case OrderStatus.ready:
        final verified = order.collectionVerifiedBy == workerId;
        return BottomActionBar(
          children: [
            if (verified)
              _button(
                icon: Icons.local_shipping_outlined,
                label: 'Start delivery',
                onPressed: onStart,
              )
            else
              _button(
                icon: Icons.fact_check_outlined,
                label: 'Verify order',
                onPressed: onVerify,
              ),
          ],
        );
      case OrderStatus.outForDelivery:
        return BottomActionBar(
          children: [
            _button(
              icon: Icons.task_alt_rounded,
              label: 'Mark as delivered',
              onPressed: onComplete,
            ),
          ],
        );
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return BottomActionBar(
          children: [
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to My Deliveries'),
            ),
          ],
        );
    }
  }
}

/// A section label with a small icon before it, e.g. "COLLECT FROM".
class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: style?.color ?? AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: style),
      ],
    );
  }
}
