import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(
    ref.watch(orderServiceProvider),
    ref.watch(staffServiceProvider),
  );
});

/// Error with a message to show on screen.
class OrdersException extends AppException {
  const OrdersException(super.message);
}

/// Orders for the store admin, read live from the shared `orders`
/// collection, so the board updates as customers and workers act.
class OrdersRepository {
  OrdersRepository(this._orders, this._staff, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final OrderService _orders;
  final StaffService _staff;
  final DateTime Function() _clock;

  /// The branch's orders for the board: everything still in progress, plus
  /// what was completed today. Cancelled orders are not shown. Sends a new
  /// list whenever any of them changes.
  Stream<List<Order>> watchBoardOrders(String branchId) {
    return _orders.watchBranchOrders(branchId).map((orders) {
      final clock = _clock();
      final today = DateTime(clock.year, clock.month, clock.day);
      return [
        for (final order in orders)
          if (order.status != OrderStatus.cancelled &&
              (!order.status.isFinished ||
                  !order.statusStartedAt.isBefore(today)))
            order,
      ];
    });
  }

  /// Active packers of [branchId], sorted by name.
  Future<List<Worker>> getPackers(String branchId) {
    return guard(
      () async {
        final workers = await _staff.getWorkers();
        return workers
            .where(
              (worker) =>
                  !worker.isDriver &&
                  worker.isActive &&
                  worker.branchId == branchId,
            )
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
      },
      label: 'packers',
      onError: () => const OrdersException(
        'Could not load the packers. Please try again.',
      ),
    );
  }

  /// Gives [order] to [packer], who then sees it in My Tasks.
  Future<void> assignPacker(Order order, Worker packer) {
    return guard(
      () => _orders.assignPacker(
        order.id,
        packerId: packer.id,
        packerName: packer.name,
      ),
      label: 'assign packer',
      onError: () => const OrdersException(
        'Could not assign the packer. Please try again.',
      ),
    );
  }
}
