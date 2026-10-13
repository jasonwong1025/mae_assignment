import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/repositories/staff_repository.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/worker_card.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/views/staff_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// Shows the Staff tab on a screen of [size].
Future<void> _pumpStaff(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = FakeAuthRepository()
    ..userToSignIn = _admin
    ..signedIn = true;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.light, home: const StaffView()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Types [text] into the field labelled [label].
Future<void> _fill(WidgetTester tester, String label, String text) async {
  final field = find.descendant(
    of: find
        .ancestor(
          of: find.text(label.toUpperCase()),
          matching: find.byType(Column),
        )
        .first,
    matching: find.byType(TextFormField),
  );
  await tester.enterText(field, text);
}

void main() {
  const desktop = Size(1600, 900);
  const phone = Size(390, 844);

  group('StaffRepository', () {
    test('lists the branch packers and every driver', () async {
      final workers = await StaffRepository().getWorkers('puchong');
      final names = workers.map((worker) => worker.name);

      expect(names, contains('Syafiq Azman'));
      expect(names, contains('Amir Hamzah'));
      expect(names, isNot(contains('Daniel Lee')));
    });

    test('refuses an email that is already used', () async {
      final repository = StaffRepository();

      expect(
        () => repository.addWorker(
          name: 'Someone',
          email: 'Daniel.Lee@grocerly.my',
          phone: '0123456789',
          temporaryPassword: 'password1',
          role: WorkerRole.packingStaff,
          branchId: 'ss15',
        ),
        throwsA(isA<StaffException>()),
      );
    });
  });

  group('Worker', () {
    final packer = Worker(
      id: 'w1',
      name: 'Daniel Lee',
      email: 'daniel@grocerly.my',
      phone: '012-555 0141',
      role: WorkerRole.packingStaff,
      branchId: 'ss15',
      isActive: true,
      isOnDuty: true,
      currentOrderNumber: 2291,
      minutesOnCurrentOrder: 4,
      ordersToday: const [2289],
      joinedAt: DateTime(2025, 3, 12),
    );

    test('rightNow describes what the worker is doing', () {
      expect(packer.rightNow, 'Packing #2291');
      expect(packer.withActive(false).rightNow, 'Deactivated');
    });

    test('becoming a driver removes the branch', () {
      final driver = packer.withDetails(
        name: packer.name,
        email: packer.email,
        phone: packer.phone,
        role: WorkerRole.deliveryDriver,
        branchId: 'ss15',
      );

      expect(driver.branchId, isNull);
      expect(driver.rightNow, 'Delivering #2291');
    });

    test('search matches name, email and phone', () {
      expect(packer.matchesSearch('daniel'), isTrue);
      expect(packer.matchesSearch('GROCERLY.MY'), isTrue);
      expect(packer.matchesSearch('0125550141'), isTrue);
      expect(packer.matchesSearch('amir'), isFalse);
    });
  });

  testWidgets('Table lists the branch packers and all drivers', (tester) async {
    await _pumpStaff(tester, desktop);

    // SS15 packers.
    expect(find.text('Daniel Lee'), findsOneWidget);
    expect(find.text('Nadia Yusof'), findsOneWidget);
    // All drivers.
    expect(find.text('Lau Wei Jie'), findsOneWidget);
    expect(find.text('All branches'), findsNWidgets(4));
    // No packers from other branches.
    expect(find.text('Hafiz Zainal'), findsNothing);

    expect(find.text('Packing #2291'), findsOneWidget);
    expect(find.text('Deactivated'), findsNWidgets(2));
  });

  testWidgets('Search narrows the table', (tester) async {
    await _pumpStaff(tester, desktop);

    await tester.enterText(find.byType(TextField), 'amir');
    await tester.pumpAndSettle();

    expect(find.text('Amir Hamzah'), findsOneWidget);
    expect(find.text('Daniel Lee'), findsNothing);
  });

  testWidgets('Clicking a worker opens their details', (tester) async {
    await _pumpStaff(tester, desktop);

    await tester.tap(find.text('Amir Hamzah'));
    await tester.pumpAndSettle();

    expect(find.text('Delivering order #2290 for 9m'), findsOneWidget);
    expect(find.text('4.8 out of 5'), findsOneWidget);
    expect(find.text('amir.hamzah@grocerly.my'), findsOneWidget);
    expect(find.text('TODAY · 3 DELIVERED'), findsOneWidget);
  });

  testWidgets('Adding a worker puts them in the table', (tester) async {
    await _pumpStaff(tester, desktop);

    await tester.tap(find.text('Add worker'));
    await tester.pumpAndSettle();

    await _fill(tester, 'Full name', 'Aina Zulkifli');
    await _fill(tester, 'Email', 'aina@grocerly.my');
    await _fill(tester, 'Phone number', '012-345 6789');
    await _fill(tester, 'Temporary password', 'password1');
    await tester.tap(find.widgetWithText(FilledButton, 'Add worker').last);
    await tester.pumpAndSettle();

    expect(find.text('Aina Zulkifli'), findsOneWidget);
    expect(find.text('Aina Zulkifli was added.'), findsOneWidget);
  });

  testWidgets('The add form rejects a bad email', (tester) async {
    await _pumpStaff(tester, desktop);

    await tester.tap(find.text('Add worker'));
    await tester.pumpAndSettle();
    await _fill(tester, 'Full name', 'Aina Zulkifli');
    await _fill(tester, 'Email', 'not-an-email');
    await tester.tap(find.widgetWithText(FilledButton, 'Add worker').last);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Aina Zulkifli was added.'), findsNothing);
  });

  testWidgets('Editing changes a worker to a driver', (tester) async {
    await _pumpStaff(tester, desktop);

    await tester.tap(find.text('Daniel Lee'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delivery Driver').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Daniel Lee was saved.'), findsOneWidget);
    expect(find.text('Delivering #2291'), findsOneWidget);
    // Five drivers in the table, plus the open panel.
    expect(find.text('All branches'), findsNWidgets(6));
  });

  testWidgets('Deactivating asks first, then updates the row', (tester) async {
    await _pumpStaff(tester, desktop);

    await tester.tap(find.text('Hakim Roslan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();

    expect(find.text('Deactivate Hakim Roslan?'), findsOneWidget);
    await tester.tap(find.text('Deactivate').last);
    await tester.pumpAndSettle();

    expect(find.text('Hakim Roslan was deactivated.'), findsOneWidget);
    expect(find.text('Reactivate'), findsOneWidget);
    expect(find.text('Packing #2288'), findsNothing);
  });

  testWidgets('Phone shows cards and opens details as a page', (tester) async {
    await _pumpStaff(tester, phone);

    expect(find.byType(WorkerCard), findsWidgets);
    expect(find.text('Daniel Lee'), findsOneWidget);

    await tester.tap(find.text('Daniel Lee'));
    await tester.pumpAndSettle();

    expect(find.text('daniel.lee@grocerly.my'), findsOneWidget);
    expect(find.byType(WorkerCard), findsNothing);
  });
}
