import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

void main() {
  group('Order.toCreateMap', () {
    const order = Order(
      id: 'o1',
      number: 2301,
      customerId: 'u1',
      customerName: 'Aisha',
      customerPhone: '0123456789',
      branchId: 'ss15',
      branchName: 'SS15 Subang',
      isDelivery: true,
      items: [
        OrderItem(
          lineId: 'p-milk',
          productId: 'p-milk',
          name: 'Fresh milk',
          brand: 'Farm',
          packSize: '1L',
          quantity: 2,
          unitPrice: 8.9,
          imageUrl: 'https://img/milk.png',
        ),
      ],
      subtotal: 17.8,
      deliveryFee: 3,
      discount: 5,
      total: 15.8,
      status: OrderStatus.pending,
      address: '12 Jalan Besar',
      customerNote: 'Leave at the door',
      promoCode: 'FRESH5',
    );

    test('does not store the document id as a field', () {
      expect(order.toCreateMap().containsKey('id'), isFalse);
    });

    test('stores the status as the enum name', () {
      expect(order.toCreateMap()[OrderFields.status], 'pending');
    });

    test('uses server timestamps for placedAt and statusSince', () {
      final map = order.toCreateMap();
      expect(map[OrderFields.placedAt], isA<FieldValue>());
      expect(map[OrderFields.statusSince], isA<FieldValue>());
    });

    test('serialises each item under the items array', () {
      final items = order.toCreateMap()[OrderFields.items] as List;
      expect(items, hasLength(1));
      final item = items.first as Map<String, dynamic>;
      expect(item[OrderItemFields.productId], 'p-milk');
      expect(item[OrderItemFields.quantity], 2);
      expect(item[OrderItemFields.unitPrice], 8.9);
    });

    test('omits an empty address for pickup orders', () {
      final pickup = order.copyWith(isDelivery: false, address: null);
      expect(pickup.toCreateMap().containsKey(OrderFields.address), isFalse);
    });
  });

  group('Order.fromFirestore', () {
    Map<String, dynamic> validMap() {
      return {
        OrderFields.number: 2301,
        OrderFields.customerId: 'u1',
        OrderFields.customerName: 'Aisha',
        OrderFields.customerPhone: '0123456789',
        OrderFields.branchId: 'ss15',
        OrderFields.branchName: 'SS15 Subang',
        OrderFields.isDelivery: false,
        OrderFields.items: [
          {
            OrderItemFields.lineId: 'p-milk',
            OrderItemFields.productId: 'p-milk',
            OrderItemFields.name: 'Fresh milk',
            OrderItemFields.brand: 'Farm',
            OrderItemFields.packSize: '1L',
            OrderItemFields.quantity: 2,
            OrderItemFields.unitPrice: 8.9,
          },
        ],
        OrderFields.subtotal: 17.8,
        OrderFields.deliveryFee: 0,
        OrderFields.discount: 0,
        OrderFields.total: 17.8,
        OrderFields.status: 'packing',
      };
    }

    test('reads a well-formed document', () {
      final order = Order.fromFirestore('o1', validMap());
      expect(order, isNotNull);
      expect(order!.id, 'o1');
      expect(order.number, 2301);
      expect(order.status, OrderStatus.packing);
      expect(order.items.single.quantity, 2);
      expect(order.itemCount, 2);
      expect(order.isPickup, isTrue);
    });

    test('round-trips through toCreateMap for the non-timestamp fields', () {
      final order = Order.fromFirestore('o1', validMap())!;
      // Re-serialise and read back; the status and totals must survive.
      final map = order.toCreateMap()..['status'] = order.status.name;
      final again = Order.fromFirestore('o1', map)!;
      expect(again.number, order.number);
      expect(again.total, order.total);
      expect(again.status, order.status);
      expect(again.items.single.productId, 'p-milk');
    });

    test('returns null when the number is missing', () {
      final map = validMap()..remove(OrderFields.number);
      expect(Order.fromFirestore('o1', map), isNull);
    });

    test('returns null when the customer id is missing', () {
      final map = validMap()..remove(OrderFields.customerId);
      expect(Order.fromFirestore('o1', map), isNull);
    });

    test('falls back to pending for an unknown status', () {
      final map = validMap()..[OrderFields.status] = 'nonsense';
      expect(Order.fromFirestore('o1', map)!.status, OrderStatus.pending);
    });

    test('reads a Firestore Timestamp into placedAt', () {
      final when = DateTime(2026, 3, 12, 18, 48);
      final map = validMap()..[OrderFields.placedAt] = Timestamp.fromDate(when);
      expect(Order.fromFirestore('o1', map)!.placedAt, when);
    });
  });

  group('OrderItem', () {
    test('lineTotal multiplies unit price by quantity', () {
      const item = OrderItem(
        lineId: 'l1',
        productId: 'p1',
        name: 'Rice',
        brand: 'Jasmine',
        packSize: '5kg',
        quantity: 3,
        unitPrice: 20,
      );
      expect(item.lineTotal, 60);
    });

    test('omits an empty image url when serialising', () {
      const item = OrderItem(
        lineId: 'l1',
        productId: 'p1',
        name: 'Rice',
        brand: 'Jasmine',
        packSize: '5kg',
        quantity: 1,
        unitPrice: 20,
      );
      expect(item.toMap().containsKey(OrderItemFields.imageUrl), isFalse);
    });
  });
}
