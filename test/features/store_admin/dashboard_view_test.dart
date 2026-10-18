import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/app/theme/app_theme.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_admin/dashboard/presentation/views/dashboard_view.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';

const _admin = AppUser(
  uid: 'uid-1',
  name: 'Jason Kok',
  email: 'jason@example.com',
  phone: '0123456789',
  role: UserRole.storeAdmin,
);

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

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        branchServiceProvider.overrideWithValue(
          branches ?? FakeBranchService(),
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

    expect(find.text('47'), findsOneWidget);
    expect(find.text('orders today · up 12 vs yesterday'), findsOneWidget);
    expect(find.textContaining('RM 2,384 revenue today'), findsOneWidget);
    expect(find.text('Mei Ling Tan'), findsOneWidget);
    expect(find.text('Amir marked #2286 delivered'), findsOneWidget);
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
    expect(find.text('47'), findsNothing);
  });

  testWidgets("Switching branch shows that branch's numbers", (tester) async {
    await _pumpDashboard(tester, tablet);

    await tester.tap(find.byTooltip('Switch branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bukit Jalil'));
    await tester.pumpAndSettle();

    expect(find.text('47'), findsNothing);
    expect(find.text('31'), findsOneWidget);
    expect(find.text('orders today · down 3 vs yesterday'), findsOneWidget);
    expect(find.text('Nurul Huda'), findsOneWidget);
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
    expect(find.text('47'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Sales & revenue'), findsOneWidget);
    expect(find.text('SS15 Subang'), findsOneWidget);
  });
}
