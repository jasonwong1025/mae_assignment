import 'package:flutter/material.dart' show TextFormField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' show find;
import 'package:patrol/patrol.dart';

/// Scrolls the widget with [key] into view, then taps it.
///
/// Uses Flutter's own `ensureVisible`, which scrolls whichever scrollable
/// holds the widget, so it works for a button at the bottom of a long list
/// without guessing which list to drag.
Future<void> tapByKey(PatrolIntegrationTester $, String key) async {
  final finder = find.byKey(Key(key), skipOffstage: false);
  await $.tester.ensureVisible(finder);
  await $.pumpAndSettle();
  await $(finder).tap();
}

/// Fills in the sign-in form and signs in with the role button [role]
/// ("Customer", "Store Worker" or "Store Admin"), from the onboarding screen.
Future<void> signInAs(
  PatrolIntegrationTester $, {
  required String email,
  required String password,
  required String role,
}) async {
  await $('I already have an account').tap();
  await $.waitUntilVisible($('Sign in to continue'));
  final fields = $(TextFormField);
  await fields.at(0).enterText(email);
  await fields.at(1).enterText(password);
  await $(role).scrollTo().tap();
}
