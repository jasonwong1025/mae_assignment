import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show find;
import 'package:patrol/patrol.dart';

import 'support/actions.dart';
import 'support/patrol_app.dart';
import 'support/waits.dart';

/// End-to-end shortage journey against the Firebase emulators, using order
/// #2399 from `node seed.mjs --with-customer` (a pickup order of the E2E
/// customer that Daniel Lee is packing):
///
/// - Daniel reports the tomatoes unavailable and offers carrots instead. The
///   order now waits for the customer and cannot be marked ready.
/// - The customer sees "Needs your reply" in Orders, opens the order and
///   accepts the replacement.
/// - Daniel opens the order again, sees the carrots as the replacement, ticks
///   every line and can review and mark the order ready.
///
/// See the README "End-to-end tests" section for how to run it.
void main() {
  patrolTest(
    'packer offers a replacement, customer accepts, packer continues',
    ($) async {
      await launchApp($);
      const loadTimeout = Duration(seconds: 60);

      // --- Packer: report the tomatoes unavailable ----------------------
      await signInAs(
        $,
        email: 'daniel.lee@grocerly.my',
        password: 'Worker123!',
        role: 'Store Worker',
      );
      await waitForWidget($, $('My Tasks'), timeout: loadTimeout);
      await waitForWidget($, $('#2399'), timeout: loadTimeout);
      await $('#2399').scrollTo().tap();
      await waitForWidget($, $('Order #2399'));
      await waitForWidget($, $('Review & mark ready'), timeout: loadTimeout);
      await $('Item unavailable?').first.scrollTo().tap();
      await waitForWidget($, $(find.textContaining('is unavailable')));
      // Roma tomato is produce, so the other produce is suggested first.
      await waitForWidget($, $('Carrot'), timeout: loadTimeout);
      await $('Carrot').tap();
      await waitForWidget(
        $,
        $('WAITING FOR CUSTOMER (1)'),
        timeout: loadTimeout,
      );
      // The order cannot be marked ready while the customer has not replied.
      await waitForWidget($, $('Waiting for the customer'));

      // --- Packer signs out ---------------------------------------------
      await $(find.byTooltip('Back')).tap();
      await $.pumpAndSettle();
      await $('Account').tap();
      await waitForWidget($, $('Daniel Lee'));
      await $('Sign out').scrollTo().tap();
      await waitForWidget($, $('I already have an account'));

      // --- Customer: accept the replacement -----------------------------
      await signInAs(
        $,
        email: 'e2e.customer@grocerly.test',
        password: 'Password123!',
        role: 'Customer',
      );
      await waitForWidget($, $('DELIVER TO'), timeout: loadTimeout);
      await $('Orders').tap();
      await waitForWidget($, $('Needs your reply'), timeout: loadTimeout);
      await $('Order #2399').tap();
      await waitForWidget($, $('Your reply is needed'), timeout: loadTimeout);
      // The offered carrots are shown with their price difference.
      await waitForWidget($, $('Carrot'));
      await $('Accept replacement').scrollTo().tap();
      await waitForWidget($, $('Replacement accepted.'));
      await waitForWidget($, $('Unavailable, replaced'));

      // --- Customer signs out -------------------------------------------
      await $(find.byTooltip('Back to orders')).tap();
      await $.pumpAndSettle();
      await $('Account').tap();
      await waitForWidget($, $('E2E Customer'));
      await $('Sign out').scrollTo().tap();
      await waitForWidget($, $('I already have an account'));

      // --- Packer: carry on with the replacement ------------------------
      await signInAs(
        $,
        email: 'daniel.lee@grocerly.my',
        password: 'Worker123!',
        role: 'Store Worker',
      );
      await waitForWidget($, $('#2399'), timeout: loadTimeout);
      await $('#2399').scrollTo().tap();
      await waitForWidget($, $('Order #2399'));
      await waitForWidget(
        $,
        $('Replacement for Roma tomato'),
        timeout: loadTimeout,
      );
      // Tick both lines: the replacement carrots and the eggs.
      await $(Checkbox).first.tap();
      await $.pumpAndSettle();
      await $(Checkbox).first.tap();
      await $.pumpAndSettle();
      // Let the last tick finish saving; the button waits for it.
      await waitForWidget($, $('PACKED (2)'));
      await $.pump(const Duration(seconds: 2));
      await $('Review & mark ready').tap();
      await waitForWidget($, $('Review order #2399'));
    },
  );
}
