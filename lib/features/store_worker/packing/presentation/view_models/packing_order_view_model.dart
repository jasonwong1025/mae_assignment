import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/orders/data/worker_order_policy.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// One provider per order id.
final packingOrderViewModelProvider = StreamNotifierProvider.autoDispose
    .family<PackingOrderViewModel, Order?, String>(PackingOrderViewModel.new);

/// State for the packing screen of one order.
/// - AsyncLoading: waiting for the order
/// - AsyncData(order): the latest version, replaced on every change (also
///   changes made elsewhere, e.g. on My Tasks)
/// - AsyncData(null): the order does not exist or is not this packer's
///   task (e.g. reassigned, or another packer's order in Ready for Pickup)
/// - AsyncError: loading failed
///
/// Actions return an error message to show, or null if they worked.
class PackingOrderViewModel extends StreamNotifier<Order?> {
  PackingOrderViewModel(this.orderId);

  final String orderId;

  @override
  Stream<Order?> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield null;
      return;
    }
    // watchOrder also returns orders the packer may only see in Ready for
    // Pickup (e.g. one a colleague packed). The packing screen is only for
    // the packer's own tasks, so anything else counts as not available.
    yield* ref
        .watch(workerOrdersRepositoryProvider)
        .watchOrder(worker, orderId)
        .map((order) {
          if (order == null) return null;
          return WorkerOrderPolicy.canViewPackingTask(worker, order)
              ? order
              : null;
        });
  }

  Future<String?> startPacking() {
    return _run((repository, worker) {
      return repository.startPacking(worker, orderId);
    });
  }

  /// Ticks ([packed] true) or unticks one line.
  Future<String?> setItemPacked(String lineId, {required bool packed}) {
    return _run((repository, worker) {
      return repository.setItemPacked(worker, orderId, lineId, packed: packed);
    });
  }

  Future<String?> markReady() {
    return _run((repository, worker) {
      return repository.markReady(worker, orderId);
    });
  }

  Future<String?> _run(
    Future<void> Function(
      WorkerOrdersRepository repository,
      WorkerProfile worker,
    )
    action,
  ) async {
    final worker = ref.read(workerSessionProvider);
    if (worker == null) return 'Choose a worker first.';
    try {
      await action(ref.read(workerOrdersRepositoryProvider), worker);
      return null;
    } on WorkerOrderException catch (e) {
      return e.message;
    }
  }
}
