// cloud_firestore exports its own `Order` type (used in query ordering),
// which clashes with the app's order model; hide it so `Order` means ours.
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
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

  /// The packer reports line [lineId] unavailable, and returns whether the
  /// flag was saved.
  ///
  /// With a [replacement] the shortage is `proposed` and waits for the
  /// customer; without one the line is `removed` at once. Nothing is saved
  /// (false) if the order is not being packed, the line does not exist, is
  /// already ticked or already flagged. Checked in the transaction, so two
  /// devices cannot flag the same line twice.
  ///
  /// Only the one line's entry is written (a dotted field path), together
  /// with `shortageLineId` and, for a proposal, `openShortages` + 1, which
  /// is what `firestore.rules` checks. Totals never change here: the
  /// adjusted total is worked out from the shortages when read.
  Future<bool> flagShortage(
    String orderId,
    String lineId, {
    OrderItem? replacement,
  }) {
    final document = _refs.order(orderId);
    return _firestore
        .runTransaction((transaction) async {
          final snapshot = await transaction.get(document);
          final order = snapshot.toModel(fromFirestore: Order.fromFirestore);
          if (order == null ||
              order.status != OrderStatus.packing ||
              !order.items.any((item) => item.lineId == lineId) ||
              order.packedLineIds.contains(lineId) ||
              order.shortageOf(lineId) != null) {
            return false;
          }
          final proposed = replacement != null;
          transaction.update(document, {
            FieldPath([OrderFields.shortages, lineId]): {
              ShortageFields.status: proposed
                  ? ShortageStatus.proposed.name
                  : ShortageStatus.removed.name,
              if (replacement != null)
                ShortageFields.replacement: replacement
                    .copyWith(lineId: lineId)
                    .toMap(),
              ShortageFields.flaggedAt: FieldValue.serverTimestamp(),
            },
            OrderFields.shortageLineId: lineId,
            if (proposed)
              OrderFields.openShortages: order.openShortageCount + 1,
          });
          return true;
        })
        .timeout(FirestoreConfig.readTimeout);
  }

  /// The customer answers the replacement offered for [lineId]: accepts it,
  /// or declines, which removes the line. Returns whether it was saved
  /// (false if there is no open proposal for the line any more).
  Future<bool> respondToShortage(
    String orderId,
    String lineId, {
    required bool accept,
  }) {
    final document = _refs.order(orderId);
    return _firestore
        .runTransaction((transaction) async {
          final snapshot = await transaction.get(document);
          final order = snapshot.toModel(fromFirestore: Order.fromFirestore);
          final shortage = order?.shortageOf(lineId);
          if (order == null ||
              order.status != OrderStatus.packing ||
              shortage == null ||
              shortage.status != ShortageStatus.proposed) {
            return false;
          }
          // Re-send the fields the rules require to stay as they were.
          final stored = snapshot.data()?[OrderFields.shortages];
          final entry = stored is Map ? stored[lineId] : null;
          if (entry is! Map) return false;
          transaction.update(document, {
            FieldPath([OrderFields.shortages, lineId]): {
              ...Map<String, dynamic>.from(entry),
              ShortageFields.status: accept
                  ? ShortageStatus.accepted.name
                  : ShortageStatus.removed.name,
              ShortageFields.decidedAt: FieldValue.serverTimestamp(),
            },
            OrderFields.shortageLineId: lineId,
            OrderFields.openShortages: order.openShortageCount - 1,
          });
          return true;
        })
        .timeout(FirestoreConfig.readTimeout);
  }

  /// Store Admin cancels an order that is not finished yet (typically one
  /// waiting too long for the customer's answer), and returns whether it
  /// did.
  Future<bool> cancelOrderAsAdmin(String id) {
    final document = _refs.order(id);
    return _firestore
        .runTransaction((transaction) async {
          final snapshot = await transaction.get(document);
          final status = snapshot.data()?[OrderFields.status];
          if (!snapshot.exists ||
              status == OrderStatus.completed.name ||
              status == OrderStatus.cancelled.name) {
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

  /// The driver reports where they are on the way to [orderId].
  ///
  /// One batch writes both places that show it: the order (so its customer,
  /// who may read only their own orders, can follow the delivery) and the
  /// driver's `driverLocations` document (the admin's Dispatch map). Both
  /// carry the server time. `firestore.rules` accepts the order write only
  /// from the assigned driver while the order is out for delivery.
  Future<void> updateDriverPosition(
    String orderId,
    String driverId,
    LatLng position,
  ) {
    final batch = _firestore.batch()
      ..update(_refs.order(orderId), {
        OrderFields.driverPosition: toGeoPoint(position),
        OrderFields.driverPositionAt: FieldValue.serverTimestamp(),
      })
      ..set(_refs.driverLocation(driverId), {
        DriverLocationFields.position: toGeoPoint(position),
        DriverLocationFields.updatedAt: FieldValue.serverTimestamp(),
      });
    return batch.commit().timeout(FirestoreConfig.readTimeout);
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
        // Newest first, to use the same branchId + placedAt (descending)
        // index as the branch watcher; reversed below.
        .orderBy(OrderFields.placedAt, descending: true)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return snapshot
        .toModels(fromFirestore: Order.fromFirestore)
        .reversed
        .toList();
  }

  /// Changes an order in one transaction and returns the new order, or null
  /// if it does not exist.
  ///
  /// [change] gets the order as it is now and returns the new version; it
  /// may throw to refuse the change, which cancels the write. Only the
  /// fields that differ are written, so a worker's update never touches the
  /// checkout fields and `firestore.rules` can check which group changed.
  ///
  /// Every workflow time that changed (`OrderFields.serverTimeKeys`) is saved
  /// as the server time, whatever time [change] put on the order: a phone
  /// with the wrong clock cannot distort the timeline, and `firestore.rules`
  /// refuses any other value. The returned order still carries the times
  /// [change] chose, so use a snapshot of the order for the saved times.
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
          // toFirestore; it changes together with the status.
          if (next.statusSince != current.statusSince ||
              changes.containsKey(OrderFields.status)) {
            changes[OrderFields.statusSince] = null;
          }
          for (final key in OrderFields.serverTimeKeys) {
            if (changes.containsKey(key)) {
              changes[key] = FieldValue.serverTimestamp();
            }
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
