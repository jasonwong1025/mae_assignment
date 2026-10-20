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
/// - Daniel reports the tomatoes unavailable and offers chicken instead. The
///   order now waits for the customer and cannot be marked ready.
/// - The customer sees "Needs your reply" in Orders, opens the order and
///   accepts the replacement.
/// - Daniel opens the order again, sees the chicken as the replacement, ticks
///   every line, reviews and marks the order ready.
/// - The customer's wallet shows the extra charge for the dearer replacement,
///   and the inbox says the order is ready for pickup.
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
      await waitForWidget($, $('Chicken breast'), timeout: loadTimeout);
      await $('Chicken breast').tap();
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
      // The offered chicken is shown with their price difference.
      // The chicken costs more than the tomatoes, and the wallet has enough.
      await waitForWidget($, $('Chicken breast'));
      await waitForWidget($, $(find.textContaining('more than the original')));
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
      // Tick both lines: the replacement chicken and the eggs.
      await $(Checkbox).first.tap();
      await $.pumpAndSettle();
      await $(Checkbox).first.tap();
      await $.pumpAndSettle();
      // Let the last tick finish saving; the button waits for it.
      await waitForWidget($, $('PACKED (2)'));
      await $.pump(const Duration(seconds: 2));
      await $('Review & mark ready').tap();
      await waitForWidget($, $('Review order #2399'));
      await $('Mark as ready').tap();
      await waitForWidget($, $('Order #2399 is ready'), timeout: loadTimeout);

      // --- Packer signs out, customer sees the wallet and the notice ----
      await $('Back to My Tasks').tap();
      await waitForWidget($, $('My Tasks'));
      await $('Account').tap();
      await waitForWidget($, $('Daniel Lee'));
      await $('Sign out').scrollTo().tap();
      await waitForWidget($, $('I already have an account'));
      await signInAs(
        $,
        email: 'e2e.customer@grocerly.test',
        password: 'Password123!',
        role: 'Customer',
      );
      await waitForWidget($, $('DELIVER TO'), timeout: loadTimeout);
      await $('Account').tap();
      // The Functions settled the order when packing finished: the dearer
      // chicken was charged to the wallet.
      await $('Wallet').scrollTo().tap();
      await waitForWidget(
        $,
        $(find.textContaining('Replacement price difference')).first,
        timeout: loadTimeout,
      );
      await $(find.byTooltip('Back')).tap();
      await $('Notifications').scrollTo().tap();
      await waitForWidget(
        $,
        $(find.textContaining('ready for pickup')).first,
        timeout: loadTimeout,
      );
    },
  );
}
