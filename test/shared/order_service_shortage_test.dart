import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../helpers/worker_test_store.dart';

/// Shortages in OrderService: the packer flags a line, the customer answers,
/// and the admin can cancel an order that is waiting.
void main() {
  final placed = DateTime(2026, 10, 16, 12);

  const milk = OrderItem(
    lineId: 'L1',
    productId: 'p1',
    name: 'Milk',
    brand: 'Farm',
    packSize: '1L',
    quantity: 2,
    unitPrice: 5,
  );
  const eggs = OrderItem(
    lineId: 'L2',
    productId: 'p2',
    name: 'Eggs',
    brand: 'Farm',
    packSize: '10',
    quantity: 1,
    unitPrice: 8,
  );
  const otherEggs = OrderItem(
    lineId: 'ignored',
    productId: 'p9',
    name: 'Omega eggs',
    brand: 'Hen',
    packSize: '10',
    quantity: 1,
    unitPrice: 9,
  );

  Order order(
    String id, {
    OrderStatus status = OrderStatus.packing,
    Set<String> packed = const {},
    Map<String, LineShortage> shortages = const {},
  }) {
    return Order(
      id: id,
      number: int.parse(id.replaceAll(RegExp('[^0-9]'), '')),
      customerId: 'customer',
      customerName: 'Customer',
      customerPhone: '012',
      branchId: 'ss15',
      branchName: 'SS15',
      isDelivery: false,
      items: const [milk, eggs],
      subtotal: 18,
      deliveryFee: 0,
      discount: 0,
      total: 18,
      status: status,
      packedLineIds: packed,
      shortages: shortages,
      placedAt: placed,
      statusSince: placed,
    );
  }

  late FakeFirebaseFirestore firestore;
  late OrderService service;

  Future<Order> read(String id) async => (await service.getOrder(id))!;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    service = OrderService(firestore);
    await putOrders(firestore, [
      order('o1'),
      order('o2', status: OrderStatus.pending),
      order('o3', packed: {'L1'}),
      order(
        'o4',
        shortages: {
          'L2': const LineShortage(
            status: ShortageStatus.proposed,
            replacement: otherEggs,
          ),
        },
      ),
    ]);
    // putOrders does not write the rules-only counter, so set it like the
    // app does for a proposal that is already open.
    await firestore.collection('orders').doc('o4').update({'openShortages': 1});
  });

  group('flagShortage', () {
    test('a replacement waits for the customer', () async {
      final saved = await service.flagShortage(
        'o1',
        'L2',
        replacement: otherEggs,
      );

      expect(saved, isTrue);
      final stored = await read('o1');
      final shortage = stored.shortageOf('L2')!;
      expect(shortage.status, ShortageStatus.proposed);
      expect(shortage.replacement!.name, 'Omega eggs');
      // The replacement takes over the line it replaces.
      expect(shortage.replacement!.lineId, 'L2');
      expect(shortage.flaggedAt, isNotNull);
      expect(stored.hasOpenShortage, isTrue);
      final raw = await firestore.collection('orders').doc('o1').get();
      expect(raw.data()!['openShortages'], 1);
      expect(raw.data()!['shortageLineId'], 'L2');
    });

    test('no replacement removes the line at once', () async {
      final saved = await service.flagShortage('o1', 'L2');

      expect(saved, isTrue);
      final stored = await read('o1');
      expect(stored.isRemoved('L2'), isTrue);
      expect(stored.hasOpenShortage, isFalse);
      final raw = await firestore.collection('orders').doc('o1').get();
      expect(raw.data()!.containsKey('openShortages'), isFalse);
    });

    test('never changes the money the customer paid', () async {
      await service.flagShortage('o1', 'L2');

      final stored = await read('o1');
      expect(stored.total, 18);
      expect(stored.subtotal, 18);
      expect(stored.adjustedTotal, 10);
    });

    test('is refused unless the order is being packed', () async {
      expect(await service.flagShortage('o2', 'L2'), isFalse);
      expect((await read('o2')).shortages, isEmpty);
    });

    test('is refused for a line that is already ticked', () async {
      expect(await service.flagShortage('o3', 'L1'), isFalse);
      expect((await read('o3')).shortages, isEmpty);
    });

    test('is refused for a line that is already flagged', () async {
      expect(await service.flagShortage('o4', 'L2'), isFalse);
      expect(
        (await read('o4')).shortageOf('L2')!.status,
        ShortageStatus.proposed,
      );
    });

    test('is refused for an unknown line or order', () async {
      expect(await service.flagShortage('o1', 'L9'), isFalse);
      expect(await service.flagShortage('missing', 'L1'), isFalse);
    });

    test('two flags on different lines both count', () async {
      await service.flagShortage('o1', 'L1', replacement: otherEggs);
      await service.flagShortage('o1', 'L2', replacement: otherEggs);

      final raw = await firestore.collection('orders').doc('o1').get();
      expect(raw.data()!['openShortages'], 2);
      expect((await read('o1')).openShortageCount, 2);
    });
  });

  group('respondToShortage', () {
    test('accepting keeps the replacement and closes the proposal', () async {
      final saved = await service.respondToShortage('o4', 'L2', accept: true);

      expect(saved, isTrue);
      final stored = await read('o4');
      final shortage = stored.shortageOf('L2')!;
      expect(shortage.status, ShortageStatus.accepted);
      expect(shortage.replacement!.name, 'Omega eggs');
      expect(shortage.decidedAt, isNotNull);
      expect(stored.hasOpenShortage, isFalse);
      final raw = await firestore.collection('orders').doc('o4').get();
      expect(raw.data()!['openShortages'], 0);
      // 2 x 5 + 1 x 9
      expect(stored.adjustedTotal, 19);
    });

    test('declining removes the line', () async {
      final saved = await service.respondToShortage('o4', 'L2', accept: false);

      expect(saved, isTrue);
      final stored = await read('o4');
      expect(stored.isRemoved('L2'), isTrue);
      expect(stored.adjustedTotal, 10);
    });

    test('cannot be answered twice', () async {
      await service.respondToShortage('o4', 'L2', accept: true);

      expect(
        await service.respondToShortage('o4', 'L2', accept: false),
        isFalse,
      );
      expect(
        (await read('o4')).shortageOf('L2')!.status,
        ShortageStatus.accepted,
      );
    });

    test('has nothing to answer on an unflagged line', () async {
      expect(
        await service.respondToShortage('o1', 'L2', accept: true),
        isFalse,
      );
      expect(
        await service.respondToShortage('missing', 'L2', accept: true),
        isFalse,
      );
    });
  });

  group('cancelOrderAsAdmin', () {
    test('cancels an order waiting on the customer', () async {
      expect(await service.cancelOrderAsAdmin('o4'), isTrue);
      expect((await read('o4')).status, OrderStatus.cancelled);
    });

    test('cancels a pending order too', () async {
      expect(await service.cancelOrderAsAdmin('o2'), isTrue);
      expect((await read('o2')).status, OrderStatus.cancelled);
    });

    test('leaves a finished order alone', () async {
      await putOrders(firestore, [
        order('o8', status: OrderStatus.completed),
        order('o9', status: OrderStatus.cancelled),
      ]);

      expect(await service.cancelOrderAsAdmin('o8'), isFalse);
      expect(await service.cancelOrderAsAdmin('o9'), isFalse);
      expect((await read('o8')).status, OrderStatus.completed);
      expect(await service.cancelOrderAsAdmin('missing'), isFalse);
    });
  });
}
