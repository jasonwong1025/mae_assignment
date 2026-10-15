import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/models/order_status.dart';
import '../../../orders/data/models/worker_order.dart';
import '../../../orders/data/repositories/worker_orders_repository.dart';
import '../../../session/presentation/view_models/worker_session_view_model.dart';

final deliveryTasksViewModelProvider =
    StreamNotifierProvider.autoDispose<DeliveryTasksViewModel, DeliveryGroups>(
      DeliveryTasksViewModel.new,
    );

/// The driver's deliveries, split into the sections of My Deliveries.
class DeliveryGroups {
  const DeliveryGroups({
    this.outForDelivery = const [],
    this.readyToCollect = const [],
    this.beingPacked = const [],
    this.completedToday = const [],
  });

  /// From the repository's list (already sorted by stage, then by when it
  /// was assigned). Cancelled orders and deliveries finished before today
  /// are left out.
  factory DeliveryGroups.from(List<WorkerOrder> orders, DateTime now) {
    return DeliveryGroups(
      outForDelivery: [
        for (final order in orders)
          if (order.status == OrderStatus.outForDelivery) order,
      ],
      readyToCollect: [
        for (final order in orders)
          if (order.status == OrderStatus.ready) order,
      ],
      beingPacked: [
        for (final order in orders)
          if (order.status == OrderStatus.pending ||
              order.status == OrderStatus.packing)
            order,
      ],
      completedToday: [
        for (final order in orders)
          if (order.status == OrderStatus.completed &&
              DateUtils.isSameDay(order.completedAt, now))
            order,
      ],
    );
  }

  /// On the way now; the driver's current job.
  final List<WorkerOrder> outForDelivery;

  /// Packed and waiting at the branch for this driver.
  final List<WorkerOrder> readyToCollect;

  /// Assigned but still being packed; visible, but cannot be collected yet.
  final List<WorkerOrder> beingPacked;
  final List<WorkerOrder> completedToday;

  bool get isEmpty =>
      outForDelivery.isEmpty &&
      readyToCollect.isEmpty &&
      beingPacked.isEmpty &&
      completedToday.isEmpty;
}

/// State for My Deliveries: the signed-in driver's deliveries at their
/// branch, grouped by stage. Updates whenever any of them changes, e.g.
/// when a packer marks one ready.
class DeliveryTasksViewModel extends StreamNotifier<DeliveryGroups> {
  @override
  Stream<DeliveryGroups> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const DeliveryGroups();
      return;
    }
    final repository = ref.watch(workerOrdersRepositoryProvider);
    yield* repository
        .watchMyDeliveries(worker)
        .map((orders) => DeliveryGroups.from(orders, DateTime.now()));
  }
}
