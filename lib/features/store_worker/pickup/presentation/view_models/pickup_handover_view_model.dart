import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';

/// One provider per order id.
final pickupHandoverViewModelProvider = StreamNotifierProvider.autoDispose
    .family<PickupHandoverViewModel, Order?, String>(
      PickupHandoverViewModel.new,
    );

/// State for the handover screen of one pickup order.
/// - AsyncLoading: waiting for the order
/// - AsyncData(order): the latest version; changes made by other packers
///   (e.g. handing it over first) show up here straight away
/// - AsyncData(null): the order does not exist or this packer may no
///   longer see it (e.g. another packer handed it over)
/// - AsyncError: loading failed
class PickupHandoverViewModel extends StreamNotifier<Order?> {
  PickupHandoverViewModel(this.orderId);

  final String orderId;

  @override
  Stream<Order?> build() async* {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) {
      yield null;
      return;
    }
    yield* ref
        .watch(workerOrdersRepositoryProvider)
        .watchOrder(worker, orderId);
  }

  /// Hands the order to the customer, checked by [method] ([code] is the
  /// scanned QR text for [VerificationMethod.qr]). Returns an error message
  /// (e.g. someone else already handed it over), or null if it worked.
  Future<String?> completePickup({
    required VerificationMethod method,
    String? code,
  }) async {
    final worker = ref.read(workerSessionProvider);
    if (worker == null) return 'Choose a worker first.';
    try {
      await ref
          .read(workerOrdersRepositoryProvider)
          .completePickup(worker, orderId, method: method, code: code);
      return null;
    } on WorkerOrderException catch (e) {
      return e.message;
    }
  }
}
