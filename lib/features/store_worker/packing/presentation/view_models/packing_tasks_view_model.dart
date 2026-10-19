import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';

final packingTasksViewModelProvider =
    StreamNotifierProvider.autoDispose<PackingTasksViewModel, List<Order>>(
      PackingTasksViewModel.new,
    );

/// State for My Tasks: the orders the signed-in packer has to pack.
/// - AsyncLoading: waiting for the first list
/// - AsyncData: the latest list, next order first; replaced on every change
/// - AsyncError: loading failed
class PackingTasksViewModel extends StreamNotifier<List<Order>> {
  @override
  Stream<List<Order>> build() async* {
    // Watching the session means this starts again for a new worker.
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const [];
      return;
    }
    yield* ref
        .watch(workerOrdersRepositoryProvider)
        .watchMyPackingTasks(worker);
  }

  /// Starts packing [orderId]. Returns an error message, or null if it
  /// worked. The list updates by itself.
  Future<String?> startPacking(String orderId) async {
    final worker = ref.read(workerSessionProvider);
    if (worker == null) return 'Choose a worker first.';
    try {
      await ref
          .read(workerOrdersRepositoryProvider)
          .startPacking(worker, orderId);
      return null;
    } on WorkerOrderException catch (e) {
      return e.message;
    }
  }
}
