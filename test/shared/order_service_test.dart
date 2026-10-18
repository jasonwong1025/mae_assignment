import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

Order _order({
  required String customerId,
  required int number,
  OrderStatus status = OrderStatus.pending,
}) {
  return Order(
    id: '',
    number: number,
    customerId: customerId,
    customerName: 'Aisha',
    customerPhone: '0123456789',
    branchId: 'ss15',
    branchName: 'SS15 Subang',
    isDelivery: true,
    items: const [
      OrderItem(
        lineId: 'p1',
        productId: 'p1',
        name: 'Fresh milk',
        brand: 'Farm',
        packSize: '1L',
        quantity: 1,
        unitPrice: 8.9,
      ),
    ],
    subtotal: 8.9,
    deliveryFee: 3,
    discount: 0,
    total: 11.9,
    status: status,
    address: '12 Jalan Besar',
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late OrderService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = OrderService(firestore);
  });

  test('createOrder writes a document and returns its id', () async {
    final id = await service.createOrder(_order(customerId: 'u1', number: 1));

    final doc = await firestore
        .collection(FirestoreCollections.orders)
        .doc(id)
        .get();
    expect(doc.exists, isTrue);
    expect(doc.data()![OrderFields.customerId], 'u1');
    expect(doc.data()![OrderFields.number], 1);
    expect(doc.data()![OrderFields.status], 'pending');
  });

  test('nextOrderNumber starts at 1001 for the first order', () async {
    expect(await service.nextOrderNumber(), 1001);
  });

  test('nextOrderNumber increments on each call', () async {
    expect(await service.nextOrderNumber(), 1001);
    expect(await service.nextOrderNumber(), 1002);
    expect(await service.nextOrderNumber(), 1003);
  });

  test('getOrder reads back a created order', () async {
    final id = await service.createOrder(
      _order(customerId: 'u1', number: 7, status: OrderStatus.packing),
    );

    final order = await service.getOrder(id);
    expect(order, isNotNull);
    expect(order!.id, id);
    expect(order.number, 7);
    expect(order.status, OrderStatus.packing);
  });

  test('getOrder returns null for a missing id', () async {
    expect(await service.getOrder('nope'), isNull);
  });

  test("watchCustomerOrders returns only that customer's orders", () async {
    await service.createOrder(_order(customerId: 'u1', number: 1));
    await service.createOrder(_order(customerId: 'u2', number: 2));
    await service.createOrder(_order(customerId: 'u1', number: 3));

    final orders = await service.watchCustomerOrders('u1').first;
    expect(orders.map((o) => o.number), unorderedEquals([1, 3]));
    expect(orders.every((o) => o.customerId == 'u1'), isTrue);
  });

  test('watchOrder emits the latest version of one order', () async {
    final id = await service.createOrder(_order(customerId: 'u1', number: 1));

    final first = await service.watchOrder(id).first;
    expect(first!.status, OrderStatus.pending);

    // A worker advances the status; the stream should reflect it.
    await firestore.collection(FirestoreCollections.orders).doc(id).update({
      OrderFields.status: OrderStatus.packing.name,
    });

    final updated = await service
        .watchOrder(id)
        .firstWhere((o) => o?.status == OrderStatus.packing);
    expect(updated!.status, OrderStatus.packing);
  });

  group('cancelOrder', () {
    Future<Map<String, dynamic>> stored(String id) async {
      final doc = await firestore
          .collection(FirestoreCollections.orders)
          .doc(id)
          .get();
      return doc.data()!;
    }

    test('cancels a pending order and stamps the server time', () async {
      final id = await service.createOrder(_order(customerId: 'u1', number: 1));

      expect(await service.cancelOrder(id), isTrue);

      final data = await stored(id);
      expect(data[OrderFields.status], 'cancelled');
      expect(data.containsKey(OrderFields.statusSince), isTrue);
    });

    test('does not cancel an order that is already being packed', () async {
      final id = await service.createOrder(
        _order(customerId: 'u1', number: 1, status: OrderStatus.packing),
      );

      expect(await service.cancelOrder(id), isFalse);
      expect((await stored(id))[OrderFields.status], 'packing');
    });

    test('returns false for an order that does not exist', () async {
      expect(await service.cancelOrder('missing'), isFalse);
    });
  });
}
