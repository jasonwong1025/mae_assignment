import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/orders/data/repositories/orders_repository.dart';
import 'package:mae_assignment/features/store_admin/orders/presentation/views/orders_view.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';
import '../../helpers/seed_data.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// 3 pm, so "minutes ago" orders in the seed data are still today.
final _now = DateTime(2026, 10, 16, 15);

OrdersRepository _repository(FakeFirebaseFirestore firestore) {
  return OrdersRepository(
    OrderService(firestore),
    StaffService(firestore),
    clock: () => _now,
  );
}

Future<FakeFirebaseFirestore> _pumpOrders(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final firestore = await seededFirestore(now: _now);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository()
            ..userToSignIn = _admin
            ..signedIn = true,
        ),
        branchServiceProvider.overrideWithValue(FakeBranchService()),
        firebaseFirestoreProvider.overrideWithValue(firestore),
        ordersRepositoryProvider.overrideWithValue(_repository(firestore)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const OrdersView()),
    ),
  );
  await tester.pumpAndSettle();
  return firestore;
}

void main() {
  group('OrdersRepository', () {
    test('lists the active packers of a branch, sorted by name', () async {
      final repository = _repository(await seededFirestore(now: _now));

      final packers = await repository.getPackers('ss15');

      // Nadia is deactivated; drivers and other branches are left out.
      expect(packers.map((p) => p.name), [
        'Bryan Ong',
        'Daniel Lee',
        'Hakim Roslan',
      ]);
      expect((await repository.getPackers('bukit-jalil')).map((p) => p.name), [
        'Hafiz Zainal',
      ]);
    });

    test('the board hides cancelled and old finished orders', () async {
      final firestore = await seededFirestore(now: _now);
      final repository = _repository(firestore);

      final orders = await repository.watchBoardOrders('ss15').first;

      expect(orders.any((o) => o.status == OrderStatus.cancelled), isFalse);
      // The seed has completed ss15 orders from earlier days; none are shown.
      final midnight = DateTime(_now.year, _now.month, _now.day);
      expect(
        orders
            .where((o) => o.status.isFinished)
            .every((o) => !o.statusStartedAt.isBefore(midnight)),
        isTrue,
      );
      expect(orders.any((o) => o.number == 2301), isTrue);
    });

    test('assigning a packer saves their id and name', () async {
      final firestore = await seededFirestore(now: _now);
      final repository = _repository(firestore);
      final hakim = (await repository.getPackers(
        'ss15',
      )).firstWhere((p) => p.name == 'Hakim Roslan');
      final order = (await repository.watchBoardOrders('ss15').first)
          .firstWhere((o) => o.number == 2287);

      await repository.assignPacker(order, hakim);

      final saved = (await OrderService(firestore).getOrder(order.id))!;
      expect(saved.packerId, hakim.id);
      expect(saved.packerName, 'Hakim Roslan');
    });
  });

  testWidgets('The admin assigns a packer from the order details', (
    tester,
  ) async {
    final firestore = await _pumpOrders(tester);

    // #2287 has no packer yet.
    await tester.tap(find.text('#2287'));
    await tester.pumpAndSettle();
    expect(find.text('No packer assigned'), findsOneWidget);

    await tester.tap(find.text('Assign packer'));
    await tester.pumpAndSettle();
    expect(find.text('Daniel Lee'), findsOneWidget);
    expect(find.text('Hakim Roslan'), findsOneWidget);
    expect(find.text('Bryan Ong'), findsOneWidget);
    // Deactivated and other-branch workers are not offered.
    expect(find.text('Nadia Yusof'), findsNothing);
    expect(find.text('Hafiz Zainal'), findsNothing);

    await tester.tap(find.text('Hakim Roslan'));
    await tester.pumpAndSettle();

    expect(find.text('Hakim Roslan will pack #2287.'), findsOneWidget);
    expect(find.text('Packer: Hakim Roslan'), findsOneWidget);
    final saved = await firestore.collection('orders').doc('ord-2287').get();
    expect(saved.data()!['packerName'], 'Hakim Roslan');
    expect(saved.data()!['packerId'], 'packer-hakim');
  });

  testWidgets('A finished order cannot be given a packer', (tester) async {
    await _pumpOrders(tester);

    // #2286 is a completed delivery.
    await tester.tap(find.text('#2286'));
    await tester.pumpAndSettle();

    expect(find.text('Assign packer'), findsNothing);
    expect(find.text('Change'), findsNothing);
  });
}
