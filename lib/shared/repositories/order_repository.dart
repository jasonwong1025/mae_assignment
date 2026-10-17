import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final Provider<OrderRepository> orderRepositoryProvider =
    Provider<OrderRepository>((ref) {
      return OrderRepository(ref.watch(orderServiceProvider));
    });

/// Error with a message that is safe to show on screen.
class OrderException implements Exception {
  const OrderException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Places and reads orders through the shared "orders" collection.
///
/// Placing an order turns the customer's [Cart] into an [Order] (capturing
/// the price of every line so totals never drift), gives it the next order
/// number, and writes it to Firestore for the worker and admin apps to read.
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

    final fee = cart.deliveryFeeFor(deliveryFee);
    final nextNumber = await _run(
      _service.nextOrderNumber,
      label: 'nextOrderNumber (counters/orders)',
    );

    final order = Order(
      // The real id comes from Firestore on write; this placeholder is
      // replaced below. Kept non-empty so the model stays valid.
      id: '',
      number: nextNumber,
      customerId: customer.uid,
      customerName: customer.name,
      customerPhone: customer.phone,
      branchId: branch.id,
      branchName: branch.name,
      isDelivery: isDelivery,
      items: [
        for (final line in cart.lines)
          OrderItem(
            lineId: line.product.id,
            productId: line.product.id,
            name: line.product.name,
            brand: line.product.brand,
            packSize: line.product.packSize,
            quantity: line.quantity,
            unitPrice: line.product.price,
            imageUrl: line.product.coverImageUrl,
          ),
      ],
      subtotal: cart.subtotal,
      deliveryFee: fee,
      discount: cart.discount,
      total: cart.totalWith(deliveryFee),
      status: OrderStatus.pending,
      address: isDelivery ? address!.line : null,
      addressLocation: isDelivery ? address!.location : null,
      customerNote: (customerNote?.trim().isEmpty ?? true)
          ? null
          : customerNote!.trim(),
      promoCode: cart.promoCode,
    );

    final id = await _run(
      () => _service.createOrder(order),
      label: 'createOrder (orders/*)',
    );
    return order.copyWith(id: id);
  }

  /// One order by id, or null if it does not exist.
  Future<Order?> getOrder(String id) => _run(() => _service.getOrder(id));

  /// Live stream of a customer's orders, newest first.
  Stream<List<Order>> watchCustomerOrders(String customerId) {
    return _service.watchCustomerOrders(customerId);
  }

  /// Live stream of one order by id.
  Stream<Order?> watchOrder(String id) => _service.watchOrder(id);

  /// Runs a Firestore call and turns any error into an OrderException.
  /// [label] names the operation in logs so a denied call is easy to spot.
  Future<T> _run<T>(Future<T> Function() call, {String label = 'order'}) async {
    try {
      return await call();
    } on OrderException {
      rethrow;
    } on Object catch (error) {
      debugPrint('Order request failed [$label]: $error');
      throw const OrderException(
        'Could not reach the server. Please check your connection and '
        'try again.',
      );
    }
  }
}
