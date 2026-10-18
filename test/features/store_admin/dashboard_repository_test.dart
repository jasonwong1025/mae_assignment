import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/dashboard/data/repositories/dashboard_repository.dart';

void main() {
  test('a sample branch has numbers', () async {
    final summary = await DashboardRepository().getSummary('ss15');

    expect(summary.ordersToday, greaterThan(0));
  });

  test('a branch added later gets an empty summary, not an error', () async {
    // A branch created in the Branches tab has a Firestore-generated id.
    final summary = await DashboardRepository().getSummary(
      'F199Np1dKRJ10bJH1aIF',
    );

    expect(summary.ordersToday, 0);
    expect(summary.revenue, 0);
    expect(summary.liveOrders, isEmpty);
    expect(summary.activity, isEmpty);
  });
}
