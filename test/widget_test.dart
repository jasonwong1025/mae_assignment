import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mae_assignment/app/app.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';

import 'helpers/fake_auth_repository.dart';

/// The app with a signed-out fake instead of Firebase.
Widget _app() {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(FakeAuthRepository())],
    child: const GrocerlyApp(),
  );
}

void main() {
  testWidgets('Onboarding shows first slide and both buttons', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('Your neighbourhood grocer, online'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('Swiping moves to the next slide', (tester) async {
    await tester.pumpWidget(_app());

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Know before you go'), findsOneWidget);
  });

  testWidgets('"Get started" opens the register page', (tester) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
  });
}
