import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/features/store_admin/dashboard/data/models/dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

/// Dashboard numbers for the store admin.
///
/// The backend is not connected yet, so this returns sample data.
/// The method is already async, so later only the inside of this class
/// changes (to call a Firestore service) and the screens stay the same.
class DashboardRepository {
  /// Today's numbers for one branch.
  Future<DashboardSummary> getSummary(String branchId) async {
    return _sampleSummaries[branchId]!;
  }
}

const _sampleSummaries = {
  'ss15': DashboardSummary(
    ordersToday: 47,
    ordersYesterday: 35,
    ordersByHour: [1, 3, 4, 5, 6, 2, 3, 4, 5, 9, 5],
    revenue: 2384,
    driversOnRoad: 4,
    totalDrivers: 6,
    liveOrders: [
      LiveOrder(
        number: 2291,
        customerName: 'Mei Ling Tan',
        status: LiveOrderStatus.packing,
        isDelivery: true,
        minutesInStatus: 4,
      ),
      LiveOrder(
        number: 2288,
        customerName: 'David Wong',
        status: LiveOrderStatus.packing,
        isDelivery: true,
        minutesInStatus: 18,
      ),
      LiveOrder(
        number: 2290,
        customerName: 'Raj Kumar',
        status: LiveOrderStatus.outForDelivery,
        isDelivery: true,
        minutesInStatus: 9,
      ),
      LiveOrder(
        number: 2289,
        customerName: 'Siti Aminah',
        status: LiveOrderStatus.ready,
        isDelivery: false,
        minutesInStatus: 15,
      ),
      LiveOrder(
        number: 2287,
        customerName: 'Farah Idris',
        status: LiveOrderStatus.pending,
        isDelivery: true,
        minutesInStatus: 22,
      ),
    ],
    activity: [
      ActivityEntry(message: 'Amir marked #2286 delivered', minutesAgo: 2),
      ActivityEntry(message: 'Daniel started packing #2291', minutesAgo: 4),
      ActivityEntry(message: 'Hakim started packing #2288', minutesAgo: 18),
      ActivityEntry(message: 'Firdaus picked up bag #2283', minutesAgo: 31),
    ],
  ),
  'bukit-jalil': DashboardSummary(
    ordersToday: 31,
    ordersYesterday: 34,
    ordersByHour: [2, 2, 3, 5, 4, 2, 1, 3, 4, 5],
    revenue: 1535,
    driversOnRoad: 2,
    totalDrivers: 4,
    liveOrders: [
      LiveOrder(
        number: 1178,
        customerName: 'Nurul Huda',
        status: LiveOrderStatus.outForDelivery,
        isDelivery: true,
        minutesInStatus: 12,
      ),
      LiveOrder(
        number: 1177,
        customerName: 'Kelvin Lim',
        status: LiveOrderStatus.packing,
        isDelivery: false,
        minutesInStatus: 6,
      ),
      LiveOrder(
        number: 1176,
        customerName: 'Priya Nair',
        status: LiveOrderStatus.pending,
        isDelivery: true,
        minutesInStatus: 3,
      ),
    ],
    activity: [
      ActivityEntry(message: 'Hafiz started packing #1177', minutesAgo: 6),
      ActivityEntry(message: 'Wei Jie left with #1178', minutesAgo: 12),
      ActivityEntry(message: 'Hafiz marked #1175 ready', minutesAgo: 40),
    ],
  ),
  'puchong': DashboardSummary(
    ordersToday: 18,
    ordersYesterday: 18,
    ordersByHour: [0, 1, 2, 3, 2, 1, 2, 3, 2, 2],
    revenue: 855,
    driversOnRoad: 1,
    totalDrivers: 3,
    liveOrders: [
      LiveOrder(
        number: 904,
        customerName: 'Aisyah Rahman',
        status: LiveOrderStatus.packing,
        isDelivery: true,
        minutesInStatus: 11,
      ),
      LiveOrder(
        number: 903,
        customerName: 'Jun Hao Lee',
        status: LiveOrderStatus.ready,
        isDelivery: false,
        minutesInStatus: 20,
      ),
    ],
    activity: [
      ActivityEntry(message: 'Syafiq started packing #904', minutesAgo: 11),
      ActivityEntry(message: 'Syafiq marked #903 ready', minutesAgo: 20),
    ],
  ),
};
