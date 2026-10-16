import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';

final workerHistoryViewModelProvider =
    StreamNotifierProvider.autoDispose<
      WorkerHistoryViewModel,
      List<WorkerOrder>
    >(WorkerHistoryViewModel.new);

/// State for My history: what the signed-in worker finished, newest first.
/// Packing Staff see the orders they packed; Delivery Drivers see the
/// deliveries they completed.
class WorkerHistoryViewModel extends StreamNotifier<List<WorkerOrder>> {
  @override
  Stream<List<WorkerOrder>> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield const [];
      return;
    }
    yield* ref.watch(workerOrdersRepositoryProvider).watchMyHistory(worker);
  }
}
