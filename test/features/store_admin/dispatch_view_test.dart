import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/repositories/dispatch_repository.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/services/driver_location_service.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/ui/deliveries_table.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_view_model.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/views/dispatch_view.dart';
import 'package:mae_assignment/features/store_admin/orders/data/repositories/orders_repository.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';
import '../../helpers/map_test_setup.dart';
import '../../helpers/seed_data.dart';

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
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        branchServiceProvider.overrideWithValue(FakeBranchService()),
        firebaseFirestoreProvider.overrideWithValue(await seededFirestore()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const DispatchView()),
    ),
  );
  await _settle(tester);
  return ProviderScope.containerOf(tester.element(find.byType(DispatchView)));
}

/// Lets the data load.
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
    Future<(DispatchRepository, OrderService)> repositoryFor() async {
      final firestore = await seededFirestore();
      final orders = OrderService(firestore);
      return (
        DispatchRepository(
          orders,
          StaffService(firestore),
          DriverLocationService(firestore),
        ),
        orders,
      );
    }

    test('lists the active drivers, not the deactivated ones', () async {
      final (repository, _) = await repositoryFor();

      final names = [for (final d in await repository.getDrivers()) d.name];

      expect(names, contains('Kumar Selvam'));
      expect(names, isNot(contains('Ridzuan Ali')));
    });

    test('assigning a driver updates the order', () async {
      final (repository, orders) = await repositoryFor();
      final drivers = await repository.getDrivers();
      final kumar = drivers.firstWhere((d) => d.name == 'Kumar Selvam');
      final amir = drivers.firstWhere((d) => d.name == 'Amir Hamzah');

      final deliveries = await repository.watchActiveDeliveries().first;
      final order = deliveries.firstWhere((o) => o.number == 2292);
      await repository.assignDriver(
        order: order,
        driver: kumar,
        activeOrders: 0,
        maxActiveOrders: 3,
      );

      final updated = (await orders.getOrder(order.id))!;
      expect(updated.driverId, kumar.id);
      expect(updated.handledBy, 'Kumar');
      expect(updated.timeline.last.title, 'Driver Kumar assigned');

      // A driver already holding the most deliveries cannot take another.
      expect(
        () => repository.assignDriver(
          order: order,
          driver: amir.withCurrentOrder(2290),
          activeOrders: 3,
          maxActiveOrders: 3,
        ),
        throwsA(isA<DispatchException>()),
      );
    });

    test('reassigning moves the order to the new driver', () async {
      final (repository, orders) = await repositoryFor();
      final kumar = (await repository.getDrivers()).firstWhere(
        (d) => d.name == 'Kumar Selvam',
      );

      final deliveries = await repository.watchActiveDeliveries().first;
      final order = deliveries.firstWhere((o) => o.number == 2290);
      expect(order.driverId, 'driver-amir');
      await repository.assignDriver(
        order: order,
        driver: kumar,
        activeOrders: 0,
        maxActiveOrders: 3,
      );

      expect((await orders.getOrder(order.id))!.driverId, kumar.id);
    });

    test('an order with no address on the map is refused', () async {
      final (repository, _) = await repositoryFor();
      final kumar = (await repository.getDrivers()).firstWhere(
        (d) => d.name == 'Kumar Selvam',
      );
      final deliveries = await repository.watchActiveDeliveries().first;
      final order = deliveries.firstWhere((o) => o.number == 2292);

      expect(
        () => repository.assignDriver(
          order: order.copyWith(addressLocation: null),
          driver: kumar,
          activeOrders: 0,
          maxActiveOrders: 3,
        ),
        throwsA(isA<DispatchException>()),
      );
    });
  });

  testWidgets('Shows drivers, orders needing a driver and the map', (
    tester,
  ) async {
    await _pumpDispatch(tester, desktop);

    expect(find.text('Dispatch'), findsWidgets);
    expect(find.textContaining('4 free · 4 busy · 0 offline'), findsOneWidget);
    expect(find.text('NEEDS A DRIVER (2)'), findsOneWidget);
    expect(find.text('#2284 · Ahmad Fauzi'), findsOneWidget);
    expect(find.text('Amir Hamzah'), findsOneWidget);
    // Amir holds four deliveries in the demo data (#2290 and #2309 on the
    // road, #2308 and #1184 ready to collect); the line follows the first.
    expect(find.text('Delivering #2290 +3 more'), findsOneWidget);
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
        .watchBoardOrders('ss15')
        .first;
    expect(orders.firstWhere((o) => o.number == 2292).handledBy, 'Kumar');
  });

  testWidgets('Auto-assign gives each waiting order a free driver', (
    tester,
  ) async {
    final container = await _pumpDispatch(tester, desktop);

    await tester.tap(find.byKey(const Key('dispatch_auto_assign')));
    await _settle(tester);

    // #2284 waited longest, so it gets the nearest free driver. Kumar then
    // has one delivery, so #2292 goes to the next nearest free driver.
    expect(
      find.text('Assigned #2284 to Kumar, #2292 to Jason.'),
      findsOneWidget,
    );
    expect(find.text('NEEDS A DRIVER (0)'), findsOneWidget);

    final orders = await container
        .read(ordersRepositoryProvider)
        .watchBoardOrders('ss15')
        .first;
    expect(orders.firstWhere((o) => o.number == 2284).handledBy, 'Kumar');
    expect(orders.firstWhere((o) => o.number == 2292).handledBy, 'Jason');
  });

  testWidgets('Auto-assign never gives a driver more than three', (
    tester,
  ) async {
    final container = await _pumpDispatch(tester, desktop);
    final state = container.read(dispatchViewModelProvider).requireValue;
    final kumar = state.drivers.firstWhere(
      (d) => d.worker.name == 'Kumar Selvam',
    );

    // Only Kumar is left, with room for one more: only #2284 gets him.
    final onlyOne = state.copyWith(drivers: [kumar.copyWith(activeOrders: 2)]);
    expect([for (final (o, _) in onlyOne.autoAssignPlan) o.number], [2284]);

    // With no room at all, nobody is given the orders.
    final full = state.copyWith(drivers: [kumar.copyWith(activeOrders: 3)]);
    expect(full.autoAssignPlan, isEmpty);
  });

  testWidgets('List view shows a table of deliveries', (tester) async {
    await _pumpDispatch(tester, desktop);

    await tester.tap(find.text('List view'));
    await _settle(tester);

    expect(find.byType(DeliveriesTable), findsOneWidget);
    expect(find.text('ARRIVES IN'), findsOneWidget);
    expect(find.text('#2285'), findsOneWidget);
    expect(find.text('1-6 of 6 deliveries'), findsOneWidget);
  });

  testWidgets('Phone opens the assign box in a sheet', (tester) async {
    await _pumpDispatch(tester, phone);

    await tester.tap(find.text('Orders (6)'));
    await _settle(tester);
    await tester.tap(find.text('#2284 · Ahmad Fauzi'));
    await _settle(tester);

    expect(find.text('ASSIGN #2284'), findsOneWidget);
    expect(find.text('Assign driver'), findsOneWidget);
  });
}
