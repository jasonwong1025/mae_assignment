import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_branch_service.dart';
import '../../helpers/seed_data.dart';

void main() {
  testWidgets('Admin signs in, lands on the dashboard and opens Orders', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = FakeAuthRepository()
      ..userToSignIn = const AppUser(
        uid: 'uid-1',
        name: 'Jason Kok',
        email: 'jason@example.com',
        phone: '0123456789',
        role: UserRole.storeAdmin,
      );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          branchServiceProvider.overrideWithValue(FakeBranchService()),
          firebaseFirestoreProvider.overrideWithValue(await seededFirestore()),
        ],
        child: const GrocerlyApp(),
      ),
    );

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'jason@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password1');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    // Dashboard.
    expect(find.textContaining('orders today'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Orders'));
    await tester.pumpAndSettle();

    // Orders board.
    expect(find.text('OUT FOR DELIVERY'), findsOneWidget);
    expect(find.text('Farah Idris'), findsWidgets);

    await tester.tap(find.widgetWithText(ListTile, 'Dashboard'));
    await tester.pumpAndSettle();
    expect(find.textContaining('orders today'), findsOneWidget);

    // "Add item" on the dashboard opens the Inventory tab.
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    expect(find.text('Prices and stock at SS15 Subang'), findsOneWidget);
  });
}
