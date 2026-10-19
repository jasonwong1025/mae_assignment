import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/orders/data/repositories/orders_repository.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';

final StreamNotifierProvider<OrdersViewModel, List<Order>>
ordersViewModelProvider =
    StreamNotifierProvider.autoDispose<OrdersViewModel, List<Order>>(
      OrdersViewModel.new,
    );

/// State for the orders board: today's orders for the selected branch.
/// - AsyncLoading: waiting for the first list
/// - AsyncData: the latest list; replaced every time an order changes
/// - AsyncError: loading failed
class OrdersViewModel extends StreamNotifier<List<Order>> {
  @override
  Stream<List<Order>> build() async* {
    // Watching the branch means this starts again, with the new branch,
    // every time the admin switches.
    final branchState = await ref.watch(branchViewModelProvider.future);
    final repository = ref.watch(ordersRepositoryProvider);

    // Pass on every list the repository sends.
    yield* repository.watchTodaysOrders(branchState.selected.id);
  }
}
