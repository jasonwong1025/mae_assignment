import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../sample_orders.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final repository = OrdersRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

/// Orders for the store admin.
///
/// The backend is not connected yet, so this keeps sample orders in memory.
/// It is already a Stream (a value that can keep changing), so later only
/// the inside of this class changes (to listen to Firestore) and the board
/// then updates live with no changes to the screens.
class OrdersRepository {
  /// Orders of each branch, by branch id. Made on first use.
  final Map<String, List<Order>> _orders = {};

  /// Sends the id of a branch whose orders changed.
  final _changes = StreamController<String>.broadcast();

  /// Today's orders for one branch. Sends a new list whenever any of
  /// them changes.
  Stream<List<Order>> watchTodaysOrders(String branchId) async* {
    yield List.unmodifiable(_ordersOf(branchId));
    await for (final changedId in _changes.stream) {
      if (changedId == branchId) yield List.unmodifiable(_ordersOf(branchId));
    }
  }

  /// Replaces the order that has the same number.
  Future<void> updateOrder(String branchId, Order order) async {
    final orders = _ordersOf(branchId);
    final index = orders.indexWhere((old) => old.number == order.number);
    if (index == -1) return;

    orders[index] = order;
    _changes.add(branchId);
  }

  List<Order> _ordersOf(String branchId) {
    return _orders.putIfAbsent(
      branchId,
      () => sampleOrdersFor(branchId, DateTime.now()),
    );
  }

  void dispose() => _changes.close();
}
