import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mae_assignment/app/router/app_router.dart';
import 'package:mae_assignment/app/theme/app_spacing.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/ui/packing_task_card.dart';
import 'package:mae_assignment/features/store_worker/packing/presentation/view_models/packing_tasks_view_model.dart';
import 'package:mae_assignment/features/store_worker/shell/presentation/ui/worker_scaffold.dart';
import 'package:mae_assignment/features/store_worker/shell/worker_routes.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/ui/empty_state.dart';

/// Packing Staff "My Tasks" tab: orders assigned to the signed-in packer
/// at their branch, with the next one to pack at the top.
class PackingTasksView extends ConsumerStatefulWidget {
  const PackingTasksView({super.key});

  @override
  ConsumerState<PackingTasksView> createState() => _PackingTasksViewState();
}

class _PackingTasksViewState extends ConsumerState<PackingTasksView> {
  /// The order whose Start button was tapped, so only it shows a spinner.
  String? _startingOrderId;

  void _openOrder(Order order) {
    unawaited(context.push(AppRoutes.workerPackingOrder(order.id)));
  }

  Future<void> _startPacking(Order order) async {
    setState(() => _startingOrderId = order.id);
    final error = await ref
        .read(packingTasksViewModelProvider.notifier)
        .startPacking(order.id);
    if (!mounted) return;
    setState(() => _startingOrderId = null);

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    _openOrder(order);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(packingTasksViewModelProvider);

    return WorkerScaffold(
      currentTab: WorkerTab.myTasks,
      child: tasks.when(
        // Keep showing the old list while a new one loads.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorState(
          message: 'Your packing tasks could not be loaded.',
          onRetry: () => ref.invalidate(packingTasksViewModelProvider),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'No packing tasks',
              message:
                  'You have no orders to pack right now. New orders '
                  'assigned to you will appear here automatically.',
            );
          }
          return _TaskList(
            orders: orders,
            startingOrderId: _startingOrderId,
            onOpen: _openOrder,
            onStart: _startPacking,
          );
        },
      ),
    );
  }
}

/// One card per order, due soonest first.
class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.orders,
    required this.startingOrderId,
    required this.onOpen,
    required this.onStart,
  });

  final List<Order> orders;
  final String? startingOrderId;
  final void Function(Order order) onOpen;
  final void Function(Order order) onStart;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      itemCount: orders.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final order = orders[index];
        final isPending = order.status == OrderStatus.pending;
        return PackingTaskCard(
          order: order,
          isStarting: startingOrderId == order.id,
          // Pending: start packing (then open). Packing: just open.
          // Disabled while another order is starting.
          onTap: startingOrderId != null
              ? null
              : () => isPending ? onStart(order) : onOpen(order),
        );
      },
    );
  }
}
