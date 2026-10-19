import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/dashboard/data/repositories/dashboard_repository.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../../helpers/seed_data.dart';

/// 3 pm, so "minutes ago" orders in the seed data are still today.
final _now = DateTime(2026, 10, 16, 15);

DashboardRepository _repository(FakeFirebaseFirestore firestore) {
  return DashboardRepository(
    OrderService(firestore),
    StaffService(firestore),
    clock: () => _now,
  );
}

void main() {
  test("works out the numbers from the branch's real orders", () async {
    final repository = _repository(await seededFirestore(now: _now));

    final summary = await repository.getSummary('ss15', openingHour: 8);

    // Every unfinished SS15 order is listed, the longest waiting first.
    expect(summary.liveOrders, isNotEmpty);
    expect(
      summary.liveOrders.every((order) => !order.status.isFinished),
      isTrue,
    );
    expect(
      summary.liveOrders.map((order) => order.customerName),
      contains('Mei Ling Tan'),
    );
    final waits = [for (final o in summary.liveOrders) o.minutesInStatus];
    expect(waits, [...waits]..sort((a, b) => b.compareTo(a)));

    // Orders placed today are counted, and so is their money.
    expect(summary.ordersToday, greaterThan(0));
    expect(summary.revenue, greaterThan(0));

    // One bar per hour from opening to now (8:00 to 15:00).
    expect(summary.ordersByHour, hasLength(8));
    expect(
      summary.ordersByHour.fold<int>(0, (sum, count) => sum + count),
      lessThanOrEqualTo(summary.ordersToday),
    );

    // Drivers: only the active ones count; the busy ones are on the road.
    expect(summary.totalDrivers, 8);
    expect(summary.driversOnRoad, greaterThan(0));
    expect(summary.driversOnRoad, lessThanOrEqualTo(summary.totalDrivers));
  });

  test('activity is worded from the order timeline, newest first', () async {
    final repository = _repository(await seededFirestore(now: _now));

    final summary = await repository.getSummary('ss15', openingHour: 8);

    expect(summary.activity, isNotEmpty);
    expect(
      summary.activity.map((entry) => entry.message),
      contains('Daniel Lee started packing #2291'),
    );
    final ages = [for (final e in summary.activity) e.minutesAgo];
    expect(ages, [...ages]..sort());
  });

  test('cancelled orders are not counted or listed', () async {
    final firestore = await seededFirestore(now: _now);
    final repository = _repository(firestore);
    final before = await repository.getSummary('ss15', openingHour: 8);

    await firestore.collection('orders').doc('ord-2301').update({
      'status': OrderStatus.cancelled.name,
    });
    final after = await repository.getSummary('ss15', openingHour: 8);

    expect(after.ordersToday, before.ordersToday - 1);
    expect(after.liveOrders.length, before.liveOrders.length - 1);
  });

  test('a branch with no orders gets zeros, not an error', () async {
    // A branch created in the Branches tab has a Firestore-generated id.
    final repository = _repository(await seededFirestore(now: _now));

    final summary = await repository.getSummary(
      'F199Np1dKRJ10bJH1aIF',
      openingHour: 8,
    );

    expect(summary.ordersToday, 0);
    expect(summary.ordersYesterday, 0);
    expect(summary.revenue, 0);
    expect(summary.liveOrders, isEmpty);
    expect(summary.activity, isEmpty);
    expect(summary.ordersByHour, everyElement(0));
  });

  test('the chart is empty before the branch opens', () async {
    final repository = DashboardRepository(
      OrderService(FakeFirebaseFirestore()),
      StaffService(FakeFirebaseFirestore()),
      clock: () => DateTime(2026, 10, 16, 6),
    );

    final summary = await repository.getSummary('ss15', openingHour: 8);

    expect(summary.ordersByHour, isEmpty);
  });
}
