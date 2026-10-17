// cloud_firestore exports its own `Order` type (used in query ordering),
// which clashes with the app's order model; hide it so `Order` means ours.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/order.dart';

final Provider<OrderService> orderServiceProvider = Provider<OrderService>((
  ref,
) {
  return OrderService(FirebaseFirestore.instance);
});

/// Reads and writes the shared "orders" collection in Firestore.
///
/// The customer app creates orders here at checkout and watches its own
/// orders for live tracking; the Store Worker and Store Admin apps read
/// the same documents. Writes are plain client writes, allowed by
/// `firestore.rules` (a customer may create and read their own orders).
class OrderService {
  OrderService(this._firestore);

  final FirebaseFirestore _firestore;

  /// How long to wait for a Firestore read before giving up. Without this,
  /// `get()` retries forever when the backend is unreachable.
  static const Duration _timeout = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _orders {
    return _firestore.collection(FirestoreCollections.orders);
  }

  /// Creates [order] with a fresh document id and returns that id. The
  /// server sets placedAt/statusSince, so the stored times are authoritative.
  Future<String> createOrder(Order order) async {
    final doc = _orders.doc();
    await doc.set(order.toCreateMap());
    return doc.id;
  }

  /// The highest order number in use, or 0 if there are no orders. The next
  /// order's number is this plus one. Orders are few in this app, so a
  /// single-document lookup by `number` descending is enough.
  Future<int> highestOrderNumber() async {
    final snapshot = await _orders
        .orderBy(OrderFields.number, descending: true)
        .limit(1)
        .get()
        .timeout(_timeout);
    if (snapshot.docs.isEmpty) return 0;
    final value = snapshot.docs.first.data()[OrderFields.number];
    return value is num ? value.toInt() : 0;
  }

  /// One order by id, or null if it does not exist.
  Future<Order?> getOrder(String id) async {
    final doc = await _orders.doc(id).get().timeout(_timeout);
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return Order.fromFirestore(doc.id, data);
  }

  /// Live stream of one customer's orders, newest first. Emits on every
  /// change (status updates from workers show up without a refresh).
  Stream<List<Order>> watchCustomerOrders(String customerId) {
    return _orders
        .where(OrderFields.customerId, isEqualTo: customerId)
        .orderBy(OrderFields.placedAt, descending: true)
        .snapshots()
        .map((snapshot) {
          return [
            for (final doc in snapshot.docs)
              ?Order.fromFirestore(doc.id, doc.data()),
          ];
        });
  }

  /// Live stream of one order by id, or null if it is deleted/missing.
  Stream<Order?> watchOrder(String id) {
    return _orders.doc(id).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return Order.fromFirestore(doc.id, data);
    });
  }
}
