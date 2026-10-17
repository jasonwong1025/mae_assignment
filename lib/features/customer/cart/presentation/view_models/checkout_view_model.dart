import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/selected_address_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/repositories/order_repository.dart';

/// Tracks only whether an order is being placed, so the Place order button
/// can show a spinner and ignore repeat taps. Navigation and error messages
/// are handled by the view from [CheckoutViewModel.placeOrder]'s result,
/// not through a listener, so no side effect runs during build/layout.
///
/// autoDispose so the flag resets to false when the Cart tab is left.
final NotifierProvider<CheckoutViewModel, bool> checkoutViewModelProvider =
    NotifierProvider.autoDispose<CheckoutViewModel, bool>(
      CheckoutViewModel.new,
    );

/// Turns the current cart into an order through [OrderRepository]. On
/// success it clears the cart and returns the new order; on failure it
/// throws an [OrderException] with a message safe to show.
class CheckoutViewModel extends Notifier<bool> {
  /// True while an order is being placed.
  @override
  bool build() => false;

  /// Places the current cart as an order and returns it. For delivery, a
  /// saved address must be chosen and inside the branch's delivery radius.
  /// Throws [OrderException] on any failure. Returns null if a place is
  /// already in progress.
  Future<Order?> placeOrder({String? note}) async {
    if (state) return null;
    state = true;
    try {
      final AppUser? user;
      try {
        user = await ref.read(currentUserProvider.future);
      } on Object {
        throw const OrderException(
          'Could not confirm your account. Please try again.',
        );
      }
      if (user == null) {
        throw const OrderException('Please sign in to place an order.');
      }

      final Branch branch;
      try {
        // Resolve the branch (it may not have been read yet if the customer
        // went straight to the cart). Not peeked via `.value`, which would
        // be null before the first read completes.
        branch = await ref.read(selectedBranchProvider.future);
      } on Object {
        throw const OrderException(
          'No store selected. Please open the Home tab and try again.',
        );
      }

      final cart = ref.read(cartViewModelProvider);

      CustomerAddress? address;
      var deliveryFee = 0.0;
      if (cart.fulfilment == FulfilmentMethod.delivery) {
        address = await ref.read(effectiveDeliveryAddressProvider.future);
        if (address == null) {
          throw const OrderException('Please choose a delivery address.');
        }
        final quote = quoteFor(branch: branch, destination: address.location);
        if (!quote.inRange) {
          throw const OrderException(
            'That address is outside this store’s delivery area. Pick '
            'another address or choose self-pickup.',
          );
        }
        deliveryFee = quote.fee;
      }

      final order = await ref
          .read(orderRepositoryProvider)
          .placeOrder(
            cart: cart,
            customer: user,
            branch: branch,
            address: address,
            deliveryFee: deliveryFee,
            customerNote: note,
          );
      ref.read(cartViewModelProvider.notifier).clear();
      ref.read(selectedAddressProvider.notifier).clear();
      return order;
    } finally {
      // The provider may have been disposed if the view navigated away on
      // success; guard the state write so it does not throw.
      if (ref.mounted) state = false;
    }
  }
}
