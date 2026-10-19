import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';

final workerHistoryViewModelProvider =
    StreamNotifierProvider.autoDispose<WorkerHistoryViewModel, List<Order>>(
      WorkerHistoryViewModel.new,
    );

/// State for My history: what the signed-in worker finished, newest first.
/// Packing Staff see the orders they packed; Delivery Drivers see the
/// deliveries they completed.
class WorkerHistoryViewModel extends StreamNotifier<List<Order>> {
  @override
  Stream<List<Order>> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const [];
      return;
    }
    yield* ref.watch(workerOrdersRepositoryProvider).watchMyHistory(worker);
  }
}
