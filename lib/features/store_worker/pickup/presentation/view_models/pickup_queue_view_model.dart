import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';

final StreamNotifierProvider<PickupQueueViewModel, List<Order>>
pickupQueueViewModelProvider =
    StreamNotifierProvider.autoDispose<PickupQueueViewModel, List<Order>>(
      PickupQueueViewModel.new,
    );

/// State for Ready for Pickup: every ready self-pickup order at the
/// packer's branch, whoever packed it, ready the longest first.
/// - AsyncLoading: waiting for the first list
/// - AsyncData: the latest list; replaced on every change
/// - AsyncError: loading failed
class PickupQueueViewModel extends StreamNotifier<List<Order>> {
  @override
  Stream<List<Order>> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const [];
      return;
    }
    yield* ref
        .watch(workerOrdersRepositoryProvider)
        .watchReadyForPickup(worker);
  }
}

final StreamNotifierProvider<PickupWaitingForDriversViewModel, List<Order>>
pickupWaitingForDriversViewModelProvider =
    StreamNotifierProvider.autoDispose<
      PickupWaitingForDriversViewModel,
      List<Order>
    >(PickupWaitingForDriversViewModel.new);

/// State for "Waiting for drivers": delivery bags at the packer's branch
/// that are ready but not yet collected (verified) by their driver.
class PickupWaitingForDriversViewModel extends StreamNotifier<List<Order>> {
  @override
  Stream<List<Order>> build() async* {
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
