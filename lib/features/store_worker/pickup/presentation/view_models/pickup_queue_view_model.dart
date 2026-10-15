import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/data/models/worker_order.dart';
import '../../../orders/data/repositories/worker_orders_repository.dart';
import '../../../session/presentation/view_models/worker_session_view_model.dart';

final pickupQueueViewModelProvider =
    StreamNotifierProvider.autoDispose<PickupQueueViewModel, List<WorkerOrder>>(
      PickupQueueViewModel.new,
    );

/// State for Ready for Pickup: every ready self-pickup order at the
/// packer's branch, whoever packed it, ready the longest first.
/// - AsyncLoading: waiting for the first list
/// - AsyncData: the latest list; replaced on every change
/// - AsyncError: loading failed
class PickupQueueViewModel extends StreamNotifier<List<WorkerOrder>> {
  @override
  Stream<List<WorkerOrder>> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const [];
      return;
    }
    yield* ref.watch(workerOrdersRepositoryProvider).watchReadyForPickup(worker);
  }
}

final pickupHandoversViewModelProvider =
    StreamNotifierProvider.autoDispose<
      PickupHandoversViewModel,
      List<WorkerOrder>
    >(PickupHandoversViewModel.new);

/// State for "Handed over by you today": pickups the signed-in packer
/// completed today, newest first.
class PickupHandoversViewModel extends StreamNotifier<List<WorkerOrder>> {
  @override
  Stream<List<WorkerOrder>> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const [];
      return;
    }
    final repository = ref.watch(workerOrdersRepositoryProvider);
    yield* repository.watchMyCompletedPickups(worker).map(_today);
  }

  /// Only orders completed on today's date.
  static List<WorkerOrder> _today(List<WorkerOrder> orders) {
    final now = DateTime.now();
    return orders
        .where((order) => DateUtils.isSameDay(order.completedAt, now))
        .toList();
  }
}
