import '../../../../shared/models/order_status.dart';
import 'models/worker_order.dart';

/// Sample orders for the Store Worker preview, used while the backend is
/// not connected. Times are worked out from [now], so the lists always
/// look like "today"; pass a fixed [now] in tests for repeatable results.
///
/// Worker and branch ids match the mock workers in mock_workers.dart:
/// - SS15 Subang: Daniel and Hakim (packers), Amir (driver)
/// - Bukit Jalil: Hafiz (packer), Wei Jie (driver)
///
/// TODO: delete once orders come from the backend.
List<WorkerOrder> seedWorkerOrders(DateTime now) {
  DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));

  // The sample handover and delivery are meant to be from "today". Just
  // after midnight, 35 or 90 minutes ago would be yesterday and they would
  // drop out of the "today" lists, so they are never earlier than
  // midnight.
  final midnight = DateTime(now.year, now.month, now.day);
  DateTime agoToday(int minutes) {
    final time = ago(minutes);
    return time.isBefore(midnight) ? midnight : time;
  }

  return [
    // ---------------- SS15 Subang ----------------

    // Daniel: pending delivery. Amir sees it as "being packed".
    WorkerOrder(
      id: 'ord-2301',
      number: 2301,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Farah Idris',
      customerPhone: '012-345 6789',
      isDelivery: true,
      address: '12, Jalan SS15/4, 47500 Subang Jaya',
      customerNote: 'Please ring the bell twice.',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-milk-full',
          name: 'Fresh milk, full cream',
          brand: 'Farm Fresh',
          packSize: '1L',
          quantity: 2,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-bread-wholemeal',
          name: 'Wholemeal bread',
          brand: 'Gardenia',
          packSize: '400g',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L3',
          productId: 'p-eggs-10',
          name: 'Grade A eggs',
          brand: 'Nutriplus',
          packSize: '10 pcs',
          quantity: 1,
        ),
      ],
      status: OrderStatus.pending,
      placedAt: ago(22),
      statusSince: ago(22),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: ago(20),
      driverId: _amir,
      driverName: _amirName,
      driverAssignedAt: ago(18),
    ),

    // Daniel: pickup being packed, 2 of 5 lines ticked. Includes two
    // milks that look alike (full cream and low fat).
    WorkerOrder(
      id: 'ord-2302',
      number: 2302,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Wong Kar Yee',
      customerPhone: '016-221 4480',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-rice-5kg',
          name: 'Jasmine rice',
          brand: 'Jati',
          packSize: '5kg',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-oil-2kg',
          name: 'Cooking oil',
          brand: 'Saji',
          packSize: '2kg',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L3',
          productId: 'p-milk-full',
          name: 'Fresh milk, full cream',
          brand: 'Farm Fresh',
          packSize: '1L',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L4',
          productId: 'p-milk-lowfat',
          name: 'Fresh milk, low fat',
          brand: 'Farm Fresh',
          packSize: '1L',
          quantity: 2,
        ),
        WorkerOrderItem(
          lineId: 'L5',
          productId: 'p-sugar-1kg',
          name: 'Fine sugar',
          brand: 'Gula Prai',
          packSize: '1kg',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.packing,
      placedAt: ago(30),
      statusSince: ago(8),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: ago(28),
      packingStartedAt: ago(8),
    ),

    // Daniel: delivery being packed, 3 of 4 lines ticked. Amir's.
    WorkerOrder(
      id: 'ord-2303',
      number: 2303,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Mei Ling Tan',
      customerPhone: '017-909 1123',
      isDelivery: true,
      address: '45, Jalan SS17/2, 47500 Subang Jaya',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-chicken-breast',
          name: 'Chicken breast',
          brand: 'Ayamas',
          packSize: '500g',
          quantity: 2,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-broccoli',
          name: 'Broccoli',
          brand: 'Fresh produce',
          packSize: '1 head',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L3',
          productId: 'p-yogurt-greek',
          name: 'Greek yogurt',
          brand: 'Marigold',
          packSize: '130g',
          quantity: 3,
        ),
        WorkerOrderItem(
          lineId: 'L4',
          productId: 'p-bananas',
          name: 'Bananas',
          brand: 'Fresh produce',
          packSize: '1 bunch',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1', 'L2', 'L3'},
      status: OrderStatus.packing,
      placedAt: ago(26),
      statusSince: ago(5),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: ago(24),
      driverId: _amir,
      driverName: _amirName,
      driverAssignedAt: ago(20),
      packingStartedAt: ago(5),
    ),

    // Hakim: pending pickup. Daniel must not see it in My Tasks.
    WorkerOrder(
      id: 'ord-2304',
      number: 2304,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Nur Aisyah',
      customerPhone: '013-778 9021',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-noodles-curry',
          name: 'Curry instant noodles',
          brand: 'Maggi',
          packSize: '5 x 79g',
          quantity: 2,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-tea-bags',
          name: 'Tea bags',
          brand: 'BOH',
          packSize: '50 bags',
          quantity: 1,
        ),
      ],
      status: OrderStatus.pending,
      placedAt: ago(6),
      statusSince: ago(6),
      packerId: _hakim,
      packerName: _hakimName,
      packerAssignedAt: ago(4),
    ),

    // Ready pickup packed by Daniel.
    WorkerOrder(
      id: 'ord-2305',
      number: 2305,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Siti Aminah',
      customerPhone: '019-332 7781',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-detergent',
          name: 'Liquid detergent',
          brand: 'Dynamo',
          packSize: '2.7kg',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-tissue',
          name: 'Facial tissue',
          brand: 'Premier',
          packSize: '4 boxes',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.ready,
      placedAt: ago(55),
      statusSince: ago(25),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: ago(50),
      packingStartedAt: ago(40),
      readyAt: ago(25),
      readyBy: _daniel,
    ),

    // Ready pickup packed by Hakim. Daniel can still hand it over.
    WorkerOrder(
      id: 'ord-2306',
      number: 2306,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Kelvin Lim',
      customerPhone: '012-880 4512',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-coffee-3in1',
          name: '3-in-1 white coffee',
          brand: 'Old Town',
          packSize: '15 sticks',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-biscuits-cream',
          name: 'Cream crackers',
          brand: 'Hup Seng',
          packSize: '428g',
          quantity: 2,
        ),
        WorkerOrderItem(
          lineId: 'L3',
          productId: 'p-milk-full',
          name: 'Fresh milk, full cream',
          brand: 'Farm Fresh',
          packSize: '1L',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1', 'L2', 'L3'},
      status: OrderStatus.ready,
      placedAt: ago(48),
      statusSince: ago(15),
      packerId: _hakim,
      packerName: _hakimName,
      packerAssignedAt: ago(45),
      packingStartedAt: ago(30),
      readyAt: ago(15),
      readyBy: _hakim,
    ),

    // Pickup packed by Hakim, handed over by Daniel.
    WorkerOrder(
      id: 'ord-2307',
      number: 2307,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Raj Kumar',
      customerPhone: '014-662 0937',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-flour',
          name: 'Wheat flour',
          brand: 'Blue Key',
          packSize: '1kg',
          quantity: 2,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-butter',
          name: 'Salted butter',
          brand: 'Anchor',
          packSize: '227g',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.completed,
      placedAt: ago(120),
      statusSince: ago(35),
      packerId: _hakim,
      packerName: _hakimName,
      packerAssignedAt: ago(115),
      packingStartedAt: ago(100),
      readyAt: ago(80),
      readyBy: _hakim,
      pickupVerification: VerificationMethod.manual,
      pickupCompletedBy: _daniel,
      pickupCompletedByName: _danielName,
      completedAt: agoToday(35),
    ),

    // Ready delivery packed by Hakim, waiting for Amir to verify.
    WorkerOrder(
      id: 'ord-2308',
      number: 2308,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'David Wong',
      customerPhone: '012-777 3344',
      isDelivery: true,
      address: 'B-10-3, Subang Avenue, Jalan SS16/1, 47500 Subang Jaya',
      customerNote: 'Leave with the guard if I do not answer.',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-water-1.5l',
          name: 'Mineral water',
          brand: 'Spritzer',
          packSize: '6 x 1.5L',
          quantity: 2,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-rice-5kg',
          name: 'Jasmine rice',
          brand: 'Jati',
          packSize: '5kg',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.ready,
      placedAt: ago(60),
      statusSince: ago(12),
      packerId: _hakim,
      packerName: _hakimName,
      packerAssignedAt: ago(55),
      driverId: _amir,
      driverName: _amirName,
      driverAssignedAt: ago(50),
      packingStartedAt: ago(35),
      readyAt: ago(12),
      readyBy: _hakim,
    ),

    // Out for delivery with Amir (verified by QR).
    WorkerOrder(
      id: 'ord-2309',
      number: 2309,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Priya Nair',
      customerPhone: '011-2345 6780',
      isDelivery: true,
      address: '8, Jalan SS15/2A, 47500 Subang Jaya',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-apples',
          name: 'Fuji apples',
          brand: 'Fresh produce',
          packSize: '4 pcs',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-orange-juice',
          name: 'Orange juice',
          brand: 'Peel Fresh',
          packSize: '1L',
          quantity: 2,
        ),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.outForDelivery,
      placedAt: ago(70),
      statusSince: ago(9),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: ago(65),
      driverId: _amir,
      driverName: _amirName,
      driverAssignedAt: ago(60),
      packingStartedAt: ago(45),
      readyAt: ago(25),
      readyBy: _daniel,
      collectionVerification: VerificationMethod.qr,
      collectionVerifiedBy: _amir,
      collectionVerifiedAt: ago(10),
      outForDeliveryAt: ago(9),
    ),

    // Delivered by Amir.
    WorkerOrder(
      id: 'ord-2310',
      number: 2310,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Aisyah Rahman',
      customerPhone: '013-410 2209',
      isDelivery: true,
      address: '21, Jalan SS14/1, 47500 Subang Jaya',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-diapers-m',
          name: 'Baby diapers, size M',
          brand: 'Drypers',
          packSize: '54 pcs',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1'},
      status: OrderStatus.completed,
      placedAt: ago(180),
      statusSince: ago(90),
      packerId: _hakim,
      packerName: _hakimName,
      packerAssignedAt: ago(175),
      driverId: _amir,
      driverName: _amirName,
      driverAssignedAt: ago(170),
      packingStartedAt: ago(160),
      readyAt: ago(140),
      readyBy: _hakim,
      collectionVerification: VerificationMethod.manual,
      collectionVerifiedBy: _amir,
      collectionVerifiedAt: ago(130),
      outForDeliveryAt: ago(128),
      deliveredBy: _amir,
      deliveredByName: _amirName,
      completedAt: agoToday(90),
    ),

    // Cancelled by HQ before packing started. Assigned to Daniel.
    WorkerOrder(
      id: 'ord-2311',
      number: 2311,
      branchId: _ss15,
      branchName: _ss15Name,
      customerName: 'Jun Hao Lee',
      customerPhone: '016-905 1180',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-chocolate',
          name: 'Milk chocolate',
          brand: 'Beryl\'s',
          packSize: '100g',
          quantity: 3,
        ),
      ],
      status: OrderStatus.cancelled,
      placedAt: ago(40),
      statusSince: ago(32),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: ago(38),
      cancelledAt: ago(32),
    ),

    // ---------------- Bukit Jalil ----------------

    // Hafiz: pending delivery for Wei Jie.
    WorkerOrder(
      id: 'ord-1181',
      number: 1181,
      branchId: _bukitJalil,
      branchName: _bukitJalilName,
      customerName: 'Nurul Huda',
      customerPhone: '012-450 7788',
      isDelivery: true,
      address: '3, Jalan Jalil Perkasa 1, 57000 Bukit Jalil',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-milk-full',
          name: 'Fresh milk, full cream',
          brand: 'Farm Fresh',
          packSize: '1L',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-eggs-10',
          name: 'Grade A eggs',
          brand: 'Nutriplus',
          packSize: '10 pcs',
          quantity: 2,
        ),
      ],
      status: OrderStatus.pending,
      placedAt: ago(10),
      statusSince: ago(10),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: ago(8),
      driverId: _weiJie,
      driverName: _weiJieName,
      driverAssignedAt: ago(7),
    ),

    // Hafiz: pickup being packed, 1 of 3 lines ticked.
    WorkerOrder(
      id: 'ord-1182',
      number: 1182,
      branchId: _bukitJalil,
      branchName: _bukitJalilName,
      customerName: 'Tan Mei Chen',
      customerPhone: '017-221 9087',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-soy-sauce',
          name: 'Light soy sauce',
          brand: 'Kimball',
          packSize: '340ml',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-noodles-curry',
          name: 'Curry instant noodles',
          brand: 'Maggi',
          packSize: '5 x 79g',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L3',
          productId: 'p-bread-wholemeal',
          name: 'Wholemeal bread',
          brand: 'Gardenia',
          packSize: '400g',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1'},
      status: OrderStatus.packing,
      placedAt: ago(18),
      statusSince: ago(6),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: ago(16),
      packingStartedAt: ago(6),
    ),

    // Ready pickup at Bukit Jalil. SS15 packers must never see it.
    WorkerOrder(
      id: 'ord-1183',
      number: 1183,
      branchId: _bukitJalil,
      branchName: _bukitJalilName,
      customerName: 'Arif Hassan',
      customerPhone: '019-887 6610',
      isDelivery: false,
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-oil-2kg',
          name: 'Cooking oil',
          brand: 'Saji',
          packSize: '2kg',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1'},
      status: OrderStatus.ready,
      placedAt: ago(42),
      statusSince: ago(20),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: ago(40),
      packingStartedAt: ago(30),
      readyAt: ago(20),
      readyBy: _hafiz,
    ),

    // Ready delivery for Wei Jie.
    WorkerOrder(
      id: 'ord-1184',
      number: 1184,
      branchId: _bukitJalil,
      branchName: _bukitJalilName,
      customerName: 'Lim Kok Wai',
      customerPhone: '016-773 2290',
      isDelivery: true,
      address: 'A-5-2, Residensi Jalil, Jalan Jalil Utama, 57000 Bukit Jalil',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-water-1.5l',
          name: 'Mineral water',
          brand: 'Spritzer',
          packSize: '6 x 1.5L',
          quantity: 1,
        ),
        WorkerOrderItem(
          lineId: 'L2',
          productId: 'p-tissue',
          name: 'Facial tissue',
          brand: 'Premier',
          packSize: '4 boxes',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.ready,
      placedAt: ago(50),
      statusSince: ago(14),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: ago(48),
      driverId: _weiJie,
      driverName: _weiJieName,
      driverAssignedAt: ago(45),
      packingStartedAt: ago(30),
      readyAt: ago(14),
      readyBy: _hafiz,
    ),

    // Out for delivery with Wei Jie.
    WorkerOrder(
      id: 'ord-1185',
      number: 1185,
      branchId: _bukitJalil,
      branchName: _bukitJalilName,
      customerName: 'Kavitha Raman',
      customerPhone: '012-668 1023',
      isDelivery: true,
      address: '17, Jalan Bukit Jalil Indah 2, 57000 Bukit Jalil',
      items: const [
        WorkerOrderItem(
          lineId: 'L1',
          productId: 'p-chicken-breast',
          name: 'Chicken breast',
          brand: 'Ayamas',
          packSize: '500g',
          quantity: 1,
        ),
      ],
      packedLineIds: const {'L1'},
      status: OrderStatus.outForDelivery,
      placedAt: ago(75),
      statusSince: ago(11),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: ago(72),
      driverId: _weiJie,
      driverName: _weiJieName,
      driverAssignedAt: ago(70),
      packingStartedAt: ago(50),
      readyAt: ago(30),
      readyBy: _hafiz,
      collectionVerification: VerificationMethod.manual,
      collectionVerifiedBy: _weiJie,
      collectionVerifiedAt: ago(12),
      outForDeliveryAt: ago(11),
    ),
  ];
}

const _ss15 = 'ss15';
const _ss15Name = 'SS15 Subang';
const _bukitJalil = 'bukit-jalil';
const _bukitJalilName = 'Bukit Jalil';

const _daniel = 'mock-daniel';
const _danielName = 'Daniel Lee';
const _hakim = 'mock-hakim';
const _hakimName = 'Hakim Roslan';
const _amir = 'mock-amir';
const _amirName = 'Amir Hamzah';
const _hafiz = 'mock-hafiz';
const _hafizName = 'Hafiz Zainal';
const _weiJie = 'mock-weijie';
const _weiJieName = 'Tan Wei Jie';
