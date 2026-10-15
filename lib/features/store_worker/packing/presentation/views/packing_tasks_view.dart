import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/app_router.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../shared/models/order_status.dart';
import '../../../../../shared/ui/empty_state.dart';
import '../../../orders/data/models/worker_order.dart';
import '../../../shell/presentation/ui/worker_scaffold.dart';
import '../../../shell/worker_routes.dart';
import '../ui/packing_task_card.dart';
import '../view_models/packing_tasks_view_model.dart';

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

  void _openOrder(WorkerOrder order) {
    context.push(AppRoutes.workerPackingOrder(order.id));
  }

  Future<void> _startPacking(WorkerOrder order) async {
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

/// Summary line, the "Up next" card, then the other orders.
class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.orders,
    required this.startingOrderId,
    required this.onOpen,
    required this.onStart,
  });

  final List<WorkerOrder> orders;
  final String? startingOrderId;
  final void Function(WorkerOrder order) onOpen;
  final void Function(WorkerOrder order) onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final packingCount = orders
        .where((order) => order.status == OrderStatus.packing)
        .length;
    final toStartCount = orders.length - packingCount;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.l),
      // Summary + one card per order.
      itemCount: orders.length + 1,
      separatorBuilder: (context, index) {
        // A heading between "Up next" and the rest.
        if (index == 1 && orders.length > 1) {
          return Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.l,
              bottom: AppSpacing.s,
            ),
            child: Text(
              'ALSO ASSIGNED TO YOU',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          );
        }
        return const SizedBox(height: AppSpacing.m);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            '$packingCount being packed · $toStartCount to start',
            style: textTheme.bodyMedium,
          );
        }
        final order = orders[index - 1];
        final isStarting = startingOrderId == order.id;
        return PackingTaskCard(
          order: order,
          isNext: index == 1,
          isStarting: isStarting,
          onOpen: () => onOpen(order),
          // Only one order can be starting at a time.
          onStart: startingOrderId == null ? () => onStart(order) : null,
        );
      },
    );
  }
}
