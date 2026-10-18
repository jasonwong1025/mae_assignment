import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' show find;
import 'package:mae_assignment/features/customer/catalogue/presentation/ui/product_card.dart';
import 'package:patrol/patrol.dart';

import 'support/actions.dart';
import 'support/patrol_app.dart';
import 'support/waits.dart';

/// End-to-end customer journey against the Firebase emulators:
/// sign in -> browse the catalogue -> add a product -> open its details and
/// add more -> restart the app and find the cart restored -> open the cart ->
/// confirm a delivery address -> place the order -> see live tracking ->
/// cancel it -> order it again -> see the orders list.
///
/// Needs the Firebase emulators running and seeded with
/// `node seed.mjs --with-customer`, and an Android emulator. See the README
/// "End-to-end tests" section for the commands.
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
    // CI emulators run without a GPU and are much slower than a dev
    // machine, so allow a generous budget; waits return as soon as the
    // widget appears.
    const catalogueTimeout = Duration(seconds: 60);
    await waitForWidget($, $('DELIVER TO'), timeout: catalogueTimeout);
    await waitForWidget($, $(Icons.add_rounded), timeout: catalogueTimeout);

    // Add the first product to the cart. The add buttons sit in the grid
    // below the "going fast" row, so scroll the first one into view before
    // tapping (Patrol's tap needs the widget hit-testable; it does not
    // auto-scroll).
    await $(Icons.add_rounded).first.scrollTo().tap();
    await $.pumpAndSettle();

    // --- Product details ---------------------------------------------
    // The first card is the product just added, so its details page shows
    // the one already in the cart.
    await $(CustomerProductCard).first.scrollTo().tap();
    await waitForWidget($, $('Product details'));
    await waitForWidget($, $('In your cart: 1'));

    // Choose a quantity of 2 and add it: 1 + 2 = 3 in the cart.
    await $(find.byTooltip('Increase quantity')).tap();
    await $(find.textContaining('Add to cart')).tap();
    await waitForWidget($, $('In your cart: 3'));

    // --- Cart survives an app restart --------------------------------
    // The cart is saved per user in Firestore, so after a restart (a fresh
    // app state, still signed in) the same product is back in the cart.
    await restartApp($);
    await waitForWidget($, $('DELIVER TO'), timeout: catalogueTimeout);
    await waitForWidget($, $(Icons.add_rounded), timeout: catalogueTimeout);
    await $(CustomerProductCard).first.scrollTo().tap();
    await waitForWidget($, $('Product details'));
    await waitForWidget($, $('In your cart: 3'), timeout: catalogueTimeout);
    await $(find.byTooltip('Back')).tap();
    await waitForWidget($, $('DELIVER TO'));

    // --- Cart --------------------------------------------------------
    // Open the Cart tab from the bottom navigation.
    await $('Cart').tap();
    await waitForWidget($, $('Your cart'));

    // The seeded customer already has a default address, so it is used by
    // default. The button is pinned outside the cart's scrolling list. Find
    // it by its stable key without traversing offscreen list children.
    await $(
      find.byKey(const Key('place_order_button'), skipOffstage: false),
    ).tap();

    // --- Tracking ----------------------------------------------------
    await waitForWidget($, $('Order tracking'), timeout: catalogueTimeout);
    await waitForWidget($, $('Pending'), timeout: catalogueTimeout);

    // --- Cancel the pending order ------------------------------------
    // Nobody has started packing it, so the customer can still cancel.
    await tapByKey($, 'cancel_order_button');
    await $(find.widgetWithText(FilledButton, 'Cancel order')).tap();
    await waitForWidget($, $('Cancelled'), timeout: catalogueTimeout);

    // --- Order again -------------------------------------------------
    // A cancelled order can be put straight back in the cart.
    await tapByKey($, 'reorder_button');
    await waitForWidget($, $('Your cart'), timeout: catalogueTimeout);

    // --- Orders list -------------------------------------------------
    await $('Orders').tap();
    await waitForWidget($, $('Your orders'));
  });
}
