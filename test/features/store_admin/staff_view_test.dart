import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/repositories/staff_repository.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/ui/worker_card.dart';
import 'package:mae_assignment/features/store_admin/staff/presentation/views/staff_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';
import '../../helpers/fake_staff_service.dart';

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
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        branchServiceProvider.overrideWithValue(FakeBranchService()),
        staffServiceProvider.overrideWithValue(FakeStaffService()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const StaffView()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Types [text] into the form field labelled [label].
Future<void> _fill(WidgetTester tester, String label, String text) async {
  final field = find.descendant(
    of: find
        .ancestor(
          of: find.descendant(
            of: find.byType(Form),
            matching: find.text(label.toUpperCase()),
          ),
          matching: find.byType(Column),
        )
        .first,
    matching: find.byType(TextFormField),
  );
  await tester.enterText(field, text);
}

void main() {
  // Tall enough to show a full page of 20 rows.
  const desktop = Size(1600, 1500);
  const phone = Size(390, 844);

  group('StaffRepository', () {
    test('lists the branch packers and every driver', () async {
      final result = await StaffRepository(
        FakeStaffService(),
      ).getWorkers('puchong');
      final names = result.items.map((worker) => worker.name);

      // 3 Puchong packers and 14 drivers.
      expect(result.totalCount, 17);
      expect(names, contains('Syafiq Azman'));
      expect(names, contains('Amir Hamzah'));
      expect(names, isNot(contains('Daniel Lee')));
    });

    test('returns pages of 20, packers first', () async {
      final repository = StaffRepository(FakeStaffService());

      final first = await repository.getWorkers('ss15');
      final second = await repository.getWorkers('ss15', page: 2);

      // 12 SS15 packers and 14 drivers.
      expect(first.totalCount, 26);
      expect(first.pageCount, 2);
      expect(first.items.length, 20);
      expect(first.items.first.role, WorkerRole.packingStaff);
      expect(second.items.length, 6);
      expect(second.items.every((worker) => worker.isDriver), isTrue);
    });

    test('search looks through every page', () async {
      final result = await StaffRepository(
        FakeStaffService(),
      ).getWorkers('ss15', searchText: 'tan wei loon');

      expect(result.items.single.name, 'Tan Wei Loon');
    });

    test('refuses an email that is already used', () async {
      final repository = StaffRepository(FakeStaffService());

      expect(
        () => repository.addWorker(
          name: 'Someone',
          email: 'daniel.lee@grocerly.my',
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
      joinedAt: DateTime(2025, 3, 12),
    );

    test('saves the fields the rules expect', () {
      final map = packer.toMap();
      expect(map['role'], 'storeWorker');
      expect(map['workerRole'], 'packingStaff');
      expect(map['branchId'], 'ss15');
      expect(Worker.fromMap('w1', map).name, 'Daniel Lee');
    });

    test('becoming a driver removes the branch', () {
      final driver = packer.withDetails(
        name: packer.name,
        phone: packer.phone,
        role: WorkerRole.deliveryDriver,
        branchId: 'ss15',
      );

      expect(driver.branchId, isNull);
      expect(driver.email, packer.email);
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
    // No packers from other branches.
    expect(find.text('Hafiz Zainal'), findsNothing);
    // 12 packers fill the page first, so 8 of the 14 drivers fit.
    expect(find.text('Amir Hamzah'), findsOneWidget);
    expect(find.text('All branches'), findsNWidgets(8));

    // Nadia; the deactivated driver is on page 2.
    expect(find.text('Deactivated'), findsOneWidget);
    expect(find.text('1-20 of 26 workers'), findsOneWidget);
  });

  testWidgets('Page 2 shows the rest of the drivers', (tester) async {
    await _pumpStaff(tester, desktop);
    expect(find.text('Lau Wei Jie'), findsNothing);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();

    expect(find.text('21-26 of 26 workers'), findsOneWidget);
    expect(find.text('Lau Wei Jie'), findsOneWidget);
    expect(find.text('Daniel Lee'), findsNothing);
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

    // Once in the table, once in the panel.
    expect(find.text('amir.hamzah@grocerly.my'), findsNWidgets(2));
    expect(find.text('Delivery Driver'), findsWidgets);
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
    // 11 packers now, so 9 drivers fit on the page, plus the open panel.
    expect(find.text('All branches'), findsNWidgets(10));
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
