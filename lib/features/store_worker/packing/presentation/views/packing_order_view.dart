import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_colors.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/core/utilities/formatters.dart';
import 'package:mae_assignment/features/store_worker/orders/data/worker_order_policy.dart';
import 'package:mae_assignment/features/store_worker/packing/data/services/label_print_service.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/bag_label_card.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/bag_label_screen.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_item_tile.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_review_sheet.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/product_details_sheet.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/replacement_sheet.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/view_models/packing_order_view_model.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_notice.dart';
import 'package:mae_assignment/shared/models/order.dart';
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
  /// Ticks the packer just made, by line id. Shown straight away so the
  /// checklist feels instant, and kept until the live order shows the same
  /// thing. (The save is a transaction, which Firestore does not show
  /// locally, so the updated order arrives a moment after the save
  /// finishes; dropping the tick when the save finished made it flick back
  /// for that moment.) Dropped at once if the save fails.
  final Map<String, bool> _savingTicks = {};

  /// Lines whose tick is still being saved, for the "saving" state.
  final Set<String> _inFlight = {};

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
    setState(() {
      _savingTicks[lineId] = packed;
      _inFlight.add(lineId);
    });
    final error = await _viewModel.setItemPacked(lineId, packed: packed);
    if (!mounted) return;
    setState(() {
      _inFlight.remove(lineId);
      // Saved: keep showing the tick until the live order catches up (see
      // _withSavingTicks). Refused: put it back as it was.
      if (error != null) _savingTicks.remove(lineId);
    });
    if (error != null) _showMessage(error);
  }

  /// Asks what to do about an unavailable item, then reports it.
  Future<void> _flagUnavailable(OrderItem item) async {
    final choice = await showReplacementSheet(
      context,
      item: item,
      loadOptions: () => _viewModel.replacementOptions(item.lineId),
    );
    if (choice == null || !mounted) return;

    setState(() => _isBusy = true);
    final error = await _viewModel.flagUnavailable(
      item.lineId,
      replacement: choice.replacement,
    );
    if (!mounted) return;
    setState(() => _isBusy = false);
    _showMessage(
      error ??
          (choice.replacement == null
              ? '${item.name} was removed from the order.'
              : 'Replacement offered. Waiting for the customer to reply.'),
    );
  }

  Future<void> _reviewAndMarkReady(Order order) async {
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
  Order _withSavingTicks(Order order) {
    // Forget ticks the live order already shows, unless a newer save for
    // that line is still running.
    _savingTicks.removeWhere(
      (lineId, packed) =>
          !_inFlight.contains(lineId) && order.isPacked(lineId) == packed,
    );
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
        // Reprint the bag label while the order waits to be collected.
        // Not on the ready screen, which has its own Print label button.
        actions: [
          if (order != null &&
              order.status == OrderStatus.ready &&
              !_justMarkedReady)
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
                  isSaving: _inFlight.isNotEmpty,
                  onSetPacked: _setPacked,
                  onFlagUnavailable: _flagUnavailable,
                  onStart: _startPacking,
                  onReview: () => _reviewAndMarkReady(shown),
                  // Back to wherever the order was opened from (My Tasks
                  // or My history).
                  onBack: _goBack,
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
    required this.onFlagUnavailable,
    required this.onStart,
    required this.onReview,
    required this.onBack,
  });

  final Order order;

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

  /// Called with the original line when the packer reports it unavailable.
  final void Function(OrderItem item) onFlagUnavailable;
  final VoidCallback onStart;
  final VoidCallback onReview;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    bool waiting(OrderItem i) =>
        order.shortageOf(i.lineId)?.status == ShortageStatus.proposed;
    final toPack = order.items
        .where(
          (i) =>
              !order.isPacked(i.lineId) &&
              !order.isRemoved(i.lineId) &&
              !waiting(i),
        )
        .toList();
    final waitingItems = order.items.where(waiting).toList();
    final packed = order.items.where((i) => order.isPacked(i.lineId)).toList();
    final removed = order.items
        .where((i) => order.isRemoved(i.lineId))
        .toList();
    final counter = '${order.packedLineCount}/${order.lineCount}';

    // Null while the checklist cannot be ticked (before Start packing, or
    // read-only orders).
    ValueChanged<bool>? onChanged(OrderItem item) {
      if (!canEdit) return null;
      return (value) => onSetPacked(item.lineId, value);
    }

    Widget tile(OrderItem original) {
      final shortage = order.shortageOf(original.lineId);
      final accepted = shortage?.status == ShortageStatus.accepted
          ? shortage?.replacement
          : null;
      // An accepted replacement is what gets packed.
      final item = accepted ?? original;
      final isRemoved = shortage?.status == ShortageStatus.removed;
      final isWaiting = shortage?.status == ShortageStatus.proposed;
      final note = switch (shortage?.status) {
        ShortageStatus.accepted => 'Replacement for ${original.name}',
        ShortageStatus.proposed =>
          'Waiting for the customer. Offered: '
              '${shortage?.replacement?.name ?? 'replacement'}',
        ShortageStatus.removed => 'Removed from the order',
        null => null,
      };
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s),
        child: PackingItemTile(
          item: item,
          isPacked: order.isPacked(item.lineId),
          onChanged: isRemoved || isWaiting ? null : onChanged(item),
          note: note,
          noteColor: isRemoved ? AppColors.error : AppColors.darkGreen,
          faded: isRemoved,
          onMarkUnavailable:
              canEdit && shortage == null && !order.isPacked(item.lineId)
              ? () => onFlagUnavailable(original)
              : null,
          // Only while the order can still be packed; packed, finished and
          // cancelled orders (e.g. from My history) show no checkboxes.
          showCheckbox:
              order.status == OrderStatus.pending ||
              order.status == OrderStatus.packing,
          onTap: () => showProductDetailsSheet(
            context,
            item: item,
            isPacked: order.isPacked(item.lineId),
            onChanged: isRemoved || isWaiting ? null : onChanged(item),
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
              if (waitingItems.isNotEmpty) ...[
                _SectionTitle('Waiting for customer (${waitingItems.length})'),
                for (final item in waitingItems) tile(item),
              ],
              if (packed.isNotEmpty) ...[
                _SectionTitle('Packed (${packed.length})'),
                for (final item in packed) tile(item),
              ],
              if (removed.isNotEmpty) ...[
                _SectionTitle('Removed (${removed.length})'),
                for (final item in removed) tile(item),
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

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final assignedAt = order.packerAssignedAt ?? order.placedAt;
    final minutes = assignedAt == null
        ? 0
        : Formatters.minutesSince(assignedAt);

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
            // Only while still to pack; once packed, the packed date and
            // time below matters more.
            if (order.readyAt == null)
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
        if (order.readyAt != null) ...[
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Packed on ${Formatters.date(order.readyAt!)} at '
                  '${Formatters.time(order.readyAt!)}',
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

  final Order order;

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
            ? 'Waiting on the pickup shelf for the customer.'
            : _collectedText() ?? 'Waiting for the driver to collect.',
      ),
      OrderStatus.outForDelivery => (
        Icons.local_shipping_outlined,
        AppColors.darkGreen,
        '${_collectedText() ?? 'Collected.'} On the way to the customer.',
      ),
      OrderStatus.completed => (
        Icons.task_alt_rounded,
        AppColors.success,
        '${order.isDelivery ? 'Delivered' : 'Handed over'} to the customer'
            '${_completedOnText()}.',
      ),
      OrderStatus.cancelled => (
        Icons.block_rounded,
        AppColors.error,
        'This order was cancelled. Do not pack it.',
      ),
    };

    return WorkerNotice(icon: icon, color: color, text: text);
  }

  /// " on 15 Oct 2026 at 5:16am", matching the "Packed on…" line, or
  /// nothing if the completion time is unknown.
  String _completedOnText() {
    final at = order.completedAt;
    if (at == null) return '';
    return ' on ${Formatters.date(at)} at ${Formatters.time(at)}';
  }

  /// "Collected on 16 Oct 2026 at 3:42pm." once the assigned driver has
  /// verified the bag; null before that.
  String? _collectedText() {
    final at = order.collectionVerifiedAt;
    if (at == null || order.collectionVerifiedBy != order.driverId) {
      return null;
    }
    return 'Collected on ${Formatters.date(at)} at ${Formatters.time(at)}.';
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

  final Order order;
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
      final waiting = order.hasOpenShortage;
      final canReview =
          left == 0 && order.lineCount > 0 && !waiting && !isSaving && !isBusy;
      return BottomActionBar(
        children: [
          FilledButton.icon(
            onPressed: canReview ? onReview : null,
            icon: isBusy
                ? const ButtonLoadingIndicator()
                : Icon(
                    waiting
                        ? Icons.hourglass_top_rounded
                        : Icons.fact_check_outlined,
                  ),
            label: Text(
              waiting ? 'Waiting for the customer' : 'Review & mark ready',
            ),
          ),
        ],
      );
    }

    // Read-only: nothing left for the packer to do here.
    return BottomActionBar(
      children: [OutlinedButton(onPressed: onBack, child: const Text('Back'))],
    );
  }
}

/// Shown right after the packer marks the order ready: the bag label to
/// print and stick on the bag.
class _ReadySuccess extends ConsumerStatefulWidget {
  const _ReadySuccess({required this.order});

  final Order order;

  @override
  ConsumerState<_ReadySuccess> createState() => _ReadySuccessState();
}

class _ReadySuccessState extends ConsumerState<_ReadySuccess> {
  bool _isPrinting = false;

  Future<void> _printLabel() async {
    setState(() => _isPrinting = true);
    try {
      await ref.read(labelPrintServiceProvider).printLabel(widget.order);
    } on Object catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The label could not be printed. Write the order number on '
              'the bag instead.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Flexible(
                        child: Text(
                          'Order #${order.number} is ready',
                          style: textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BagLabelCard(order: order),
                ],
              ),
            ),
          ),
        ),
        BottomActionBar(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          children: [
            FilledButton.icon(
              onPressed: _isPrinting ? null : _printLabel,
              icon: _isPrinting
                  ? const ButtonLoadingIndicator()
                  : const Icon(Icons.print_outlined),
              label: const Text('Print label'),
            ),
            // Same gap as above Cancel in the Verify order sheet.
            const SizedBox(height: AppSpacing.s),
            TextButton(
              onPressed: () => context.go(AppRoutes.workerPacking),
              child: const Text('Back to My Tasks'),
            ),
          ],
        ),
      ],
    );
  }
}
