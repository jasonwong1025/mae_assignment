import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_item_tile.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/ui/pickup_order_card.dart';
import 'package:mae_assignment/features/store_worker/pickup/presentation/view_models/pickup_handover_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_notice.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/confirm_sheet.dart';
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
  // The two manual checks. Both are needed before Complete pickup.
  bool _numberChecked = false;
  bool _nameChecked = false;

  /// True while Complete pickup is running.
  bool _isBusy = false;

  /// True once this packer handed the order over and the screen is
  /// closing. Stops a "not available" flash as the order leaves the queue.
  bool _isLeaving = false;

  bool get _isVerified => _numberChecked && _nameChecked;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.workerPickup);
    }
  }

  Future<void> _completePickup(WorkerOrder order) async {
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.shopping_bag_outlined,
      title: 'Hand over order #${order.number}?',
      message:
          'Give the bag to ${order.customerName}. This completes the order '
          'and cannot be undone.',
      confirmLabel: 'Hand over',
    );
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    final error = await ref
        .read(pickupHandoverViewModelProvider(widget.orderId).notifier)
        .completePickup(method: VerificationMethod.manual);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (error != null) {
      setState(() => _isBusy = false);
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isLeaving = true);
    messenger.showSnackBar(
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
        title: Text(order == null ? 'Pickup' : 'Pickup #${order.number}'),
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
              data: (order) {
                if (_isLeaving) return const SizedBox.shrink();
                if (order == null || worker == null || order.isDelivery) {
                  return EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Order not available',
                    message: order != null && order.isDelivery
                        ? 'This is a delivery order. Its driver collects it '
                              'from the store.'
                        : 'This order is no longer waiting for pickup. '
                              'Another packer may have handed it over.',
                    action: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.workerPickup),
                      child: const Text('Back to Ready for Pickup'),
                    ),
                  );
                }
                return _HandoverContent(
                  order: order,
                  workerId: worker.id,
                  numberChecked: _numberChecked,
                  nameChecked: _nameChecked,
                  isBusy: _isBusy,
                  onNumberChecked: (value) =>
                      setState(() => _numberChecked = value),
                  onNameChecked: (value) =>
                      setState(() => _nameChecked = value),
                  onComplete: _isVerified && !_isBusy
                      ? () => _completePickup(order)
                      : null,
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
    required this.numberChecked,
    required this.nameChecked,
    required this.isBusy,
    required this.onNumberChecked,
    required this.onNameChecked,
    required this.onComplete,
    required this.onBack,
  });

  final WorkerOrder order;
  final String workerId;
  final bool numberChecked;
  final bool nameChecked;
  final bool isBusy;
  final ValueChanged<bool> onNumberChecked;
  final ValueChanged<bool> onNameChecked;

  /// Null keeps Complete pickup disabled.
  final VoidCallback? onComplete;
  final VoidCallback onBack;

  bool get _canHandOver => order.status == OrderStatus.ready;

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
              const SizedBox(height: AppSpacing.l),
              if (_canHandOver)
                _VerificationCard(
                  order: order,
                  numberChecked: numberChecked,
                  nameChecked: nameChecked,
                  onNumberChecked: onNumberChecked,
                  onNameChecked: onNameChecked,
                )
              else
                _StatusNotice(order: order, workerId: workerId),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  bottom: AppSpacing.s,
                ),
                child: Text(
                  'IN THE BAG (${order.lineCount} PRODUCTS · '
                  '${order.itemCount} ITEMS)',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
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
        ),
        if (_canHandOver)
          BottomActionBar(
            children: [
              if (onComplete == null && !isBusy) ...[
                Text(
                  'Tick both checks above to continue',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.s),
              ],
              FilledButton.icon(
                onPressed: onComplete,
                icon: isBusy
                    ? const ButtonLoadingIndicator()
                    : const Icon(Icons.shopping_bag_outlined),
                label: const Text('Complete pickup'),
              ),
            ],
          )
        else
          BottomActionBar(
            children: [
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back to Ready for Pickup'),
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

  final WorkerOrder order;
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
              label: isReady ? 'Ready for pickup' : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(order.customerName, style: textTheme.titleLarge),
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
        const SizedBox(height: AppSpacing.xs),
        Text(
          isReady
              ? '${packedByText(order, workerId)} · ready '
                    '${Formatters.minutes(minutesReady(order))} ago'
              : packedByText(order, workerId),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// The manual check: order number and name, both ticked by the packer.
/// This only confirms the right bag goes to the right person; it does not
/// prove who the customer is.
class _VerificationCard extends StatelessWidget {
  const _VerificationCard({
    required this.order,
    required this.numberChecked,
    required this.nameChecked,
    required this.onNumberChecked,
    required this.onNameChecked,
  });

  final WorkerOrder order;
  final bool numberChecked;
  final bool nameChecked;
  final ValueChanged<bool> onNumberChecked;
  final ValueChanged<bool> onNameChecked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final verified = numberChecked && nameChecked;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: verified ? AppColors.success : AppColors.border,
          width: verified ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Verify the customer', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Ask for the order number and name before handing over the '
              'bag.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            CheckboxListTile(
              value: numberChecked,
              onChanged: (value) => onNumberChecked(value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text('Customer gave order number #${order.number}'),
            ),
            CheckboxListTile(
              value: nameChecked,
              onChanged: (value) => onNameChecked(value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text('Name matches ${order.customerName}'),
            ),
            if (verified)
              const Row(
                children: [
                  Icon(Icons.verified_outlined, color: AppColors.success),
                  SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'Verified by manual check',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Why the order can no longer be handed over.
class _StatusNotice extends StatelessWidget {
  const _StatusNotice({required this.order, required this.workerId});

  final WorkerOrder order;
  final String workerId;

  @override
  Widget build(BuildContext context) {
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
