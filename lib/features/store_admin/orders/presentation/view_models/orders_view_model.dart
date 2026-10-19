import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/orders/data/repositories/orders_repository.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/shared/models/order.dart';

final StreamNotifierProvider<OrdersViewModel, List<Order>>
ordersViewModelProvider =
    StreamNotifierProvider.autoDispose<OrdersViewModel, List<Order>>(
      OrdersViewModel.new,
    );

/// State for the orders board: the selected branch's orders in progress and
/// completed today.
/// - AsyncLoading: waiting for the first list
/// - AsyncData: the latest list; replaced every time an order changes
/// - AsyncError: loading failed
class OrdersViewModel extends StreamNotifier<List<Order>> {
  @override
  Stream<List<Order>> build() async* {
    // Watching the branch means this starts again, with the new branch,
    // every time the admin switches.
    // Read before the first await: the provider can be disposed while it
    // waits (for example on sign-out), and a disposed ref cannot be used.
    final repository = ref.watch(ordersRepositoryProvider);
    final branchState = await ref.watch(branchViewModelProvider.future);

    // Pass on every list the repository sends.
    yield* repository.watchBoardOrders(branchState.selected.id);
  }

  /// Gives [order] to [packer]. Returns an error message, or null if it
  /// worked.
  Future<String?> assignPacker(Order order, Worker packer) async {
    try {
      await ref.read(ordersRepositoryProvider).assignPacker(order, packer);
    } on OrdersException catch (error) {
      return error.message;
    }
    return null;
  }
}

/// The active packers of one branch, for the "Assign packer" list.
final packersProvider = FutureProvider.autoDispose.family<List<Worker>, String>(
  (ref, branchId) => ref.watch(ordersRepositoryProvider).getPackers(branchId),
);
