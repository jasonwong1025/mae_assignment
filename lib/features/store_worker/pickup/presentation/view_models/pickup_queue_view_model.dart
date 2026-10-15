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

final pickupWaitingForDriversViewModelProvider =
    StreamNotifierProvider.autoDispose<
      PickupWaitingForDriversViewModel,
      List<WorkerOrder>
    >(PickupWaitingForDriversViewModel.new);

/// State for "Waiting for drivers": delivery bags at the packer's branch
/// that are ready but not yet collected (verified) by their driver.
class PickupWaitingForDriversViewModel
    extends StreamNotifier<List<WorkerOrder>> {
  @override
  Stream<List<WorkerOrder>> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const [];
      return;
    }
    yield* ref
        .watch(workerOrdersRepositoryProvider)
        .watchWaitingForDrivers(worker);
  }
}
