import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/utilities/formatters.dart';
import '../../../../../shared/models/order_status.dart';
import '../../../../../shared/ui/bottom_action_bar.dart';
import '../../../../../shared/ui/button_loading_indicator.dart';
import '../../../../../shared/ui/confirm_sheet.dart';
import '../../../../../shared/ui/empty_state.dart';
import '../../../../../shared/ui/order_status_label.dart';
import '../../../orders/data/models/worker_order.dart';
import '../../../packing/presentation/ui/packing_item_tile.dart';
import '../../../packing/presentation/ui/packing_progress_bar.dart';
import '../../../session/presentation/view_models/worker_session_view_model.dart';
import '../../data/services/launcher_service.dart';
import '../ui/delivery_order_card.dart';
import '../ui/delivery_stepper.dart';
import '../ui/verify_order_sheet.dart';
import '../view_models/delivery_detail_view_model.dart';
import '../../../shell/presentation/ui/worker_notice.dart';

/// Full-screen view of one delivery: progress, customer and address with
/// Call and Navigate, the bag's contents (read-only), and the next step:
/// Verify order, Start delivery or Mark as delivered.
class DeliveryDetailView extends ConsumerStatefulWidget {
  const DeliveryDetailView({super.key, required this.orderId});

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
  Future<void> _verify(WorkerOrder order) async {
    await showVerifyOrderSheet(
      context,
      order: order,
      onVerify: _viewModel.verifyByNumber,
    );
  }

  Future<void> _startDelivery() async {
    setState(() => _isBusy = true);
    final error = await _viewModel.startDelivery();
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (error != null) _showMessage(error);
  }

  Future<void> _completeDelivery(WorkerOrder order) async {
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.task_alt_rounded,
      title: 'Mark order #${order.number} delivered?',
      message:
          'Only confirm once the groceries are with ${order.customerName}. '
          'This completes the order and cannot be undone.',
      confirmLabel: 'Mark delivered',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    final error = await _viewModel.completeDelivery();
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

  Future<void> _navigate(String address) async {
    final opened = await ref.read(launcherServiceProvider).openDirections(
      address,
    );
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
                    action: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.workerDelivery),
                      child: const Text('Back to My Deliveries'),
                    ),
                  );
                }
                return _DeliveryContent(
                  order: order,
                  workerId: worker.id,
                  isBusy: _isBusy,
                  onCall: () => _call(order.customerPhone),
                  onNavigate: order.address == null
                      ? null
                      : () => _navigate(order.address!),
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
    required this.workerId,
    required this.isBusy,
    required this.onCall,
    required this.onNavigate,
    required this.onVerify,
    required this.onStart,
    required this.onComplete,
    required this.onBack,
  });

  final WorkerOrder order;
  final String workerId;
  final bool isBusy;
  final VoidCallback onCall;

  /// Null if the order has no address.
  final VoidCallback? onNavigate;
  final VoidCallback onVerify;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  bool get _isBeingPacked =>
      order.status == OrderStatus.pending ||
      order.status == OrderStatus.packing;

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
                    status: order.status,
                    label: deliveryStatusLabel(order),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              DeliveryStepper(order: order, workerId: workerId),
              const SizedBox(height: AppSpacing.l),
              _StatusNotice(order: order, workerId: workerId),
              if (_isBeingPacked) ...[
                const SizedBox(height: AppSpacing.m),
                PackingProgressBar(order: order),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Being packed by ${order.packerName}',
                  style: textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              _CustomerCard(
                order: order,
                onCall: onCall,
                onNavigate: onNavigate,
              ),
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

/// One line saying what the driver should do now.
class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.order, required this.workerId});

  final WorkerOrder order;
  final String workerId;

  @override
  Widget build(BuildContext context) {
    final verifiedByMe = order.collectionVerifiedBy == workerId;
    final completedAt = order.completedAt;

    final (icon, color, text) = switch (order.status) {
      OrderStatus.pending || OrderStatus.packing => (
        Icons.hourglass_top_rounded,
        AppColors.info,
        'Still being packed. You can verify and collect it once it is ready.',
      ),
      OrderStatus.ready when !verifiedByMe => (
        Icons.inventory_2_outlined,
        AppColors.success,
        'Ready at ${order.branchName}. Check the bag label and verify the '
            'order number before you leave.',
      ),
      OrderStatus.ready => (
        Icons.verified_outlined,
        AppColors.success,
        'Order verified. Start the delivery when you leave the store.',
      ),
      OrderStatus.outForDelivery => (
        Icons.local_shipping_outlined,
        AppColors.darkGreen,
        'On the way. Mark it delivered once the customer has the groceries.',
      ),
      OrderStatus.completed => (
        Icons.task_alt_rounded,
        AppColors.success,
        completedAt == null
            ? 'Delivered.'
            : 'Delivered at ${Formatters.time(completedAt)}.',
      ),
      OrderStatus.cancelled => (
        Icons.block_rounded,
        AppColors.error,
        'This order was cancelled. Do not deliver it.',
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
  });

  final WorkerOrder order;
  final VoidCallback onCall;
  final VoidCallback? onNavigate;

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
            const SizedBox(height: AppSpacing.l),
            Text('DELIVER TO', style: _labelStyle(textTheme)),
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
                    label: const Text('Navigate'),
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

  final WorkerOrder order;

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
          'Order items (${order.lineCount} products · '
          '${order.itemCount} items)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          0,
          AppSpacing.m,
          AppSpacing.m,
        ),
        children: [
          // Read-only: the checklist belongs to the packer.
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: PackingItemTile(
                item: item,
                isPacked: order.isPacked(item.lineId),
                onChanged: null,
              ),
            ),
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

  final WorkerOrder order;
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
            verified
                ? _button(
                    icon: Icons.local_shipping_outlined,
                    label: 'Start delivery',
                    onPressed: onStart,
                  )
                : _button(
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
            OutlinedButton(
              onPressed: onBack,
              child: const Text('Back to My Deliveries'),
            ),
          ],
        );
    }
  }
}
