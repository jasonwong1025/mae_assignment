import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

/// Sample orders for one branch, used while the backend is not connected.
/// Times are worked out from [now], so the board always looks like "today".
// TODO(team): delete this file once orders come from Firestore.
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
      branchId: 'ss15',
      number: 2287,
      customer: 'Farah Idris',
      phone: '012-345 6789',
      status: OrderStatus.pending,
      placedMinutesAgo: 22,
      minutesInStatus: 22,
      address: '12, Jalan SS15/4, Subang Jaya',
      location: const LatLng(3.0771, 101.5848),
      note: 'Please ring the bell twice.',
      items: const [
        _Line(name: 'Fresh milk 1L', quantity: 2, unitPrice: 7.90),
        _Line(name: 'Wholemeal bread', quantity: 1, unitPrice: 4.50),
        _Line(name: 'Eggs (10)', quantity: 1, unitPrice: 6.80),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2293,
      customer: 'Wong Kar Yee',
      phone: '016-221 4480',
      status: OrderStatus.pending,
      placedMinutesAgo: 6,
      minutesInStatus: 6,
      isDelivery: false,
      items: const [
        _Line(name: 'Jasmine rice 5kg', quantity: 1, unitPrice: 28.90),
        _Line(name: 'Cooking oil 2kg', quantity: 1, unitPrice: 17.50),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2294,
      customer: 'Nur Aisyah',
      phone: '013-778 9021',
      status: OrderStatus.pending,
      placedMinutesAgo: 2,
      minutesInStatus: 2,
      address: 'B-10-3, Subang Avenue, Subang Jaya',
      location: const LatLng(3.0812, 101.5855),
      items: const [
        _Line(name: 'Bananas (bunch)', quantity: 1, unitPrice: 5.20),
        _Line(name: 'Greek yogurt', quantity: 3, unitPrice: 4.90),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2291,
      customer: 'Mei Ling Tan',
      phone: '017-909 1123',
      status: OrderStatus.packing,
      placedMinutesAgo: 15,
      minutesInStatus: 4,
      address: '45, Jalan SS17/2, Subang Jaya',
      location: const LatLng(3.0795, 101.5960),
      worker: 'Daniel',
      items: const [
        _Line(name: 'Chicken breast 500g', quantity: 2, unitPrice: 11.90),
        _Line(name: 'Broccoli', quantity: 1, unitPrice: 6.40),
        _Line(name: 'Soy sauce', quantity: 1, unitPrice: 5.90),
        _Line(name: 'Tofu', quantity: 2, unitPrice: 2.80),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2288,
      customer: 'David Wong',
      phone: '019-334 5567',
      status: OrderStatus.packing,
      placedMinutesAgo: 34,
      minutesInStatus: 18,
      address: '8, Jalan USJ 2/5, Subang Jaya',
      location: const LatLng(3.0625, 101.5912),
      worker: 'Hakim',
      items: const [
        _Line(name: 'Oat milk 1L', quantity: 2, unitPrice: 12.90),
        _Line(name: 'Granola', quantity: 1, unitPrice: 15.90),
        _Line(name: 'Blueberries', quantity: 1, unitPrice: 13.50),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2289,
      customer: 'Siti Aminah',
      phone: '011-2345 6780',
      status: OrderStatus.ready,
      placedMinutesAgo: 40,
      minutesInStatus: 15,
      isDelivery: false,
      worker: 'Daniel',
      items: const [
        _Line(name: 'Instant noodles (5)', quantity: 2, unitPrice: 4.80),
        _Line(name: 'Dish soap', quantity: 1, unitPrice: 6.90),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2292,
      customer: 'Ooi Hui Min',
      phone: '012-618 3390',
      status: OrderStatus.ready,
      placedMinutesAgo: 30,
      minutesInStatus: 7,
      address: '5, Jalan SS16/1, Subang Jaya',
      location: const LatLng(3.0815, 101.5820),
      worker: 'Bryan',
      items: const [
        _Line(name: 'Fresh milk 1L', quantity: 1, unitPrice: 7.90),
        _Line(name: 'Apples (6)', quantity: 1, unitPrice: 9.90),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2284,
      customer: 'Ahmad Fauzi',
      phone: '019-870 2215',
      status: OrderStatus.ready,
      placedMinutesAgo: 44,
      minutesInStatus: 12,
      address: '30, Jalan USJ 9/5, Subang Jaya',
      location: const LatLng(3.0475, 101.5830),
      worker: 'Hakim',
      items: const [
        _Line(name: 'Jasmine rice 5kg', quantity: 1, unitPrice: 28.90),
        _Line(name: 'Eggs (10)', quantity: 2, unitPrice: 6.80),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2290,
      customer: 'Raj Kumar',
      phone: '012-887 4410',
      status: OrderStatus.outForDelivery,
      placedMinutesAgo: 48,
      minutesInStatus: 9,
      address: '23, Jalan SS19/1, Subang Jaya',
      location: const LatLng(3.0745, 101.5745),
      driverId: 'w7',
      worker: 'Amir',
      items: const [
        _Line(name: 'Basmati rice 2kg', quantity: 1, unitPrice: 19.90),
        _Line(name: 'Onions 1kg', quantity: 1, unitPrice: 4.20),
        _Line(name: 'Tomatoes 500g', quantity: 2, unitPrice: 3.60),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2285,
      customer: 'Chong Wei Ling',
      phone: '018-556 7732',
      status: OrderStatus.outForDelivery,
      placedMinutesAgo: 62,
      minutesInStatus: 21,
      address: 'A-5-12, Main Place Residence, USJ 21',
      location: const LatLng(3.0310, 101.5840),
      driverId: 'w8',
      worker: 'Firdaus',
      items: const [
        _Line(name: 'Mineral water 1.5L', quantity: 6, unitPrice: 1.80),
        _Line(name: 'Potato chips', quantity: 2, unitPrice: 5.50),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2286,
      customer: 'Wei Ming',
      phone: '016-903 2218',
      status: OrderStatus.completed,
      placedMinutesAgo: 75,
      minutesInStatus: 2,
      address: '17, Jalan SS14/8, Subang Jaya',
      worker: 'Amir',
      items: const [
        _Line(name: 'Salmon fillet', quantity: 1, unitPrice: 24.90),
        _Line(name: 'Lemon', quantity: 2, unitPrice: 1.50),
      ],
    ),
    _order(
      now,
      branchId: 'ss15',
      number: 2283,
      customer: 'Lim H.',
      phone: '012-600 1934',
      status: OrderStatus.completed,
      placedMinutesAgo: 95,
      minutesInStatus: 31,
      isDelivery: false,
      worker: 'Firdaus',
      items: const [
        _Line(name: 'Coffee beans 250g', quantity: 1, unitPrice: 32),
      ],
    ),
  ];
}

List<Order> _bukitJalilOrders(DateTime now) {
  return [
    _order(
      now,
      branchId: 'bukit-jalil',
      number: 1176,
      customer: 'Priya Nair',
      phone: '012-411 9087',
      status: OrderStatus.pending,
      placedMinutesAgo: 3,
      minutesInStatus: 3,
      address: 'C-12-7, The Park Sky Residence, Bukit Jalil',
      location: const LatLng(3.0560, 101.6800),
      items: const [
        _Line(name: 'Paneer 200g', quantity: 2, unitPrice: 9.90),
        _Line(name: 'Spinach', quantity: 1, unitPrice: 3.50),
      ],
    ),
    _order(
      now,
      branchId: 'bukit-jalil',
      number: 1177,
      customer: 'Kelvin Lim',
      phone: '017-320 5546',
      status: OrderStatus.packing,
      placedMinutesAgo: 14,
      minutesInStatus: 6,
      isDelivery: false,
      worker: 'Hafiz',
      items: const [
        _Line(name: 'Cereal', quantity: 1, unitPrice: 14.90),
        _Line(name: 'Fresh milk 1L', quantity: 1, unitPrice: 7.90),
      ],
    ),
    _order(
      now,
      branchId: 'bukit-jalil',
      number: 1179,
      customer: 'Lee Mei Fong',
      phone: '017-554 0921',
      status: OrderStatus.ready,
      placedMinutesAgo: 25,
      minutesInStatus: 5,
      address: '7, Jalan Jalil Jaya 2, Bukit Jalil',
      location: const LatLng(3.0505, 101.6745),
      worker: 'Hafiz',
      items: const [
        _Line(name: 'Chicken wings 1kg', quantity: 1, unitPrice: 15.90),
        _Line(name: 'Potatoes 1kg', quantity: 1, unitPrice: 5.40),
      ],
    ),
    _order(
      now,
      branchId: 'bukit-jalil',
      number: 1178,
      customer: 'Nurul Huda',
      phone: '013-998 2204',
      status: OrderStatus.outForDelivery,
      placedMinutesAgo: 41,
      minutesInStatus: 12,
      address: '21, Jalan Jalil Perkasa 5, Bukit Jalil',
      location: const LatLng(3.0620, 101.6730),
      driverId: 'w9',
      worker: 'Wei Jie',
      items: const [
        _Line(name: 'Diapers (M)', quantity: 1, unitPrice: 45.90),
        _Line(name: 'Baby wipes', quantity: 2, unitPrice: 8.50),
      ],
    ),
    _order(
      now,
      branchId: 'bukit-jalil',
      number: 1175,
      customer: 'Tan Boon Huat',
      phone: '019-205 6671',
      status: OrderStatus.completed,
      placedMinutesAgo: 88,
      minutesInStatus: 25,
      isDelivery: false,
      worker: 'Hafiz',
      items: const [_Line(name: 'Eggs (30)', quantity: 1, unitPrice: 17.50)],
    ),
  ];
}

List<Order> _puchongOrders(DateTime now) {
  return [
    _order(
      now,
      branchId: 'puchong',
      number: 904,
      customer: 'Aisyah Rahman',
      phone: '011-1090 4432',
      status: OrderStatus.packing,
      placedMinutesAgo: 26,
      minutesInStatus: 11,
      address: '9, Jalan Puteri 5/2, Bandar Puteri Puchong',
      location: const LatLng(3.0225, 101.6110),
      worker: 'Syafiq',
      items: const [
        _Line(name: 'Brown rice 2kg', quantity: 1, unitPrice: 16.90),
        _Line(name: 'Canned tuna', quantity: 3, unitPrice: 6.20),
      ],
    ),
    _order(
      now,
      branchId: 'puchong',
      number: 905,
      customer: 'Muthu Krishnan',
      phone: '012-702 6618',
      status: OrderStatus.ready,
      placedMinutesAgo: 33,
      minutesInStatus: 9,
      address: '14, Jalan Kenari 3, Bandar Puchong Jaya',
      location: const LatLng(3.0400, 101.6200),
      worker: 'Syafiq',
      items: const [
        _Line(name: 'Atta flour 2kg', quantity: 1, unitPrice: 11.50),
        _Line(name: 'Ghee 400g', quantity: 1, unitPrice: 18.90),
      ],
    ),
    _order(
      now,
      branchId: 'puchong',
      number: 903,
      customer: 'Jun Hao Lee',
      phone: '016-447 1290',
      status: OrderStatus.ready,
      placedMinutesAgo: 45,
      minutesInStatus: 20,
      isDelivery: false,
      worker: 'Syafiq',
      items: const [
        _Line(name: 'Orange juice 1L', quantity: 2, unitPrice: 8.90),
        _Line(name: 'Croissants (4)', quantity: 1, unitPrice: 9.50),
      ],
    ),
  ];
}

/// One product line as written in the sample lists below. Turned into a
/// full [OrderItem] by [_order].
class _Line {
  const _Line({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  final String name;
  final int quantity;
  final double unitPrice;
}

/// Branch names for the sample branches.
const _branchNames = {
  'ss15': 'SS15 Subang',
  'bukit-jalil': 'Bukit Jalil',
  'puchong': 'Puchong',
};

/// Builds one sample order in the shared [Order] contract. Fills in the
/// parts that follow from the rest (ids, money, and the timestamps of each
/// step) so the lists above stay short.
Order _order(
  DateTime now, {
  required String branchId,
  required int number,
  required String customer,
  required String phone,
  required OrderStatus status,
  required int placedMinutesAgo,
  required int minutesInStatus,
  required List<_Line> items,
  bool isDelivery = true,
  String? address,
  LatLng? location,
  String? note,
  String? worker,
  String? driverId,
}) {
  final placedAt = now.subtract(Duration(minutes: placedMinutesAgo));
  final statusSince = now.subtract(Duration(minutes: minutesInStatus));

  final lines = [
    for (final (index, line) in items.indexed)
      OrderItem(
        lineId: 'L${index + 1}',
        productId: 'sample-${line.name.toLowerCase().replaceAll(' ', '-')}',
        name: line.name,
        brand: '',
        packSize: '',
        quantity: line.quantity,
        unitPrice: line.unitPrice,
      ),
  ];
  final subtotal = lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
  final deliveryFee = isDelivery ? 5.00 : 0.0;

  // The steps an order has gone through to reach [status], spread evenly
  // between when it was placed and when it reached that status. Pickup
  // orders skip "out for delivery".
  final steps = [
    OrderStatus.pending,
    OrderStatus.packing,
    OrderStatus.ready,
    if (isDelivery) OrderStatus.outForDelivery,
    OrderStatus.completed,
  ];
  final stepsDone = steps.indexOf(status) + 1;
  final timeBetweenSteps =
      statusSince.difference(placedAt) ~/ math.max(1, stepsDone - 1);

  // When step [step] (an index into [steps]) happened, or null if the
  // order has not got that far.
  DateTime? stepTime(OrderStatus step) {
    final index = steps.indexOf(step);
    if (index == -1 || index >= stepsDone) return null;
    return placedAt.add(timeBetweenSteps * index);
  }

  // A delivery order that has a driver was handed to them when it became
  // ready; the worker named in the list is the driver. Otherwise the
  // worker is the packer.
  final hasDriver = driverId != null;
  final readyAt = stepTime(OrderStatus.ready);

  return Order(
    id: 'ord-$number',
    number: number,
    customerId: 'sample-customer-$number',
    customerName: customer,
    customerPhone: phone,
    branchId: branchId,
    branchName: _branchNames[branchId] ?? branchId,
    isDelivery: isDelivery,
    items: lines,
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    discount: 0,
    total: subtotal + deliveryFee,
    status: status,
    address: address,
    addressLocation: location,
    customerNote: note,
    placedAt: placedAt,
    statusSince: statusSince,
    packerName: hasDriver ? null : worker,
    driverId: driverId,
    driverName: hasDriver ? worker : null,
    driverAssignedAt: hasDriver ? readyAt : null,
    packingStartedAt: stepTime(OrderStatus.packing),
    readyAt: readyAt,
    outForDeliveryAt: stepTime(OrderStatus.outForDelivery),
    completedAt: stepTime(OrderStatus.completed),
  );
}
