import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/cart_view_model.dart';
import 'package:mae_assignment/features/customer/catalogue/presentation/view_models/selected_branch_view_model.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/repositories/order_repository.dart';

final NotifierProvider<CheckoutViewModel, CheckoutState>
checkoutViewModelProvider = NotifierProvider<CheckoutViewModel, CheckoutState>(
  CheckoutViewModel.new,
);

/// Where checkout is: idle, placing the order, placed (with the new order),
/// or failed (with a message to show).
sealed class CheckoutState {
  const CheckoutState();
}

/// Nothing in progress; the Place order button is active.
class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

/// The order is being written; the button shows a spinner.
class CheckoutPlacing extends CheckoutState {
  const CheckoutPlacing();
}

/// The order was placed; [order] has its id and number for navigation.
class CheckoutPlaced extends CheckoutState {
  const CheckoutPlaced(this.order);

  final Order order;
}

/// Placing failed; [message] is safe to show on screen.
class CheckoutFailure extends CheckoutState {
  const CheckoutFailure(this.message);

  final String message;
}

/// Turns the current cart into an order through [OrderRepository]. On
/// success it clears the cart and exposes the new order so the view can
/// open its tracking screen.
class CheckoutViewModel extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutIdle();

  /// Places the current cart as an order. [address] is required for
  /// delivery; ignored for pickup. No-op while already placing.
  Future<void> placeOrder({String? address, String? note}) async {
    if (state is CheckoutPlacing) return;
    state = const CheckoutPlacing();

    final AppUser? user;
    try {
      user = await ref.read(currentUserProvider.future);
    } on Object {
      state = const CheckoutFailure(
        'Could not confirm your account. Please try again.',
      );
      return;
    }
    if (user == null) {
      state = const CheckoutFailure('Please sign in to place an order.');
      return;
    }

    final branch = ref.read(selectedBranchProvider).value;
    if (branch == null) {
      state = const CheckoutFailure(
        'No store selected. Please go back to the Home tab and try again.',
      );
      return;
    }

    final cart = ref.read(cartViewModelProvider);

    try {
      final order = await ref
          .read(orderRepositoryProvider)
          .placeOrder(
            cart: cart,
            customer: user,
            branch: branch,
            address: address,
            customerNote: note,
          );
      ref.read(cartViewModelProvider.notifier).clear();
      state = CheckoutPlaced(order);
    } on OrderException catch (error) {
      state = CheckoutFailure(error.message);
    } on Object {
      state = const CheckoutFailure(
        'Could not place your order. Please try again.',
      );
    }
  }

  /// Resets to idle, e.g. after showing an error or navigating away.
  void reset() => state = const CheckoutIdle();
}
