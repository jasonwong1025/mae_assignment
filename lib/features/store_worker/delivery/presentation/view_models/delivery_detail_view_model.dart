import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';

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

  /// Checks the collection code the driver typed from the bag label.
  Future<String?> verifyByCode(String typedCode) {
    return _run((repository, worker) {
      return repository.verifyCollection(
        worker,
        orderId,
        method: VerificationMethod.manual,
        code: typedCode,
      );
    });
  }

  /// Checks the QR code the driver scanned from the bag label.
  Future<String?> verifyByQr(String scannedCode) {
    return _run((repository, worker) {
      return repository.verifyCollection(
        worker,
        orderId,
        method: VerificationMethod.qr,
        code: scannedCode,
      );
    });
  }

  Future<String?> startDelivery() {
    return _run((repository, worker) {
      return repository.startDelivery(worker, orderId);
    });
  }

  Future<String?> completeDelivery({required Uint8List photo}) {
    return _run((repository, worker) {
      return repository.completeDelivery(worker, orderId, photo: photo);
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
