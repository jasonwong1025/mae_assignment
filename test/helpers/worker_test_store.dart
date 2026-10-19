import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/orders/data/services/delivery_proof_service.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import 'worker_test_orders.dart';

/// Stand-in for the Storage upload: remembers the photo and returns a URL.
class FakeDeliveryProofService extends Fake implements DeliveryProofService {
  /// The photo uploaded for each order id.
  final Map<String, Uint8List> uploads = {};

  @override
  Future<String> upload(String orderId, Uint8List photo) async {
    uploads[orderId] = photo;
    return 'https://fake.test/proof/$orderId.jpg';
  }
}

/// Writes [orders] to the `orders` collection the way the apps do: the
/// order's own fields, plus the server-managed placedAt and statusSince.
Future<void> putOrders(
  FakeFirebaseFirestore firestore,
  Iterable<Order> orders,
) async {
  for (final order in orders) {
    await putOrder(firestore, order);
  }
}

Future<void> putOrder(FakeFirebaseFirestore firestore, Order order) {
  final fallback = Timestamp.fromDate(DateTime(2026));
  return firestore.collection('orders').doc(order.id).set({
    ...order.toFirestore(),
    'placedAt': order.placedAt == null
        ? fallback
        : Timestamp.fromDate(order.placedAt!),
    'statusSince': order.statusSince == null
        ? fallback
        : Timestamp.fromDate(order.statusSince!),
  });
}

/// An in-memory Firestore with orders in it, and the Store Worker
/// repository on top, so worker tests run the real data layer with no
/// emulator.
class WorkerTestStore {
  WorkerTestStore._(this.firestore, this.repository, this.proofs, this.service);

  final FakeFirebaseFirestore firestore;
  final WorkerOrdersRepository repository;
  final FakeDeliveryProofService proofs;
  final OrderService service;

  /// Creates the store. [seed] builds the starting orders from the clock's
  /// time (default: the standard test orders); [clock] is the time workers'
  /// actions are stamped with.
  static Future<WorkerTestStore> create({
    DateTime Function()? clock,
    List<Order> Function(DateTime now)? seed,
    Duration delay = Duration.zero,
  }) async {
    final now = (clock ?? DateTime.now)();
    final firestore = FakeFirebaseFirestore();
    await putOrders(firestore, (seed ?? workerTestOrders)(now));
    final service = OrderService(firestore);
    final proofs = FakeDeliveryProofService();
    final repository = WorkerOrdersRepository(
      service,
      proofs,
      clock: clock,
      actionDelay: delay,
    );
    return WorkerTestStore._(firestore, repository, proofs, service);
  }

  /// One order as saved in the database, or null.
  Future<Order?> read(String id) => service.getOrder(id);
}
