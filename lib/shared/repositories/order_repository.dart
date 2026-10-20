import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final Provider<OrderRepository> orderRepositoryProvider =
    Provider<OrderRepository>((ref) {
      return OrderRepository(ref.watch(orderServiceProvider));
    });

/// Error with a message that is safe to show on screen.
class OrderException extends AppException {
  const OrderException(super.message);
}

/// Places and reads orders through the shared "orders" collection.
///
/// The trusted Function turns a cart intent into a priced order. The admin
/// and worker apps read and update the same orders.
class OrderRepository {
  OrderRepository(this._service);

  final OrderService _service;

  /// Writes the customer's cart as a new order and returns it with its id
  /// and number. The caller clears the cart on success.
  ///
  /// For delivery, [address] (the chosen saved address) and [deliveryFee]
  /// (the branch's distance-based quote) are required; the address's line
  /// and location are stored on the order so a driver can navigate.
  Future<Order> placeOrder({
    required Cart cart,
    required AppUser customer,
    required Branch branch,
    CustomerAddress? address,
    double deliveryFee = 0,
    String? customerNote,
  }) async {
    if (cart.isEmpty) {
      throw const OrderException('Your cart is empty.');
    }

    final isDelivery = cart.fulfilment == FulfilmentMethod.delivery;
    if (isDelivery && address == null) {
      throw const OrderException('Please choose a delivery address.');
    }

    return await _run(
      () => _service.placeOrder(
        branchId: branch.id,
        lines: [
          for (final line in cart.lines)
            {'productId': line.product.id, 'quantity': line.quantity},
        ],
        fulfilment: isDelivery ? 'delivery' : 'pickup',
        addressId: isDelivery ? address!.id : null,
        promoCode: cart.promoCode,
        customerNote: customerNote?.trim(),
      ),
      label: 'placeOrder (callable)',
    );
  }

  /// Cancels a pending order. Throws an [OrderException] if packing has
  /// already started (or the order is gone), so the customer is told rather
  /// than left guessing.
  Future<void> cancelOrder(String orderId) {
    return _run(() async {
      final cancelled = await _service.cancelOrder(orderId);
      if (!cancelled) {
        throw const OrderException(
          'This order can no longer be cancelled. Packing may already have '
          'started.',
        );
      }
    }, label: 'cancelOrder (orders/$orderId)');
  }

  /// Answers the replacement offered for [lineId]: [accept] takes it,
  /// otherwise the line is removed from the order. Throws an
  /// [OrderException] if it has been answered already or the order changed
  /// (for example Store Admin cancelled it).
  Future<void> respondToShortage(
    String orderId,
    String lineId, {
    required bool accept,
  }) {
    return _run(() async {
      final saved = await _service.respondToShortage(
        orderId,
        lineId,
        accept: accept,
      );
      if (!saved) {
        throw const OrderException(
          'This item can no longer be changed. The order may have been '
          'updated or cancelled.',
        );
      }
    }, label: 'respondToShortage (orders/$orderId)');
  }

  /// One order by id, or null if it does not exist.
  Future<Order?> getOrder(String id) => _run(() => _service.getOrder(id));

  /// Live stream of a customer's orders, newest first.
  Stream<List<Order>> watchCustomerOrders(String customerId) {
    return _service.watchCustomerOrders(customerId);
  }

  /// Live stream of one order by id.
  Stream<Order?> watchOrder(String id) => _service.watchOrder(id);

  /// Runs a Firestore call through the shared [guard]. [label] names the
  /// operation in logs so a denied call is easy to spot.
  Future<T> _run<T>(Future<T> Function() call, {String label = 'order'}) {
    return guard(
      call,
      label: label,
      onError: () => const OrderException(kNetworkErrorMessage),
    );
  }
}
