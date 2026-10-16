import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/branches/presentation/views/branches_view.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/repositories/inventory_repository.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_image_picker_service.dart';
import '../../helpers/map_test_setup.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

/// Shows the Branches tab. Returns the providers.
Future<ProviderContainer> _pumpBranches(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = FakeAuthRepository()
    ..userToSignIn = _admin
    ..signedIn = true;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(theme: AppTheme.light, home: const BranchesView()),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(BranchesView)));
}

Branch _branch({String name = 'Test branch'}) {
  return Branch(
    id: '',
    name: name,
    address: '1, Jalan Test',
    phone: '03-1234 5678',
    location: const LatLng(3.1, 101.6),
    weeklyHours: List.filled(
      7,
      const DayHours(opensAt: 8 * 60, closesAt: 20 * 60),
    ),
    maxDeliveryKm: 5,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
  );
}

void main() {
  const desktop = Size(1600, 1000);
  const phone = Size(390, 844);

  setUpAll(mockMapTileCache);

  group('Branch', () {
    test('delivery fee rounds the km up and stops at the limit', () {
      final branch = _branch();

      // 3.2 km counts as 4 km: RM 3 + 4 x RM 0.50.
      expect(branch.deliveryFee(3.2), 5);
      expect(branch.deliveryFee(5), 5.5);
      expect(branch.deliveryFee(5.1), isNull);
    });

    test('hours are looked up by weekday', () {
      final branch = _branch();
      // 19 Oct 2026 is a Monday.
      expect(branch.hoursOn(DateTime(2026, 10, 19)).opensAt, 8 * 60);
    });
  });

  group('BranchRepository', () {
    test('adds a branch with a new id and keeps names unique', () async {
      final repository = BranchRepository();

      final added = await repository.addBranch(_branch());
      final all = await repository.getBranches();

      expect(added.id, isNotEmpty);
      expect(all.length, 4);
      expect(
        () => repository.addBranch(_branch(name: 'puchong')),
        throwsA(isA<BranchException>()),
      );
    });
  });

  test('a new branch gets every product with 0 stock', () async {
    final inventory = InventoryRepository(FakeImagePickerService());
    final before = await inventory.getItems('ss15');

    await inventory.addBranch('new-branch');
    final added = await inventory.getItems('new-branch');

    expect(added.totalCount, before.totalCount);
    expect(added.items.every((item) => item.stock == 0), isTrue);
  });

  testWidgets('Lists branches and opens the details', (tester) async {
    await _pumpBranches(tester, desktop);

    expect(find.text('1-3 of 3 branches'), findsOneWidget);
    await tester.tap(find.text('Puchong').last);
    await tester.pumpAndSettle();

    expect(find.text('OPENING HOURS'), findsOneWidget);
    // Puchong is closed on Sundays.
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('Temporarily closing a branch', (tester) async {
    final container = await _pumpBranches(tester, desktop);

    await tester.tap(find.text('Puchong').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Temporarily closed'), findsWidgets);
    final branches = await container
        .read(branchRepositoryProvider)
        .getBranches();
    expect(
      branches.firstWhere((b) => b.id == 'puchong').isTemporarilyClosed,
      isTrue,
    );
  });

  testWidgets('Phone shows cards', (tester) async {
    await _pumpBranches(tester, phone);

    expect(find.text('SS15 Subang'), findsOneWidget);
    expect(find.text('Bukit Jalil'), findsOneWidget);
  });
}
