import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/repositories/order_repository.dart';

/// Live stream of the signed-in customer's orders, newest first. Emits a
/// new list whenever an order changes (so a worker's status update shows up
/// without a manual refresh). Empty while nobody is signed in.
///
/// retry is disabled: a query error (e.g. a missing index, or offline)
/// should settle into the error state so the screen shows "Try again",
/// instead of Riverpod retrying forever and the screen spinning.
final StreamProvider<List<Order>> customerOrdersProvider =
    StreamProvider.autoDispose<List<Order>>((ref) async* {
      final user = await ref.watch(currentUserProvider.future);
      if (user == null) {
        yield const [];
        return;
      }
      yield* ref.watch(orderRepositoryProvider).watchCustomerOrders(user.uid);
    }, retry: (_, _) => null);

/// Live stream of one order by id, for the tracking screen.
final customerOrderProvider = StreamProvider.autoDispose.family<Order?, String>(
  (ref, orderId) {
    return ref.watch(orderRepositoryProvider).watchOrder(orderId);
  },
  retry: (_, _) => null,
);
