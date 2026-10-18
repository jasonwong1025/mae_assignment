import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

final StreamNotifierProvider<DeliveryTasksViewModel, DeliveryGroups>
deliveryTasksViewModelProvider =
    StreamNotifierProvider.autoDispose<DeliveryTasksViewModel, DeliveryGroups>(
      DeliveryTasksViewModel.new,
    );

/// The driver's deliveries, split into the sections of My Deliveries.
class DeliveryGroups {
  const DeliveryGroups({
    this.outForDelivery = const [],
    this.readyToCollect = const [],
    this.beingPacked = const [],
  });

  /// From the repository's list. Only active deliveries: completed ones
  /// are in My history (Account), and cancelled ones are left out.
  /// Each section puts the most urgent (earliest due) first. Ready to
  /// collect also keeps each branch's orders together, so the driver
  /// collects everything at one store in one trip.
  factory DeliveryGroups.from(List<WorkerOrder> orders) {
    return DeliveryGroups(
      outForDelivery: _byDue([
        for (final order in orders)
          if (order.status == OrderStatus.outForDelivery) order,
      ]),
      readyToCollect: _byBranchThenDue([
        for (final order in orders)
          if (order.status == OrderStatus.ready) order,
      ]),
      beingPacked: _byDue([
        for (final order in orders)
          if (order.status == OrderStatus.pending ||
              order.status == OrderStatus.packing)
            order,
      ]),
    );
  }

  /// Earliest due first; orders with no due time go last. Stable, so ties
  /// keep the repository's order.
  static List<WorkerOrder> _byDue(List<WorkerOrder> orders) {
    final indexed = orders.indexed.toList()
      ..sort((a, b) {
        final byDue = _compareDue(a.$2, b.$2);
        return byDue != 0 ? byDue : a.$1.compareTo(b.$1);
      });
    return [for (final (_, order) in indexed) order];
  }

  /// Branches in the order of their most urgent order, then by due time
  /// within each branch.
  static List<WorkerOrder> _byBranchThenDue(List<WorkerOrder> orders) {
    final sorted = _byDue(orders);
    final byBranch = <String, List<WorkerOrder>>{};
    for (final order in sorted) {
      byBranch.putIfAbsent(order.branchId, () => []).add(order);
    }
    return [for (final group in byBranch.values) ...group];
  }

  static int _compareDue(WorkerOrder a, WorkerOrder b) {
    final dueA = a.dueAt;
    final dueB = b.dueAt;
    if (dueA == null && dueB == null) return 0;
    if (dueA == null) return 1;
    if (dueB == null) return -1;
    return dueA.compareTo(dueB);
  }

  /// On the way now; the driver's current job.
  final List<WorkerOrder> outForDelivery;

  /// Packed and waiting at the branch for this driver.
  final List<WorkerOrder> readyToCollect;

  /// Assigned but still being packed; visible, but cannot be collected yet.
  final List<WorkerOrder> beingPacked;

  bool get isEmpty =>
      outForDelivery.isEmpty && readyToCollect.isEmpty && beingPacked.isEmpty;
}

/// State for My Deliveries: the signed-in driver's assigned deliveries
/// across branches, grouped by stage. Updates whenever any of them changes,
/// such as when a packer marks one ready.
class DeliveryTasksViewModel extends StreamNotifier<DeliveryGroups> {
  @override
  Stream<DeliveryGroups> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const DeliveryGroups();
      return;
    }
    final repository = ref.watch(workerOrdersRepositoryProvider);
    yield* repository.watchMyDeliveries(worker).map(DeliveryGroups.from);
  }
}
