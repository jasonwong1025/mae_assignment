import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/repositories/dispatch_repository.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/services/driver_location_service.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/deliveries_table.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/views/dispatch_view.dart';
import 'package:mae_assignment/features/store_admin/orders/data/repositories/orders_repository.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/map_test_setup.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// Shows the Dispatch tab on a screen of [size]. Returns the providers.
Future<ProviderContainer> _pumpDispatch(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = FakeAuthRepository()
    ..userToSignIn = _admin
    ..signedIn = true;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.light, home: const DispatchView()),
    ),
  );
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(DispatchView)));
}

/// Lets the data load. Not pumpAndSettle: the moving drivers never settle.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(mockMapTileCache);

  const desktop = Size(1600, 1000);
  const phone = Size(390, 844);

  group('DispatchRepository', () {
    test('assigning a driver updates the order and the driver', () async {
      final orders = OrdersRepository();
      final repository = DispatchRepository(orders, DriverLocationService());
      final branch = (await BranchRepository().getBranches()).first;
      final drivers = await repository.getDrivers();
      final kumar = drivers.firstWhere((d) => d.name == 'Kumar Selvam');
      final amir = drivers.firstWhere((d) => d.name == 'Amir Hamzah');

      final deliveries = await repository.watchDeliveries('ss15').first;
      final order = deliveries.firstWhere((o) => o.number == 2292);
      await repository.assignDriver(
        branch: branch,
        order: order,
        driver: kumar,
      );

      final updated = (await orders.watchTodaysOrders('ss15').first).firstWhere(
        (o) => o.number == 2292,
      );
      expect(updated.driverId, kumar.id);
      expect(updated.assignedWorker, 'Kumar');
      expect(updated.timeline.last.title, 'Driver Kumar assigned');

      final kumarNow = (await repository.getDrivers()).firstWhere(
        (d) => d.id == kumar.id,
      );
      expect(kumarNow.currentOrderNumber, 2292);

      // A busy driver cannot take another order.
      expect(
        () =>
            repository.assignDriver(branch: branch, order: order, driver: amir),
        throwsA(isA<DispatchException>()),
      );
    });

    test('reassigning sets the old driver free', () async {
      final repository = DispatchRepository(
        OrdersRepository(),
        DriverLocationService(),
      );
      final branch = (await BranchRepository().getBranches()).first;
      final drivers = await repository.getDrivers();
      final amir = drivers.firstWhere((d) => d.name == 'Amir Hamzah');
      final kumar = drivers.firstWhere((d) => d.name == 'Kumar Selvam');

      final deliveries = await repository.watchDeliveries('ss15').first;
      final order = deliveries.firstWhere((o) => o.number == 2290);
      await repository.assignDriver(
        branch: branch,
        order: order,
        driver: kumar,
        oldDriver: amir,
      );

      final amirNow = (await repository.getDrivers()).firstWhere(
        (d) => d.id == amir.id,
      );
      expect(amirNow.currentOrderNumber, isNull);
    });
  });

  test('Drivers move toward their next stop', () async {
    final service = DriverLocationService();
    final updates = <LatLng>[];
    final subscription = service.watchLocations().listen(
      (locations) => updates.add(locations['w10']!.position),
    );

    service.setStops('w10', [const LatLng(3.0757, 101.5869)]);
    // One move happens every 2 seconds.
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    expect(updates.length, greaterThanOrEqualTo(2));
    expect(updates.last, isNot(updates.first));

    unawaited(subscription.cancel());
    service.dispose();
  });

  testWidgets('Shows drivers, orders needing a driver and the map', (
    tester,
  ) async {
    await _pumpDispatch(tester, desktop);

    expect(find.text('Dispatch'), findsWidgets);
    expect(find.textContaining('9 free · 3 busy · 2 offline'), findsOneWidget);
    expect(find.text('NEEDS A DRIVER (2)'), findsOneWidget);
    expect(find.text('#2284 · Ahmad Fauzi'), findsOneWidget);
    expect(find.text('Amir Hamzah'), findsOneWidget);
    expect(find.text('Delivering #2290'), findsOneWidget);
    // Map labels.
    expect(find.text('SS15 Subang'), findsWidgets);
    expect(find.text('Amir · #2290'), findsOneWidget);
  });

  testWidgets('Assigning the nearest free driver', (tester) async {
    final container = await _pumpDispatch(tester, desktop);

    await tester.tap(find.text('#2292 · Ooi Hui Min'));
    await _settle(tester);
    expect(find.text('ASSIGN #2292'), findsOneWidget);
    // Kumar is the closest free driver to SS15.
    expect(find.textContaining('Kumar Selvam · '), findsWidgets);

    await tester.tap(find.text('Assign driver'));
    await _settle(tester);

    expect(find.text('#2292 assigned to Kumar Selvam.'), findsOneWidget);
    expect(find.text('NEEDS A DRIVER (1)'), findsOneWidget);

    // The Orders tab sees the same change.
    final orders = await container
        .read(ordersRepositoryProvider)
        .watchTodaysOrders('ss15')
        .first;
    expect(orders.firstWhere((o) => o.number == 2292).assignedWorker, 'Kumar');
  });

  testWidgets('List view shows a table of deliveries', (tester) async {
    await _pumpDispatch(tester, desktop);

    await tester.tap(find.text('List view'));
    await _settle(tester);

    expect(find.byType(DeliveriesTable), findsOneWidget);
    expect(find.text('ARRIVES IN'), findsOneWidget);
    expect(find.text('#2285'), findsOneWidget);
    expect(find.text('1-4 of 4 deliveries'), findsOneWidget);
  });

  testWidgets('Phone opens the assign box in a sheet', (tester) async {
    await _pumpDispatch(tester, phone);

    await tester.tap(find.text('Orders (4)'));
    await _settle(tester);
    await tester.tap(find.text('#2284 · Ahmad Fauzi'));
    await _settle(tester);

    expect(find.text('ASSIGN #2284'), findsOneWidget);
    expect(find.text('Assign driver'), findsOneWidget);
  });
}
