import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../sample_orders.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository();
});

/// Orders for the store admin.
///
/// The backend is not connected yet, so this returns sample data.
/// It is already a Stream (a value that can keep changing), so later only
/// the inside of this class changes (to listen to Firestore) and the board
/// then updates live with no changes to the screens.
class OrdersRepository {
  /// Today's orders for one branch. Sends a new list whenever any of
  /// them changes.
  Stream<List<Order>> watchTodaysOrders(String branchId) {
    return Stream.value(sampleOrdersFor(branchId, DateTime.now()));
  }
}
