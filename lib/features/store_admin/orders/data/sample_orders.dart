import 'dart:math' as math;

import 'models/order.dart';

/// Sample orders for one branch, used while the backend is not connected.
/// Times are worked out from [now], so the board always looks like "today".
/// TODO: delete this file once orders come from Firestore.
List<Order> sampleOrdersFor(String branchId, DateTime now) {
  switch (branchId) {
    case 'ss15':
      return _ss15Orders(now);
    case 'bukit-jalil':
      return _bukitJalilOrders(now);
    case 'puchong':
      return _puchongOrders(now);
    default:
      return [];
  }
}

List<Order> _ss15Orders(DateTime now) {
  return [
    _order(
      now,
      number: 2287,
      customer: 'Farah Idris',
      phone: '012-345 6789',
      status: OrderStatus.pending,
      placedMinutesAgo: 22,
      minutesInStatus: 22,
      address: '12, Jalan SS15/4, Subang Jaya',
      note: 'Please ring the bell twice.',
      items: const [
        OrderItem(name: 'Fresh milk 1L', quantity: 2, unitPrice: 7.90),
        OrderItem(name: 'Wholemeal bread', quantity: 1, unitPrice: 4.50),
        OrderItem(name: 'Eggs (10)', quantity: 1, unitPrice: 6.80),
      ],
    ),
    _order(
      now,
      number: 2293,
      customer: 'Wong Kar Yee',
      phone: '016-221 4480',
      status: OrderStatus.pending,
      placedMinutesAgo: 6,
      minutesInStatus: 6,
      isDelivery: false,
      payment: PaymentMethod.cash,
      items: const [
        OrderItem(name: 'Jasmine rice 5kg', quantity: 1, unitPrice: 28.90),
        OrderItem(name: 'Cooking oil 2kg', quantity: 1, unitPrice: 17.50),
      ],
    ),
    _order(
      now,
      number: 2294,
      customer: 'Nur Aisyah',
      phone: '013-778 9021',
      status: OrderStatus.pending,
      placedMinutesAgo: 2,
      minutesInStatus: 2,
      address: 'B-10-3, Subang Avenue, Subang Jaya',
      items: const [
        OrderItem(name: 'Bananas (bunch)', quantity: 1, unitPrice: 5.20),
        OrderItem(name: 'Greek yogurt', quantity: 3, unitPrice: 4.90),
      ],
    ),
    _order(
      now,
      number: 2291,
      customer: 'Mei Ling Tan',
      phone: '017-909 1123',
      status: OrderStatus.packing,
      placedMinutesAgo: 15,
      minutesInStatus: 4,
      address: '45, Jalan SS17/2, Subang Jaya',
      worker: 'Daniel',
      items: const [
        OrderItem(name: 'Chicken breast 500g', quantity: 2, unitPrice: 11.90),
        OrderItem(name: 'Broccoli', quantity: 1, unitPrice: 6.40),
        OrderItem(name: 'Soy sauce', quantity: 1, unitPrice: 5.90),
        OrderItem(name: 'Tofu', quantity: 2, unitPrice: 2.80),
      ],
    ),
    _order(
      now,
      number: 2288,
      customer: 'David Wong',
      phone: '019-334 5567',
      status: OrderStatus.packing,
      placedMinutesAgo: 34,
      minutesInStatus: 18,
      address: '8, Jalan USJ 2/5, Subang Jaya',
      worker: 'Hakim',
      attentionReason:
          'Oat milk is out of stock. Waiting for the customer to accept '
          'a replacement.',
      items: const [
        OrderItem(
          name: 'Oat milk 1L',
          quantity: 2,
          unitPrice: 12.90,
          isOutOfStock: true,
        ),
        OrderItem(name: 'Granola', quantity: 1, unitPrice: 15.90),
        OrderItem(
          name: 'Blueberries',
          quantity: 1,
          unitPrice: 13.50,
          replacedWith: 'Strawberries',
        ),
      ],
    ),
    _order(
      now,
      number: 2289,
      customer: 'Siti Aminah',
      phone: '011-2345 6780',
      status: OrderStatus.ready,
      placedMinutesAgo: 40,
      minutesInStatus: 15,
      isDelivery: false,
      worker: 'Daniel',
      items: const [
        OrderItem(name: 'Instant noodles (5)', quantity: 2, unitPrice: 4.80),
        OrderItem(name: 'Dish soap', quantity: 1, unitPrice: 6.90),
      ],
    ),
    _order(
      now,
      number: 2290,
      customer: 'Raj Kumar',
      phone: '012-887 4410',
      status: OrderStatus.outForDelivery,
      placedMinutesAgo: 48,
      minutesInStatus: 9,
      address: '23, Jalan SS19/1, Subang Jaya',
      worker: 'Amir',
      items: const [
        OrderItem(name: 'Basmati rice 2kg', quantity: 1, unitPrice: 19.90),
        OrderItem(name: 'Onions 1kg', quantity: 1, unitPrice: 4.20),
        OrderItem(name: 'Tomatoes 500g', quantity: 2, unitPrice: 3.60),
      ],
    ),
    _order(
      now,
      number: 2285,
      customer: 'Chong Wei Ling',
      phone: '018-556 7732',
      status: OrderStatus.outForDelivery,
      placedMinutesAgo: 62,
      minutesInStatus: 21,
      address: 'A-5-12, Main Place Residence, USJ 21',
      payment: PaymentMethod.cash,
      worker: 'Firdaus',
      items: const [
        OrderItem(name: 'Mineral water 1.5L', quantity: 6, unitPrice: 1.80),
        OrderItem(name: 'Potato chips', quantity: 2, unitPrice: 5.50),
      ],
    ),
    _order(
      now,
      number: 2286,
      customer: 'Wei Ming',
      phone: '016-903 2218',
      status: OrderStatus.completed,
      placedMinutesAgo: 75,
      minutesInStatus: 2,
      address: '17, Jalan SS14/8, Subang Jaya',
      worker: 'Amir',
      items: const [
        OrderItem(name: 'Salmon fillet', quantity: 1, unitPrice: 24.90),
        OrderItem(name: 'Lemon', quantity: 2, unitPrice: 1.50),
      ],
    ),
    _order(
      now,
      number: 2283,
      customer: 'Lim H.',
      phone: '012-600 1934',
      status: OrderStatus.completed,
      placedMinutesAgo: 95,
      minutesInStatus: 31,
      isDelivery: false,
      payment: PaymentMethod.cash,
      worker: 'Firdaus',
      items: const [
        OrderItem(name: 'Coffee beans 250g', quantity: 1, unitPrice: 32.00),
      ],
    ),
    _order(
      now,
      number: 2280,
      customer: 'K. Devi',
      phone: '014-772 8830',
      status: OrderStatus.cancelled,
      placedMinutesAgo: 120,
      minutesInStatus: 110,
      address: '3, Jalan SS18/6, Subang Jaya',
      items: const [
        OrderItem(name: 'Butter 250g', quantity: 1, unitPrice: 13.90),
        OrderItem(name: 'Flour 1kg', quantity: 2, unitPrice: 3.90),
      ],
    ),
  ];
}

List<Order> _bukitJalilOrders(DateTime now) {
  return [
    _order(
      now,
      number: 1176,
      customer: 'Priya Nair',
      phone: '012-411 9087',
      status: OrderStatus.pending,
      placedMinutesAgo: 3,
      minutesInStatus: 3,
      address: 'C-12-7, The Park Sky Residence, Bukit Jalil',
      items: const [
        OrderItem(name: 'Paneer 200g', quantity: 2, unitPrice: 9.90),
        OrderItem(name: 'Spinach', quantity: 1, unitPrice: 3.50),
      ],
    ),
    _order(
      now,
      number: 1177,
      customer: 'Kelvin Lim',
      phone: '017-320 5546',
      status: OrderStatus.packing,
      placedMinutesAgo: 14,
      minutesInStatus: 6,
      isDelivery: false,
      worker: 'Hafiz',
      items: const [
        OrderItem(name: 'Cereal', quantity: 1, unitPrice: 14.90),
        OrderItem(name: 'Fresh milk 1L', quantity: 1, unitPrice: 7.90),
      ],
    ),
    _order(
      now,
      number: 1178,
      customer: 'Nurul Huda',
      phone: '013-998 2204',
      status: OrderStatus.outForDelivery,
      placedMinutesAgo: 41,
      minutesInStatus: 12,
      address: '21, Jalan Jalil Perkasa 5, Bukit Jalil',
      worker: 'Wei Jie',
      items: const [
        OrderItem(name: 'Diapers (M)', quantity: 1, unitPrice: 45.90),
        OrderItem(name: 'Baby wipes', quantity: 2, unitPrice: 8.50),
      ],
    ),
    _order(
      now,
      number: 1175,
      customer: 'Tan Boon Huat',
      phone: '019-205 6671',
      status: OrderStatus.completed,
      placedMinutesAgo: 88,
      minutesInStatus: 25,
      isDelivery: false,
      payment: PaymentMethod.cash,
      worker: 'Hafiz',
      items: const [
        OrderItem(name: 'Eggs (30)', quantity: 1, unitPrice: 17.50),
      ],
    ),
  ];
}

List<Order> _puchongOrders(DateTime now) {
  return [
    _order(
      now,
      number: 904,
      customer: 'Aisyah Rahman',
      phone: '011-1090 4432',
      status: OrderStatus.packing,
      placedMinutesAgo: 26,
      minutesInStatus: 11,
      address: '9, Jalan Puteri 5/2, Bandar Puteri Puchong',
      worker: 'Syafiq',
      attentionReason:
          'Brown rice is out of stock. Waiting for the customer to accept '
          'a replacement.',
      items: const [
        OrderItem(
          name: 'Brown rice 2kg',
          quantity: 1,
          unitPrice: 16.90,
          isOutOfStock: true,
        ),
        OrderItem(name: 'Canned tuna', quantity: 3, unitPrice: 6.20),
      ],
    ),
    _order(
      now,
      number: 903,
      customer: 'Jun Hao Lee',
      phone: '016-447 1290',
      status: OrderStatus.ready,
      placedMinutesAgo: 45,
      minutesInStatus: 20,
      isDelivery: false,
      payment: PaymentMethod.cash,
      worker: 'Syafiq',
      items: const [
        OrderItem(name: 'Orange juice 1L', quantity: 2, unitPrice: 8.90),
        OrderItem(name: 'Croissants (4)', quantity: 1, unitPrice: 9.50),
      ],
    ),
  ];
}

/// Builds one sample order. Fills in the parts that follow from the rest
/// (delivery fee, paid or not, timeline) so the lists above stay short.
Order _order(
  DateTime now, {
  required int number,
  required String customer,
  required String phone,
  required OrderStatus status,
  required int placedMinutesAgo,
  required int minutesInStatus,
  required List<OrderItem> items,
  bool isDelivery = true,
  String? address,
  String? note,
  PaymentMethod payment = PaymentMethod.online,
  String? worker,
  String? attentionReason,
}) {
  final placedAt = now.subtract(Duration(minutes: placedMinutesAgo));
  final statusSince = now.subtract(Duration(minutes: minutesInStatus));

  return Order(
    number: number,
    customerName: customer,
    customerPhone: phone,
    status: status,
    statusSince: statusSince,
    isDelivery: isDelivery,
    address: address,
    customerNote: note,
    items: items,
    deliveryFee: isDelivery ? 5.00 : 0,
    paymentMethod: payment,
    // Online orders are paid at checkout, cash orders when handed over.
    isPaid: payment == PaymentMethod.online || status == OrderStatus.completed,
    assignedWorker: worker,
    attentionReason: attentionReason,
    timeline: _timeline(
      placedAt: placedAt,
      statusSince: statusSince,
      status: status,
      isDelivery: isDelivery,
      worker: worker,
    ),
  );
}

/// The steps an order has gone through to reach [status], spread evenly
/// between when it was placed and when it reached that status.
List<OrderEvent> _timeline({
  required DateTime placedAt,
  required DateTime statusSince,
  required OrderStatus status,
  required bool isDelivery,
  String? worker,
}) {
  if (status == OrderStatus.cancelled) {
    return [
      OrderEvent(title: 'Order placed', time: placedAt),
      OrderEvent(title: 'Order cancelled', time: statusSince),
    ];
  }

  // Pickup orders skip "Out for delivery".
  final steps = [
    (OrderStatus.pending, 'Order placed'),
    (OrderStatus.packing, 'Packing started'),
    (OrderStatus.ready, isDelivery ? 'Ready for delivery' : 'Ready for pickup'),
    if (isDelivery) (OrderStatus.outForDelivery, 'Out for delivery'),
    (OrderStatus.completed, isDelivery ? 'Delivered' : 'Picked up'),
  ];

  final stepsDone = steps.indexWhere((step) => step.$1 == status) + 1;
  final timeBetweenSteps =
      statusSince.difference(placedAt) ~/ math.max(1, stepsDone - 1);

  return [
    for (var i = 0; i < stepsDone; i++)
      OrderEvent(
        title: steps[i].$2,
        time: placedAt.add(timeBetweenSteps * i),
        // The customer places the order; staff do every step after that.
        by: i == 0 ? null : worker,
      ),
  ];
}
