/// Everything the dashboard shows for one branch, for today.
class DashboardSummary {
  const DashboardSummary({
    required this.ordersToday,
    required this.ordersYesterday,
    required this.ordersByHour,
    required this.cashRevenue,
    required this.onlineRevenue,
    required this.driversOnRoad,
    required this.totalDrivers,
    required this.liveOrders,
    required this.activity,
  });

  final int ordersToday;
  final int ordersYesterday;

  /// Order count for each hour since the branch opened.
  /// The last number is the current hour.
  final List<int> ordersByHour;

  /// Revenue in whole ringgit.
  final int cashRevenue;
  final int onlineRevenue;

  final int driversOnRoad;
  final int totalDrivers;

  /// Orders that are not finished yet.
  final List<LiveOrder> liveOrders;

  /// Latest staff actions, newest first.
  final List<ActivityEntry> activity;

  int get totalRevenue => cashRevenue + onlineRevenue;
}

/// Where an unfinished order is right now.
enum LiveOrderStatus {
  pending('Pending'),
  packing('Packing'),
  ready('Ready'),
  outForDelivery('Out for delivery');

  const LiveOrderStatus(this.label);

  /// Name shown to the admin, e.g. "Out for delivery".
  final String label;
}

/// One row of the "Right now" list.
class LiveOrder {
  const LiveOrder({
    required this.number,
    required this.customerName,
    required this.status,
    required this.isDelivery,
    required this.minutesInStatus,
  });

  final int number;
  final String customerName;
  final LiveOrderStatus status;

  /// True for delivery, false for pickup at the store.
  final bool isDelivery;

  /// How long the order has been in its current status.
  final int minutesInStatus;
}

/// One line of the activity list, e.g. "Amir marked #2286 delivered".
class ActivityEntry {
  const ActivityEntry({required this.message, required this.minutesAgo});

  final String message;
  final int minutesAgo;
}
