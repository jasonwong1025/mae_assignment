import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

import '../../helpers/fake_auth_repository.dart';

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
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
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
    await tester.tap(find.text('Store Admin'));
    await tester.pumpAndSettle();

    // Dashboard.
    expect(find.text('orders today · up 12 vs yesterday'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Orders'));
    await tester.pumpAndSettle();

    // Orders board.
    expect(find.text('OUT FOR DELIVERY'), findsOneWidget);
    expect(find.text('Farah Idris'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('orders today · up 12 vs yesterday'), findsOneWidget);
  });
}
