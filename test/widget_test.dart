import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mae_assignment/app/app.dart';

void main() {
  testWidgets('Onboarding shows first slide and both buttons', (tester) async {
    await tester.pumpWidget(const GrocerlyApp());

    expect(find.text('Your neighbourhood grocer, online'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('Swiping moves to the next slide', (tester) async {
    await tester.pumpWidget(const GrocerlyApp());

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Know before you go'), findsOneWidget);
  });

  testWidgets('"Get started" opens the register page', (tester) async {
    await tester.pumpWidget(const GrocerlyApp());

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Create account'), findsOneWidget);
  });
}
