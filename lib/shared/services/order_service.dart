// cloud_firestore exports its own `Order` type (used in query ordering),
// which clashes with the app's order model; hide it so `Order` means ours.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

final Provider<OrderService> orderServiceProvider = Provider<OrderService>((
  ref,
) {
  return OrderService(ref.watch(firebaseFirestoreProvider));
});

/// Reads and writes the shared "orders" collection in Firestore.
///
/// The customer app creates orders here at checkout and watches its own
/// orders for live tracking. The Store Worker and Store Admin order screens
/// currently use sample data. Writes are plain client writes, allowed by
/// `firestore.rules` (a customer may create and read their own orders).
class OrderService {
  OrderService(this._firestore) : _refs = FirestoreRefs(_firestore);

  final FirebaseFirestore _firestore;
  final FirestoreRefs _refs;

  /// Creates [order] with a fresh document id and returns that id. The
  /// server sets placedAt/statusSince, so the stored times are authoritative.
  Future<String> createOrder(Order order) async {
    final doc = _refs.orders.doc();
    await doc.set({
      ...order.toFirestore(),
      OrderFields.placedAt: FieldValue.serverTimestamp(),
      OrderFields.statusSince: FieldValue.serverTimestamp(),
    });
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
    final counter = _refs.counter(CounterDocs.orders);
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
        .timeout(FirestoreConfig.readTimeout);
  }

  /// Cancels the order if it is still pending, and returns whether it did.
  ///
  /// The check and the write happen in one transaction, so an order a packer
  /// has just started on is never cancelled from under them. `firestore.rules`
  /// enforces the same thing on the server.
  Future<bool> cancelOrder(String id) {
    final document = _refs.order(id);
    return _firestore
        .runTransaction((transaction) async {
          final snapshot = await transaction.get(document);
          final status = snapshot.data()?[OrderFields.status];
          if (!snapshot.exists || status != OrderStatus.pending.name) {
            return false;
          }
          transaction.update(document, {
            OrderFields.status: OrderStatus.cancelled.name,
            OrderFields.statusSince: FieldValue.serverTimestamp(),
          });
          return true;
        })
        .timeout(FirestoreConfig.readTimeout);
  }

  /// One order by id, or null if it does not exist.
  Future<Order?> getOrder(String id) async {
    final doc = await _refs
        .order(id)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return doc.toModel(fromFirestore: Order.fromFirestore);
  }

  /// Live stream of one customer's orders, newest first. Emits on every
  /// change (status updates from workers show up without a refresh).
  Stream<List<Order>> watchCustomerOrders(String customerId) {
    return _refs.orders
        .where(OrderFields.customerId, isEqualTo: customerId)
        .orderBy(OrderFields.placedAt, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.toModels(fromFirestore: Order.fromFirestore),
        );
  }

  /// Live stream of one order by id, or null if it is deleted/missing.
  Stream<Order?> watchOrder(String id) {
    return _refs
        .order(id)
        .snapshots()
        .map((doc) => doc.toModel(fromFirestore: Order.fromFirestore));
  }
}
