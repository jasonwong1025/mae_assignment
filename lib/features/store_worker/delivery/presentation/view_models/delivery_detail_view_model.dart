import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/data/models/worker_order.dart';
import '../../../orders/data/repositories/worker_orders_repository.dart';
import '../../../session/data/models/worker_profile.dart';
import '../../../session/presentation/view_models/worker_session_view_model.dart';

/// One provider per order id.
final deliveryDetailViewModelProvider = StreamNotifierProvider.autoDispose
    .family<DeliveryDetailViewModel, WorkerOrder?, String>(
      DeliveryDetailViewModel.new,
    );

/// State for the delivery screen of one order.
/// - AsyncLoading: waiting for the order
/// - AsyncData(order): the latest version; a packer marking it ready shows
///   up here straight away
/// - AsyncData(null): the order does not exist or is not this driver's
///   (e.g. reassigned to another driver)
/// - AsyncError: loading failed
///
/// Actions return an error message to show, or null if they worked.
class DeliveryDetailViewModel extends StreamNotifier<WorkerOrder?> {
  DeliveryDetailViewModel(this.orderId);

  final String orderId;

  @override
  Stream<WorkerOrder?> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield null;
      return;
    }
    yield* ref
        .watch(workerOrdersRepositoryProvider)
        .watchOrder(worker, orderId);
  }

  /// Checks the order number the driver typed from the bag.
  Future<String?> verifyByNumber(String typedNumber) {
    return _run((repository, worker) {
      return repository.verifyCollection(
        worker,
        orderId,
        method: VerificationMethod.manual,
        code: typedNumber,
      );
    });
  }

  Future<String?> startDelivery() {
    return _run((repository, worker) {
      return repository.startDelivery(worker, orderId);
    });
  }

  Future<String?> completeDelivery() {
    return _run((repository, worker) {
      return repository.completeDelivery(worker, orderId);
    });
  }

  Future<String?> _run(
    Future<void> Function(WorkerOrdersRepository repository, WorkerProfile worker)
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
