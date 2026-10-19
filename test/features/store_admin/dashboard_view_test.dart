import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/dashboard/data/repositories/dashboard_repository.dart';
import 'package:mae_assignment/features/store_admin/dashboard/presentation/views/dashboard_view.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
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

/// The dashboard with a signed-in fake admin, on a screen of [size].
Future<void> _pumpDashboard(
  WidgetTester tester,
  Size size, {
  FakeBranchService? branches,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = FakeAuthRepository()
    ..userToSignIn = _admin
    ..signedIn = true;

  final firestore = await seededFirestore(now: _now);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        branchServiceProvider.overrideWithValue(
          branches ?? FakeBranchService(),
        ),
        firebaseFirestoreProvider.overrideWithValue(firestore),
        dashboardRepositoryProvider.overrideWithValue(
          DashboardRepository(
            OrderService(firestore),
            StaffService(firestore),
            clock: () => _now,
          ),
        ),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const DashboardView()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const tablet = Size(1280, 800);
  const phone = Size(390, 844);

  testWidgets('Tablet shows the sidebar and the first branch', (tester) async {
    await _pumpDashboard(tester, tablet);

    expect(find.text('SS15 Subang'), findsOneWidget);
    expect(find.text('Sales & revenue'), findsOneWidget);
    expect(find.text('Jason Kok'), findsOneWidget);
    expect(find.textContaining(', Jason'), findsOneWidget);

    expect(find.textContaining('orders today'), findsOneWidget);
    expect(find.textContaining('revenue today'), findsOneWidget);
    expect(find.text('Mei Ling Tan'), findsWidgets);
    expect(find.text('Daniel Lee started packing #2291'), findsOneWidget);
  });

  testWidgets('A branch added in the app opens with an empty dashboard', (
    tester,
  ) async {
    // A branch created in the Branches tab gets a Firestore-generated id,
    // which has no sample numbers.
    final branches = FakeBranchService();
    branches.branches[0] = Branch(
      id: 'F199Np1dKRJ10bJH1aIF',
      name: 'New Town',
      address: '1 Jalan Baru',
      phone: '03-0000 0000',
      location: const LatLng(3.1, 101.6),
      weeklyHours: branches.branches[0].weeklyHours,
      maxDeliveryKm: 5,
      baseDeliveryFee: 3,
      feePerKm: 0.5,
    );

    await _pumpDashboard(tester, tablet, branches: branches);

    expect(tester.takeException(), isNull);
    expect(find.text('New Town'), findsWidgets);
    expect(find.text('0'), findsWidgets);
    expect(find.text('Mei Ling Tan'), findsNothing);
  });

  testWidgets("Switching branch shows that branch's numbers", (tester) async {
    await _pumpDashboard(tester, tablet);

    await tester.tap(find.byTooltip('Switch branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bukit Jalil'));
    await tester.pumpAndSettle();

    expect(find.text('Mei Ling Tan'), findsNothing);
    expect(find.text('Nurul Huda'), findsWidgets);
  });

  testWidgets('The current page is highlighted in the sidebar', (tester) async {
    await _pumpDashboard(tester, tablet);

    final dashboard = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Dashboard'),
    );
    final sales = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Sales & revenue'),
    );

    expect(dashboard.selected, isTrue);
    expect(sales.selected, isFalse);
  });

  testWidgets('Phone keeps the sidebar in a drawer', (tester) async {
    await _pumpDashboard(tester, phone);

    // The sidebar is hidden, the dashboard is still there.
    expect(find.text('Sales & revenue'), findsNothing);
    expect(find.textContaining('orders today'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Sales & revenue'), findsOneWidget);
    expect(find.text('SS15 Subang'), findsOneWidget);
  });
}
