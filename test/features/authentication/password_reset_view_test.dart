import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/authentication/presentation/views/login_view.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  testWidgets('password reset dialog closes cleanly and sends the email', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: LoginView()),
      ),
    );

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'test@example.com');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(repository.lastResetEmail, 'test@example.com');
    expect(find.text('Reset password'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
