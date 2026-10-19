import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show find;
import 'package:patrol/patrol.dart';

import 'support/patrol_app.dart';
import 'support/waits.dart';

/// End-to-end staff journey against the Firebase emulators, using the demo
/// data from `node seed.mjs --with-customer`:
///
/// - The admin signs in, opens the Orders board, and gives the unassigned
///   pending order #2287 to the packer Hakim Roslan.
/// - The admin signs out. Hakim signs in on the Store Worker app, finds #2287
///   in My Tasks and starts packing it.
/// - The admin signs back in and sees the order is now being packed by Hakim.
///
/// See the README "End-to-end tests" section for how to run it.
void main() {
  patrolTest('admin assigns a packer and the packer starts the order', (
    $,
  ) async {
    await launchApp($);
    const loadTimeout = Duration(seconds: 60);

    // --- Admin: assign the packer -------------------------------------
    await _signIn($, 'e2e.admin@grocerly.test', 'Password123!', 'Store Admin');
    await waitForWidget($, $('RIGHT NOW'), timeout: loadTimeout);

    await _openOrders($);
    await waitForWidget($, $('#2287'), timeout: loadTimeout);
    await $('#2287').scrollTo().tap();
    await waitForWidget($, $('Order #2287'));
    await waitForWidget($, $('No packer assigned'));

    await $('Assign packer').scrollTo().tap();
    await waitForWidget($, $('Hakim Roslan'));
    await $('Hakim Roslan').tap();
    await waitForWidget($, $('Hakim Roslan will pack #2287.'));
    await waitForWidget($, $('Packer: Hakim Roslan'));

    // --- Admin signs out ----------------------------------------------
    await $(find.byTooltip('Close')).tap();
    await $.pumpAndSettle();
    await $(find.byTooltip('Open navigation menu')).tap();
    await $.pumpAndSettle();
    await $(find.byTooltip('Sign out')).tap();
    await waitForWidget($, $('I already have an account'));

    // --- Packer: start packing ----------------------------------------
    await _signIn($, 'hakim.roslan@grocerly.my', 'Worker123!', 'Store Worker');
    await waitForWidget($, $('My Tasks'), timeout: loadTimeout);
    await waitForWidget($, $('#2287'), timeout: loadTimeout);
    await $('#2287').scrollTo().tap();
    await waitForWidget($, $('Order #2287'));
    // Opening a pending task from My Tasks starts packing it.
    await waitForWidget($, $('Review & mark ready'), timeout: loadTimeout);

    // --- Packer signs out ---------------------------------------------
    await $(find.byTooltip('Back')).tap();
    await $.pumpAndSettle();
    await $('Account').tap();
    await waitForWidget($, $('Hakim Roslan'));
    await $('Sign out').scrollTo().tap();
    await waitForWidget($, $('I already have an account'));

    // --- Admin sees the order being packed ----------------------------
    await _signIn($, 'e2e.admin@grocerly.test', 'Password123!', 'Store Admin');
    await _openOrders($);
    // On a phone the board shows one status tab at a time: #2287 has moved
    // from Pending to Packing.
    await waitForWidget(
      $,
      $(find.textContaining('Packing ')),
      timeout: loadTimeout,
    );
    await $(find.textContaining('Packing ')).first.tap();
    await $.pumpAndSettle();
    await waitForWidget($, $('#2287'), timeout: loadTimeout);
    await waitForWidget($, $('Hakim'));
  });
}

/// Fills in the sign-in form and signs in with the role button [role].
Future<void> _signIn(
  PatrolIntegrationTester $,
  String email,
  String password,
  String role,
) async {
  await $('I already have an account').tap();
  await $.waitUntilVisible($('Sign in to continue'));
  final fields = $(TextFormField);
  await fields.at(0).enterText(email);
  await fields.at(1).enterText(password);
  await $(role).scrollTo().tap();
}

/// Opens the Orders board of SS15 Subang from the navigation drawer.
Future<void> _openOrders(PatrolIntegrationTester $) async {
  await $(find.byTooltip('Open navigation menu')).tap();
  await $.pumpAndSettle();
  // The demo orders used here belong to SS15 Subang.
  await $(find.byTooltip('Switch branch')).tap();
  await $.pumpAndSettle();
  await $('SS15 Subang').tap();
  await $.pumpAndSettle();
  if (!$(ListTile).$('Orders').exists) {
    await $(find.byTooltip('Open navigation menu')).tap();
    await $.pumpAndSettle();
  }
  await $(ListTile).$('Orders').tap();
}
