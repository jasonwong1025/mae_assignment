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
    // longer than the default 10s. Anchor first on the always-present
    // "DELIVER TO" header (proves the catalogue frame rendered even if the
    // product grid is still loading), then on a seeded product.
    const catalogueTimeout = Duration(seconds: 30);
    await $('DELIVER TO').waitUntilVisible(timeout: catalogueTimeout);
    await $('Fresh milk 1L').waitUntilVisible(timeout: catalogueTimeout);

    // Add the first product to the cart via its "+" button (the add button
    // on each product card uses Icons.add_rounded).
    await $(Icons.add_rounded).tap();

    // --- Cart --------------------------------------------------------
    // Open the Cart tab from the bottom navigation.
    await $('Cart').tap();
    await $.waitUntilVisible($('Your cart'));

    // The seeded customer already has a default address, so "Change" shows
    // and we keep it. Place the order.
    await $.waitUntilVisible($('Place order'));
    await $('Place order').tap();

    // --- Tracking ----------------------------------------------------
    await $.waitUntilVisible($('Order tracking'));
    await $.waitUntilVisible($('Pending'));

    // --- Back to the orders list -------------------------------------
    await $('Back to orders').tap();
    await $.waitUntilVisible($('Your orders'));
  });
}
