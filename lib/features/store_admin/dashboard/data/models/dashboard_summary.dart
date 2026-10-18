import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';

/// Everything the dashboard shows for one branch, for today.
@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required int ordersToday,
    required int ordersYesterday,

    /// Order count for each hour since the branch opened.
    /// The last number is the current hour.
    required List<int> ordersByHour,

    /// Today's revenue in whole ringgit.
    required int revenue,
    required int driversOnRoad,
    required int totalDrivers,

    /// Orders that are not finished yet.
    required List<LiveOrder> liveOrders,

    /// Latest staff actions, newest first.
    required List<ActivityEntry> activity,
  }) = _DashboardSummary;

  const DashboardSummary._();
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
@freezed
abstract class LiveOrder with _$LiveOrder {
  const factory LiveOrder({
    required int number,
    required String customerName,
    required LiveOrderStatus status,

    /// True for delivery, false for pickup at the store.
    required bool isDelivery,

    /// How long the order has been in its current status.
    required int minutesInStatus,
  }) = _LiveOrder;

  const LiveOrder._();
}

/// One line of the activity list, e.g. "Amir marked #2286 delivered".
@freezed
abstract class ActivityEntry with _$ActivityEntry {
  const factory ActivityEntry({
    required String message,
    required int minutesAgo,
  }) = _ActivityEntry;

  const ActivityEntry._();
}
