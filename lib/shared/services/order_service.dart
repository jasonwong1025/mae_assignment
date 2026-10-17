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

  /// Reserves and returns the next order number, atomically, from the
  /// shared counters/orders document.
  ///
  /// A customer cannot read other customers' orders (see `firestore.rules`),
  /// so the next number cannot come from scanning the orders collection.
  /// A transaction on a single counter is both allowed and race-safe:
  /// concurrent checkouts never get the same number. The first order starts
  /// at 1001 so numbers look like real order ids.
  Future<int> nextOrderNumber() {
    final counter = _firestore
        .collection(FirestoreCollections.counters)
        .doc(CounterDocs.orders);
    return _firestore
        .runTransaction((transaction) async {
          final snapshot = await transaction.get(counter);
          final current = snapshot.exists
              ? (snapshot.data()?[CounterFields.value] as num?)?.toInt() ?? 1000
              : 1000;
          final next = current + 1;
          transaction.set(counter, {CounterFields.value: next});
          return next;
        })
        .timeout(_timeout);
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
