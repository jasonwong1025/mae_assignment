// cloud_firestore exports its own `Order` type (used in query ordering),
// which clashes with the app's order model; hide it so `Order` means ours.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
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
/// orders for live tracking. Store Admin watches a branch's orders and
/// assigns packers and drivers; Store Workers watch the orders they may see
/// and record fulfilment. Writes are plain client writes, allowed by
/// `firestore.rules` (each role may write only its own group of fields, see
/// `OrderFields`).
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

  // ---------------------------------------------------------------------
  // Store Admin and Store Worker
  // ---------------------------------------------------------------------

  /// Live stream of a branch's most recent orders, newest first. Emits on
  /// every change, so every screen on the branch updates at once.
  ///
  /// Needs the composite index branchId + placedAt (firestore.indexes.json).
  Stream<List<Order>> watchBranchOrders(String branchId, {int limit = 200}) {
    return _refs.orders
        .where(OrderFields.branchId, isEqualTo: branchId)
        .orderBy(OrderFields.placedAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.toModels(fromFirestore: Order.fromFirestore),
        );
  }

  /// Live stream of the orders assigned to one driver, newest first.
  ///
  /// Needs the composite index driverId + placedAt (firestore.indexes.json).
  Stream<List<Order>> watchDriverOrders(String driverId, {int limit = 100}) {
    return _refs.orders
        .where(OrderFields.driverId, isEqualTo: driverId)
        .orderBy(OrderFields.placedAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.toModels(fromFirestore: Order.fromFirestore),
        );
  }

  /// Live stream of every delivery that is ready or on the road, for all
  /// branches, so Dispatch knows which drivers are busy.
  Stream<List<Order>> watchActiveDeliveries() {
    return _refs.orders
        .where(OrderFields.isDelivery, isEqualTo: true)
        .where(
          OrderFields.status,
          whereIn: [OrderStatus.ready.name, OrderStatus.outForDelivery.name],
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.toModels(fromFirestore: Order.fromFirestore),
        );
  }

  /// A branch's orders that are not finished yet (pending, packing, ready or
  /// on the road), whenever they were placed.
  Future<List<Order>> getActiveBranchOrders(String branchId) async {
    final snapshot = await _refs.orders
        .where(OrderFields.branchId, isEqualTo: branchId)
        .where(
          OrderFields.status,
          whereIn: [
            OrderStatus.pending.name,
            OrderStatus.packing.name,
            OrderStatus.ready.name,
            OrderStatus.outForDelivery.name,
          ],
        )
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return snapshot.toModels(fromFirestore: Order.fromFirestore);
  }

  /// A branch's orders placed from [start] up to (not including) [end],
  /// oldest first. Used by Sales and the dashboard.
  Future<List<Order>> getBranchOrdersBetween(
    String branchId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _refs.orders
        .where(OrderFields.branchId, isEqualTo: branchId)
        .where(OrderFields.placedAt, isGreaterThanOrEqualTo: toTimestamp(start))
        .where(OrderFields.placedAt, isLessThan: toTimestamp(end))
        .orderBy(OrderFields.placedAt)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return snapshot.toModels(fromFirestore: Order.fromFirestore);
  }

  /// Changes an order in one transaction and returns the saved order, or
  /// null if it does not exist.
  ///
  /// [change] gets the order as it is now and returns the new version; it
  /// may throw to refuse the change, which cancels the write. Only the
  /// fields that differ are written, so a worker's update never touches the
  /// checkout fields and `firestore.rules` can check which group changed.
  Future<Order?> updateOrder(String id, Order Function(Order current) change) {
    final document = _refs.order(id);
    return _firestore
        .runTransaction((transaction) async {
          final snapshot = await transaction.get(document);
          final current = snapshot.toModel(fromFirestore: Order.fromFirestore);
          if (current == null) return null;

          final next = change(current);
          final before = current.toFirestore();
          final after = next.toFirestore();
          final changes = <String, dynamic>{
            for (final entry in after.entries)
              if (!_sameValue(before[entry.key], entry.value))
                entry.key: entry.value,
          };
          // statusSince is a server-managed field, so it is not part of
          // toFirestore; write it when it changed.
          if (next.statusSince != current.statusSince &&
              next.statusSince != null) {
            changes[OrderFields.statusSince] = toTimestamp(next.statusSince!);
          }
          if (changes.isNotEmpty) transaction.update(document, changes);
          return next;
        })
        .timeout(FirestoreConfig.readTimeout);
  }

  /// Assigns (or changes) the packer. Store Admin only.
  Future<void> assignPacker(
    String id, {
    required String packerId,
    required String packerName,
  }) {
    return _refs.order(id).update({
      OrderFields.packerId: packerId,
      OrderFields.packerName: packerName,
      OrderFields.packerAssignedAt: FieldValue.serverTimestamp(),
    });
  }

  /// Assigns (or changes) the driver. Store Admin only.
  Future<void> assignDriver(
    String id, {
    required String driverId,
    required String driverName,
  }) {
    return _refs.order(id).update({
      OrderFields.driverId: driverId,
      OrderFields.driverName: driverName,
      OrderFields.driverAssignedAt: FieldValue.serverTimestamp(),
    });
  }

  static bool _sameValue(Object? a, Object? b) {
    if (a is List && b is List) return listEquals(a, b);
    return a == b;
  }
}
