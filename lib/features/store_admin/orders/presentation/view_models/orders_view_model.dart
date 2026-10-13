import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/order.dart';
import '../../data/repositories/orders_repository.dart';

final ordersViewModelProvider =
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
