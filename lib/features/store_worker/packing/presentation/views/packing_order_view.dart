import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/orders/data/worker_order_policy.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_item_tile.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_review_sheet.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/product_details_sheet.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/view_models/packing_order_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_notice.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/bottom_action_bar.dart';
import 'package:mae_assignment/shared/ui/button_loading_indicator.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';
import 'package:mae_assignment/shared/ui/fulfilment_tag.dart';
import 'package:mae_assignment/shared/ui/order_status_label.dart';

/// Full-screen packing view for one order: details, the checklist with
/// live progress, and the Start packing / Review & mark ready actions.
/// Orders that cannot be packed any more (cancelled, ready, delivered)
/// are shown read-only.
class PackingOrderView extends ConsumerStatefulWidget {
  const PackingOrderView({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<PackingOrderView> createState() => _PackingOrderViewState();
}

class _PackingOrderViewState extends ConsumerState<PackingOrderView> {
  /// Ticks the packer just made that are still being saved, by line id.
  /// Shown straight away so the checklist feels instant; dropped once the
  /// repository answers (the saved order then shows the same thing).
  final Map<String, bool> _savingTicks = {};

  /// True while Start packing or Mark as ready is running.
  bool _isBusy = false;

  /// True after this packer marked the order ready here, to show the
  /// success panel.
  bool _justMarkedReady = false;

  PackingOrderViewModel get _viewModel =>
      ref.read(packingOrderViewModelProvider(widget.orderId).notifier);

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.workerPacking);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _startPacking() async {
    setState(() => _isBusy = true);
    final error = await _viewModel.startPacking();
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (error != null) _showMessage(error);
  }

  Future<void> _setPacked(String lineId, bool packed) async {
    setState(() => _savingTicks[lineId] = packed);
    final error = await _viewModel.setItemPacked(lineId, packed: packed);
    if (!mounted) return;
    setState(() => _savingTicks.remove(lineId));
    if (error != null) _showMessage(error);
  }

  Future<void> _reviewAndMarkReady(WorkerOrder order) async {
    final confirmed = await showPackingReviewSheet(context, order);
    if (!confirmed || !mounted) return;

    setState(() => _isBusy = true);
    final error = await _viewModel.markReady();
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      _justMarkedReady = error == null;
    });
    if (error != null) _showMessage(error);
  }

  /// The order with the ticks still being saved applied on top.
  WorkerOrder _withSavingTicks(WorkerOrder order) {
    if (_savingTicks.isEmpty) return order;
    final lines = {...order.packedLineIds};
    _savingTicks.forEach((lineId, packed) {
      if (packed) {
        lines.add(lineId);
      } else {
        lines.remove(lineId);
      }
    });
    return order.copyWith(packedLineIds: lines);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(packingOrderViewModelProvider(widget.orderId));
    final worker = ref.watch(workerSessionProvider);
    final order = orderState.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        title: Text(order == null ? 'Order' : 'Order #${order.number}'),
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
                  packingOrderViewModelProvider(widget.orderId),
                ),
              ),
              data: (order) {
                if (order == null || worker == null) {
                  return EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Order not available',
                    message:
                        'This order is no longer assigned to you. It may have '
                        'been reassigned or removed.',
                    action: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.workerPacking),
                      child: const Text('Back to My Tasks'),
                    ),
                  );
                }
                if (_justMarkedReady) return _ReadySuccess(order: order);

                final shown = _withSavingTicks(order);
                final canEdit =
                    order.status == OrderStatus.packing &&
                    WorkerOrderPolicy.canViewPackingTask(worker, order);
                final canStart =
                    WorkerOrderPolicy.checkStartPacking(worker, order) == null;
                return _PackingContent(
                  order: shown,
                  canEdit: canEdit,
                  canStart: canStart,
                  isBusy: _isBusy,
                  isSaving: _savingTicks.isNotEmpty,
                  onSetPacked: _setPacked,
                  onStart: _startPacking,
                  onReview: () => _reviewAndMarkReady(shown),
                  onBack: () => context.go(AppRoutes.workerPacking),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The order's details and checklist, with the action bar at the bottom.
class _PackingContent extends StatelessWidget {
  const _PackingContent({
    required this.order,
    required this.canEdit,
    required this.canStart,
    required this.isBusy,
    required this.isSaving,
    required this.onSetPacked,
    required this.onStart,
    required this.onReview,
    required this.onBack,
  });

  final WorkerOrder order;

  /// True while the checklist can be ticked.
  final bool canEdit;

  /// True if Start packing is allowed.
  final bool canStart;
  final bool isBusy;

  /// True while a tick is still being saved.
  final bool isSaving;
  // Callback signature: a positional (lineId, packed) pair reads naturally
  // for a checklist toggle.
  // ignore: avoid_positional_boolean_parameters
  final void Function(String lineId, bool packed) onSetPacked;
  final VoidCallback onStart;
  final VoidCallback onReview;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final toPack = order.items.where((i) => !order.isPacked(i.lineId)).toList();
    final packed = order.items.where((i) => order.isPacked(i.lineId)).toList();
    final counter = '${order.packedLineCount}/${order.lineCount}';

    // Null while the checklist cannot be ticked (before Start packing, or
    // read-only orders).
    ValueChanged<bool>? onChanged(WorkerOrderItem item) {
      if (!canEdit) return null;
      return (value) => onSetPacked(item.lineId, value);
    }

    Widget tile(WorkerOrderItem item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s),
        child: PackingItemTile(
          item: item,
          isPacked: order.isPacked(item.lineId),
          onChanged: onChanged(item),
          onTap: () => showProductDetailsSheet(
            context,
            item: item,
            isPacked: order.isPacked(item.lineId),
            onChanged: onChanged(item),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              _OrderHeader(order: order),
              // No banner while packing: the checklist speaks for itself.
              if (order.status != OrderStatus.packing) ...[
                const SizedBox(height: AppSpacing.m),
                _StatusBanner(order: order),
              ],
              // Something left to pack: TO PACK carries the counter.
              if (toPack.isNotEmpty) ...[
                _SectionTitle('To pack (${toPack.length})', trailing: counter),
                for (final item in toPack) tile(item),
              ],
              if (packed.isNotEmpty) ...[
                _SectionTitle('Packed (${packed.length})'),
                for (final item in packed) tile(item),
              ],
            ],
          ),
        ),
        _ActionBar(
          order: order,
          canStart: canStart,
          isBusy: isBusy,
          isSaving: isSaving,
          onStart: onStart,
          onReview: onReview,
          onBack: onBack,
        ),
      ],
    );
  }
}

/// Customer, pickup or delivery, status, driver and the customer's note.
class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final WorkerOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final minutes = Formatters.minutesSince(order.packerAssignedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(order.customerName, style: textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FulfilmentTag(isDelivery: order.isDelivery),
            OrderStatusBadge(status: order.status),
            Text(
              'Assigned ${Formatters.minutes(minutes)} ago',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        if (order.isDelivery && order.driverName != null) ...[
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Driver: ${order.driverName}',
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
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
                    'Customer note: ${order.customerNote}',
                    style: textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// One-line explanation of what the packer can do with the order now.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.order});

  final WorkerOrder order;

  @override
  Widget build(BuildContext context) {
    final (icon, color, text) = switch (order.status) {
      OrderStatus.pending => (
        Icons.info_outline_rounded,
        AppColors.info,
        'Tap Start packing, then tick each product as it goes into the bag.',
      ),
      // Not shown while packing (see _PackingContent).
      OrderStatus.packing => (
        Icons.inventory_2_outlined,
        AppColors.info,
        'Being packed.',
      ),
      OrderStatus.ready => (
        Icons.check_circle_outline_rounded,
        AppColors.success,
        !order.isDelivery
            ? 'Packed and waiting on the pickup shelf.'
            : _collectedText() ??
                  'Packed and waiting for ${order.driverName ?? 'the driver'}.',
      ),
      OrderStatus.outForDelivery => (
        Icons.local_shipping_outlined,
        AppColors.darkGreen,
        '${_collectedText() ?? 'Packed.'} '
            '${order.driverName ?? 'The driver'} is delivering it.',
      ),
      OrderStatus.completed => (
        Icons.task_alt_rounded,
        AppColors.success,
        order.isDelivery
            ? 'Delivered to the customer.'
            : 'Handed over to the customer.',
      ),
      OrderStatus.cancelled => (
        Icons.block_rounded,
        AppColors.error,
        'This order was cancelled. Do not pack it.',
      ),
    };

    return WorkerNotice(icon: icon, color: color, text: text);
  }

  /// "Collected by Amir Hamzah at 3:42pm." once the assigned driver has
  /// verified the bag; null before that.
  String? _collectedText() {
    final at = order.collectionVerifiedAt;
    if (at == null || order.collectionVerifiedBy != order.driverId) {
      return null;
    }
    return 'Collected by ${order.driverName ?? 'the driver'} at '
        '${Formatters.time(at)}.';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.trailing});

  final String text;

  /// Shown on the right, e.g. the packed count "2/5".
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.s),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: style)),
          if (trailing != null)
            Text(trailing!, style: style?.copyWith(color: AppColors.darkGreen)),
        ],
      ),
    );
  }
}

/// The main action for the order's status, pinned to the bottom.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.order,
    required this.canStart,
    required this.isBusy,
    required this.isSaving,
    required this.onStart,
    required this.onReview,
    required this.onBack,
  });

  final WorkerOrder order;
  final bool canStart;
  final bool isBusy;
  final bool isSaving;
  final VoidCallback onStart;
  final VoidCallback onReview;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (order.status == OrderStatus.pending && canStart) {
      return BottomActionBar(
        children: [
          FilledButton.icon(
            onPressed: isBusy ? null : onStart,
            icon: isBusy
                ? const ButtonLoadingIndicator()
                : const Icon(Icons.play_arrow_rounded),
            label: const Text('Start packing'),
          ),
        ],
      );
    }

    if (order.status == OrderStatus.packing) {
      final left = order.lineCount - order.packedLineCount;
      final canReview = left == 0 && !isSaving && !isBusy;
      return BottomActionBar(
        children: [
          FilledButton.icon(
            onPressed: canReview ? onReview : null,
            icon: isBusy
                ? const ButtonLoadingIndicator()
                : const Icon(Icons.fact_check_outlined),
            label: const Text('Review & mark ready'),
          ),
        ],
      );
    }

    // Read-only: nothing left for the packer to do here.
    return BottomActionBar(
      children: [
        OutlinedButton(
          onPressed: onBack,
          child: const Text('Back to My Tasks'),
        ),
      ],
    );
  }
}

/// Shown right after the packer marks the order ready.
class _ReadySuccess extends StatelessWidget {
  const _ReadySuccess({required this.order});

  final WorkerOrder order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nextStep = order.isDelivery
        ? 'Label the bag and keep it for '
              '${order.driverName ?? 'the driver'}. They will verify it '
              'before leaving.'
        : 'Label the bag and put it on the pickup shelf. It now shows in '
              'Ready for Pickup for every packer at ${order.branchName}.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.greenTint,
                    foregroundColor: AppColors.success,
                    child: Icon(Icons.check_rounded, size: 48),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Order #${order.number} is ready',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    nextStep,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Large order number to copy onto the bag.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.m,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkGreen, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('BAG LABEL', style: textTheme.bodySmall),
                        Text(
                          '#${order.number}',
                          style: textTheme.headlineMedium,
                        ),
                        Text(
                          '${order.customerName} · '
                          '${order.isDelivery ? 'Delivery' : 'Pickup'}',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        BottomActionBar(
          children: [
            FilledButton(
              onPressed: () => context.go(AppRoutes.workerPacking),
              child: const Text('Back to My Tasks'),
            ),
          ],
        ),
      ],
    );
  }
}
