import 'package:mae_assignment/features/store_admin/inventory/data/sample_inventory.dart';
import 'package:mae_assignment/features/store_worker/orders/data/models/worker_order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

/// Sample orders for the Store Worker preview, used while the backend is
/// not connected. Times are worked out from [now], so the lists always
/// look like "today"; pass a fixed [now] in tests for repeatable results.
///
/// Worker and branch ids match the mock workers in mock_workers.dart:
/// - SS15 Subang: Daniel and Hakim (packers)
/// - Bukit Jalil: Hafiz (packer)
/// - Drivers Amir and Wei Jie have no branch: each has deliveries from both
///   branches (Amir: SS15 orders and #1184; Wei Jie: #2301 and the other
///   Bukit Jalil orders).
///
// TODO(team): delete once orders come from the backend.
List<WorkerOrder> seedWorkerOrders(DateTime now) {
  DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));

  // [days] days back, [minutes] before this time of day; for My history.
  DateTime daysAgo(int days, int minutes) =>
      now.subtract(Duration(days: days, minutes: minutes));

  // Promised pickup or delivery time; negative is in the past.
  DateTime fromNow(int minutes) => now.add(Duration(minutes: minutes));

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

    // Daniel: pending delivery for Wei Jie (a cross-branch driver), who
    // sees it as "being packed".
    WorkerOrder(
      id: 'ord-2301',
      number: 2301,
      branchId: _ss15,
      branchName: _ss15Name,
      branchAddress: _ss15Address,
      customerName: 'Farah Idris',
      customerPhone: '012-345 6789',
      isDelivery: true,
      address: '12, Jalan SS15/4, 47500 Subang Jaya',
      customerNote: 'Please ring the bell twice.',
      items: [
        _item(_ss15, 'L1', 'p1', 2),
        _item(_ss15, 'L2', 'p5', 1),
        _item(_ss15, 'L3', 'p3', 1),
      ],
      status: OrderStatus.pending,
      placedAt: ago(22),
      dueAt: fromNow(25),
      statusSince: ago(22),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: ago(20),
      driverId: _weiJie,
      driverName: _weiJieName,
      driverAssignedAt: ago(18),
    ),

    // Daniel: pickup being packed, 2 of 5 lines ticked. Includes two
    // milks that look alike (Farm Fresh milk and Oatside oat milk, both 1L).
    WorkerOrder(
      id: 'ord-2302',
      number: 2302,
      branchId: _ss15,
      branchName: _ss15Name,
      branchAddress: _ss15Address,
      customerName: 'Wong Kar Yee',
      customerPhone: '016-221 4480',
      isDelivery: false,
      items: [
        _item(_ss15, 'L1', 'p12', 1),
        _item(_ss15, 'L2', 'p13', 1),
        _item(_ss15, 'L3', 'p1', 1),
        _item(_ss15, 'L4', 'p2', 2),
        _item(_ss15, 'L5', 'p36', 1),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.packing,
      placedAt: ago(30),
      dueAt: fromNow(55),
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
      branchAddress: _ss15Address,
      customerName: 'Mei Ling Tan',
      customerPhone: '017-909 1123',
      isDelivery: true,
      address: '45, Jalan SS17/2, 47500 Subang Jaya',
      items: [
        _item(_ss15, 'L1', 'p10', 2),
        _item(_ss15, 'L2', 'p8', 1),
        _item(_ss15, 'L3', 'p4', 3),
        _item(_ss15, 'L4', 'p7', 1),
      ],
      packedLineIds: const {'L1', 'L2', 'L3'},
      status: OrderStatus.packing,
      placedAt: ago(26),
      dueAt: fromNow(40),
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
      branchAddress: _ss15Address,
      customerName: 'Nur Aisyah',
      customerPhone: '013-778 9021',
      isDelivery: false,
      items: [_item(_ss15, 'L1', 'p33', 2), _item(_ss15, 'L2', 'p38', 1)],
      status: OrderStatus.pending,
      placedAt: ago(6),
      dueAt: fromNow(50),
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
      branchAddress: _ss15Address,
      customerName: 'Siti Aminah',
      customerPhone: '019-332 7781',
      isDelivery: false,
      items: [_item(_ss15, 'L1', 'p45', 1), _item(_ss15, 'L2', 'p18', 1)],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.ready,
      placedAt: ago(55),
      dueAt: fromNow(10),
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
      branchAddress: _ss15Address,
      customerName: 'Kelvin Lim',
      customerPhone: '012-880 4512',
      isDelivery: false,
      items: [
        _item(_ss15, 'L1', 'p37', 1),
        _item(_ss15, 'L2', 'p17', 2),
        _item(_ss15, 'L3', 'p1', 1),
      ],
      packedLineIds: const {'L1', 'L2', 'L3'},
      status: OrderStatus.ready,
      placedAt: ago(48),
      dueAt: fromNow(20),
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
      branchAddress: _ss15Address,
      customerName: 'Raj Kumar',
      customerPhone: '014-662 0937',
      isDelivery: false,
      items: [_item(_ss15, 'L1', 'p35', 2), _item(_ss15, 'L2', 'p29', 1)],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.completed,
      placedAt: ago(120),
      dueAt: fromNow(-20),
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
      branchAddress: _ss15Address,
      customerName: 'David Wong',
      customerPhone: '012-777 3344',
      isDelivery: true,
      address: 'B-10-3, Subang Avenue, Jalan SS16/1, 47500 Subang Jaya',
      customerNote: 'Leave with the guard if I do not answer.',
      items: [_item(_ss15, 'L1', 'p15', 2), _item(_ss15, 'L2', 'p12', 1)],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.ready,
      placedAt: ago(60),
      dueAt: fromNow(15),
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
      branchAddress: _ss15Address,
      customerName: 'Priya Nair',
      customerPhone: '011-2345 6780',
      isDelivery: true,
      address: '8, Jalan SS15/2A, 47500 Subang Jaya',
      items: [_item(_ss15, 'L1', 'p9', 1), _item(_ss15, 'L2', 'p16', 2)],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.outForDelivery,
      placedAt: ago(70),
      dueAt: fromNow(5),
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
      branchAddress: _ss15Address,
      customerName: 'Aisyah Rahman',
      customerPhone: '013-410 2209',
      isDelivery: true,
      address: '21, Jalan SS14/1, 47500 Subang Jaya',
      items: [_item(_ss15, 'L1', 'p19', 1)],
      packedLineIds: const {'L1'},
      status: OrderStatus.completed,
      placedAt: ago(180),
      dueAt: fromNow(-60),
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
      branchAddress: _ss15Address,
      customerName: 'Jun Hao Lee',
      customerPhone: '016-905 1180',
      isDelivery: false,
      items: [_item(_ss15, 'L1', 'p41', 3)],
      status: OrderStatus.cancelled,
      placedAt: ago(40),
      dueAt: fromNow(30),
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
      branchAddress: _bukitJalilAddress,
      customerName: 'Nurul Huda',
      customerPhone: '012-450 7788',
      isDelivery: true,
      address: '3, Jalan Jalil Perkasa 1, 57000 Bukit Jalil',
      items: [
        _item(_bukitJalil, 'L1', 'p1', 1),
        _item(_bukitJalil, 'L2', 'p3', 2),
      ],
      status: OrderStatus.pending,
      placedAt: ago(10),
      dueAt: fromNow(45),
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
      branchAddress: _bukitJalilAddress,
      customerName: 'Tan Mei Chen',
      customerPhone: '017-221 9087',
      isDelivery: false,
      items: [
        _item(_bukitJalil, 'L1', 'p14', 1),
        _item(_bukitJalil, 'L2', 'p33', 1),
        _item(_bukitJalil, 'L3', 'p5', 1),
      ],
      packedLineIds: const {'L1'},
      status: OrderStatus.packing,
      placedAt: ago(18),
      dueAt: fromNow(35),
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
      branchAddress: _bukitJalilAddress,
      customerName: 'Arif Hassan',
      customerPhone: '019-887 6610',
      isDelivery: false,
      items: [_item(_bukitJalil, 'L1', 'p13', 1)],
      packedLineIds: const {'L1'},
      status: OrderStatus.ready,
      placedAt: ago(42),
      dueAt: fromNow(15),
      statusSince: ago(20),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: ago(40),
      packingStartedAt: ago(30),
      readyAt: ago(20),
      readyBy: _hafiz,
    ),

    // Ready delivery for Amir: his Bukit Jalil job alongside his SS15 ones.
    WorkerOrder(
      id: 'ord-1184',
      number: 1184,
      branchId: _bukitJalil,
      branchName: _bukitJalilName,
      branchAddress: _bukitJalilAddress,
      customerName: 'Lim Kok Wai',
      customerPhone: '016-773 2290',
      isDelivery: true,
      address: 'A-5-2, Residensi Jalil, Jalan Jalil Utama, 57000 Bukit Jalil',
      items: [
        _item(_bukitJalil, 'L1', 'p15', 1),
        _item(_bukitJalil, 'L2', 'p46', 1),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.ready,
      placedAt: ago(50),
      dueAt: fromNow(25),
      statusSince: ago(14),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: ago(48),
      driverId: _amir,
      driverName: _amirName,
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
      branchAddress: _bukitJalilAddress,
      customerName: 'Kavitha Raman',
      customerPhone: '012-668 1023',
      isDelivery: true,
      address: '17, Jalan Bukit Jalil Indah 2, 57000 Bukit Jalil',
      items: [_item(_bukitJalil, 'L1', 'p10', 1)],
      packedLineIds: const {'L1'},
      status: OrderStatus.outForDelivery,
      placedAt: ago(75),
      dueAt: fromNow(10),
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

    // ---------------- Earlier days (for My history) ----------------

    // Yesterday: pickup packed by Daniel, handed over by Hakim.
    WorkerOrder(
      id: 'ord-2280',
      number: 2280,
      branchId: _ss15,
      branchName: _ss15Name,
      branchAddress: _ss15Address,
      customerName: 'Lee Siew Ling',
      customerPhone: '012-334 9081',
      isDelivery: false,
      items: [_item(_ss15, 'L1', 'p29', 1), _item(_ss15, 'L2', 'p31', 2)],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.completed,
      placedAt: daysAgo(1, 180),
      dueAt: daysAgo(1, 60),
      statusSince: daysAgo(1, 50),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: daysAgo(1, 170),
      packingStartedAt: daysAgo(1, 150),
      readyAt: daysAgo(1, 130),
      readyBy: _daniel,
      pickupVerification: VerificationMethod.manual,
      pickupCompletedBy: _hakim,
      pickupCompletedByName: _hakimName,
      completedAt: daysAgo(1, 50),
    ),

    // Yesterday: delivery packed by Hakim, delivered by Amir.
    WorkerOrder(
      id: 'ord-2281',
      number: 2281,
      branchId: _ss15,
      branchName: _ss15Name,
      branchAddress: _ss15Address,
      customerName: 'Ahmad Faiz',
      customerPhone: '017-662 1045',
      isDelivery: true,
      address: '9, Jalan SS15/8, 47500 Subang Jaya',
      items: [_item(_ss15, 'L1', 'p33', 2), _item(_ss15, 'L2', 'p15', 1)],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.completed,
      placedAt: daysAgo(1, 240),
      dueAt: daysAgo(1, 120),
      statusSince: daysAgo(1, 110),
      packerId: _hakim,
      packerName: _hakimName,
      packerAssignedAt: daysAgo(1, 230),
      driverId: _amir,
      driverName: _amirName,
      driverAssignedAt: daysAgo(1, 225),
      packingStartedAt: daysAgo(1, 210),
      readyAt: daysAgo(1, 190),
      readyBy: _hakim,
      collectionVerification: VerificationMethod.manual,
      collectionVerifiedBy: _amir,
      collectionVerifiedAt: daysAgo(1, 170),
      outForDeliveryAt: daysAgo(1, 168),
      deliveredBy: _amir,
      deliveredByName: _amirName,
      completedAt: daysAgo(1, 110),
    ),

    // Three days ago: delivery packed by Daniel, delivered by Amir.
    WorkerOrder(
      id: 'ord-2275',
      number: 2275,
      branchId: _ss15,
      branchName: _ss15Name,
      branchAddress: _ss15Address,
      customerName: 'Grace Ong',
      customerPhone: '016-781 2237',
      isDelivery: true,
      address: '27, Jalan SS16/3, 47500 Subang Jaya',
      items: [
        _item(_ss15, 'L1', 'p10', 2),
        _item(_ss15, 'L2', 'p22', 1),
        _item(_ss15, 'L3', 'p25', 1),
      ],
      packedLineIds: const {'L1', 'L2', 'L3'},
      status: OrderStatus.completed,
      placedAt: daysAgo(3, 200),
      dueAt: daysAgo(3, 90),
      statusSince: daysAgo(3, 80),
      packerId: _daniel,
      packerName: _danielName,
      packerAssignedAt: daysAgo(3, 190),
      driverId: _amir,
      driverName: _amirName,
      driverAssignedAt: daysAgo(3, 185),
      packingStartedAt: daysAgo(3, 170),
      readyAt: daysAgo(3, 150),
      readyBy: _daniel,
      collectionVerification: VerificationMethod.qr,
      collectionVerifiedBy: _amir,
      collectionVerifiedAt: daysAgo(3, 130),
      outForDeliveryAt: daysAgo(3, 128),
      deliveredBy: _amir,
      deliveredByName: _amirName,
      completedAt: daysAgo(3, 80),
    ),

    // Yesterday at Bukit Jalil: packed by Hafiz, delivered by Wei Jie.
    WorkerOrder(
      id: 'ord-1170',
      number: 1170,
      branchId: _bukitJalil,
      branchName: _bukitJalilName,
      branchAddress: _bukitJalilAddress,
      customerName: 'Siti Nurhaliza',
      customerPhone: '019-224 5513',
      isDelivery: true,
      address: '5, Jalan Jalil Jaya 3, 57000 Bukit Jalil',
      items: [
        _item(_bukitJalil, 'L1', 'p12', 1),
        _item(_bukitJalil, 'L2', 'p13', 1),
      ],
      packedLineIds: const {'L1', 'L2'},
      status: OrderStatus.completed,
      placedAt: daysAgo(1, 200),
      dueAt: daysAgo(1, 90),
      statusSince: daysAgo(1, 85),
      packerId: _hafiz,
      packerName: _hafizName,
      packerAssignedAt: daysAgo(1, 190),
      driverId: _weiJie,
      driverName: _weiJieName,
      driverAssignedAt: daysAgo(1, 185),
      packingStartedAt: daysAgo(1, 170),
      readyAt: daysAgo(1, 150),
      readyBy: _hafiz,
      collectionVerification: VerificationMethod.manual,
      collectionVerifiedBy: _weiJie,
      collectionVerifiedAt: daysAgo(1, 130),
      outForDeliveryAt: daysAgo(1, 128),
      deliveredBy: _weiJie,
      deliveredByName: _weiJieName,
      completedAt: daysAgo(1, 85),
    ),
  ];
}

const _ss15 = 'ss15';
const _ss15Name = 'SS15 Subang';
const _ss15Address = '18, Jalan SS15/4D, 47500 Subang Jaya';
const _bukitJalil = 'bukit-jalil';
const _bukitJalilName = 'Bukit Jalil';
const _bukitJalilAddress = 'Lot G-12, Jalan Jalil Perkasa 7, 57000 Bukit Jalil';

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

/// The admin's sample products, by id, so order lines show the same names,
/// brands, sizes, categories and descriptions as the Inventory tab.
final _inventory = sampleInventory();
final _catalogue = {
  for (final item in _inventory) item.product.id: item.product,
};

/// Each product's price at each branch, keyed "branchId/productId".
final _prices = {
  for (final item in _inventory)
    '${item.branchId}/${item.product.id}': item.price,
};
final _categoryNames = {
  for (final category in sampleCategories()) category.id: category.name,
};

/// One order line for catalogue product [productId], priced at [branchId].
WorkerOrderItem _item(
  String branchId,
  String lineId,
  String productId,
  int quantity,
) {
  final product = _catalogue[productId]!;
  return WorkerOrderItem(
    lineId: lineId,
    productId: product.id,
    name: product.name,
    brand: product.brand,
    packSize: product.packSize,
    unitPrice: _prices['$branchId/$productId'] ?? 0,
    category: _categoryNames[product.categoryId] ?? '',
    description: product.description,
    quantity: quantity,
  );
}
