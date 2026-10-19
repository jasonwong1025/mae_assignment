import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/dashboard/data/models/dashboard_summary.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    ref.watch(orderServiceProvider),
    ref.watch(staffServiceProvider),
  );
});

/// Error with a message to show on screen.
class DashboardException extends AppException {
  const DashboardException(super.message);
}

/// Dashboard numbers for the store admin, worked out from the branch's real
/// orders and the active drivers, so a branch with no orders yet simply
/// shows zeros.
class DashboardRepository {
  DashboardRepository(this._orders, this._staff, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final OrderService _orders;
  final StaffService _staff;
  final DateTime Function() _clock;

  /// How many staff actions the activity list shows.
  static const int _activityCount = 6;

  /// Today's numbers for one branch. [openingHour] is the hour of the first
  /// bar in the orders-by-hour chart (24-hour clock).
  Future<DashboardSummary> getSummary(
    String branchId, {
    required int openingHour,
  }) {
    return guard(
      () async {
        final clock = _clock();
        final today = DateTime(clock.year, clock.month, clock.day);
        final yesterday = DateTime(clock.year, clock.month, clock.day - 1);
        final tomorrow = DateTime(clock.year, clock.month, clock.day + 1);

        final recent = await _orders.getBranchOrdersBetween(
          branchId,
          yesterday,
          tomorrow,
        );
        final unfinished = await _orders.getActiveBranchOrders(branchId);
        final workers = await _staff.getWorkers();

        // Cancelled orders were never fulfilled, so they are not counted.
        final placed = [
          for (final order in recent)
            if (order.status != OrderStatus.cancelled) order,
        ];
        final todays = [
          for (final order in placed)
            if (!_placedAt(order).isBefore(today)) order,
        ];
        final yesterdays = placed.length - todays.length;

        final onRoad = {
          for (final order in unfinished)
            if (order.status == OrderStatus.outForDelivery &&
                order.driverId != null)
              order.driverId,
        };

        return DashboardSummary(
          ordersToday: todays.length,
          ordersYesterday: yesterdays,
          ordersByHour: _ordersByHour(todays, openingHour, clock),
          revenue: todays
              .fold<double>(0, (sum, order) => sum + order.total)
              .round(),
          driversOnRoad: onRoad.length,
          totalDrivers: workers
              .where((worker) => worker.isDriver && worker.isActive)
              .length,
          liveOrders: _liveOrders(unfinished, clock),
          activity: _activity(todays, clock),
        );
      },
      label: 'dashboard',
      onError: () => const DashboardException(
        'Could not load the dashboard. Please try again.',
      ),
    );
  }

  static DateTime _placedAt(Order order) =>
      order.placedAt ?? order.statusStartedAt;

  /// Orders placed in each hour from [openingHour] to the current hour.
  /// Empty before the branch opens.
  static List<int> _ordersByHour(
    List<Order> todays,
    int openingHour,
    DateTime now,
  ) {
    if (now.hour < openingHour) return const [];
    final counts = List<int>.filled(now.hour - openingHour + 1, 0);
    for (final order in todays) {
      final index = _placedAt(order).hour - openingHour;
      if (index >= 0 && index < counts.length) counts[index]++;
    }
    return counts;
  }

  /// Unfinished orders, the longest waiting first.
  static List<LiveOrder> _liveOrders(List<Order> unfinished, DateTime now) {
    final sorted = [...unfinished]
      ..sort((a, b) => a.statusStartedAt.compareTo(b.statusStartedAt));
    return [
      for (final order in sorted)
        LiveOrder(
          number: order.number,
          customerName: order.customerName,
          status: order.status,
          isDelivery: order.isDelivery,
          minutesInStatus: order.minutesInStatus(now),
        ),
    ];
  }

  /// The latest staff actions on today's orders, newest first, in words
  /// like "Amir marked #2286 delivered".
  static List<ActivityEntry> _activity(List<Order> todays, DateTime now) {
    final events = <(DateTime, String)>[];
    for (final order in todays) {
      for (final event in order.timeline) {
        final by = event.by;
        if (by == null) continue;
        events.add((event.time, _describe(by, event.title, order.number)));
      }
    }
    events.sort((a, b) => b.$1.compareTo(a.$1));
    return [
      for (final (time, message) in events.take(_activityCount))
        ActivityEntry(
          message: message,
          minutesAgo: now.difference(time).inMinutes.clamp(0, 1 << 20),
        ),
    ];
  }

  /// A timeline step as a sentence, e.g. "Amir marked #2286 delivered".
  static String _describe(String by, String title, int number) {
    if (title.startsWith('Driver ') && title.endsWith(' assigned')) {
      final driver = title.substring(7, title.length - 9);
      return '$by assigned $driver to #$number';
    }
    return switch (title) {
      'Packing started' => '$by started packing #$number',
      'Ready for delivery' || 'Ready for pickup' => '$by marked #$number ready',
      'Out for delivery' => '$by started delivering #$number',
      'Delivered' => '$by marked #$number delivered',
      'Picked up' => '$by handed over #$number',
      _ => '$by: ${title.toLowerCase()} #$number',
    };
  }
}
