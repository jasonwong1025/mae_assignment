import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import 'support/patrol_app.dart';

/// End-to-end customer journey against the Firebase emulators:
/// sign in -> browse the catalogue -> add a product -> open the cart ->
/// confirm a delivery address -> place the order -> see live tracking ->
/// go back to the orders list.
///
/// Prerequisites (see the README "End-to-end tests" section):
///   1. Firebase emulators running (auth + firestore).
///   2. The emulator seeded with the catalogue and a test customer who has
///      one saved address:
///        cd test_firebase
///        FIRESTORE_EMULATOR_HOST=localhost:8085 \
///        FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
///        node seed.mjs --with-customer
///   3. A device/emulator connected.
///
/// Run (a physical device needs the host's LAN ip for the emulators):
///   patrol test --target integration_test/customer_journey_test.dart \
///     --dart-define=USE_FIREBASE_EMULATOR=true \
///     --dart-define=FIREBASE_EMULATOR_HOST=`host-ip`
void main() {
  patrolTest('customer places an order and tracks it', ($) async {
    await launchApp($);

    // --- Onboarding -> Sign in ---------------------------------------
    await $('I already have an account').tap();
    await $.waitUntilVisible($('Sign in to continue'));

    // The sign-in form has two inputs, in order: email/phone, then
    // password. Fill them with the seeded customer's credentials.
    final fields = $(TextFormField);
    await fields.at(0).enterText('e2e.customer@grocerly.test');
    await fields.at(1).enterText('Password123!');

    // "Continue as Customer" signs in and lands on the catalogue.
    await $('Customer').tap();

    // --- Catalogue (Home) --------------------------------------------
    // The catalogue reads the branch and products from Firestore, so give it
    // longer than the default 10s. Use waitUntilExists (not ...Visible) for
    // anchors: it only needs the widget in the tree, not hit-testable, so a
    // chip inside a horizontal list or a card below the fold still counts as
    // "the catalogue loaded". The "+" add button only renders once products
    // are shown, so waiting for it confirms the grid has data.
    const catalogueTimeout = Duration(seconds: 30);
    await $.waitUntilExists($('DELIVER TO'), timeout: catalogueTimeout);
    await $.waitUntilExists(
      $(Icons.add_rounded),
      timeout: catalogueTimeout,
    );

    // Add the first product to the cart. The add buttons sit in the grid
    // below the "going fast" row, so scroll the first one into view before
    // tapping (Patrol's tap needs the widget hit-testable; it does not
    // auto-scroll).
    await $(Icons.add_rounded).first.scrollTo().tap();
    await $.pumpAndSettle();

    // --- Cart --------------------------------------------------------
    // Open the Cart tab from the bottom navigation.
    await $('Cart').tap();
    await $.waitUntilExists($('Your cart'));

    // The seeded customer already has a default address, so it is used by
    // default. Place the order (the button label includes the total, so
    // match on the leading text).
    await $('Place order').scrollTo().tap();

    // --- Tracking ----------------------------------------------------
    await $.waitUntilExists($('Order tracking'), timeout: catalogueTimeout);
    await $.waitUntilExists($('Pending'), timeout: catalogueTimeout);

    // --- Back to the orders list -------------------------------------
    await $('Back to orders').tap();
    await $.waitUntilExists($('Your orders'));
  });
}
