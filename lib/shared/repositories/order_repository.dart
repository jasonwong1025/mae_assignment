import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/cart/data/models/cart.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/branch.dart';
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
  Future<Order> placeOrder({
    required Cart cart,
    required AppUser customer,
    required Branch branch,
    String? address,
    String? customerNote,
  }) async {
    if (cart.isEmpty) {
      throw const OrderException('Your cart is empty.');
    }

    final isDelivery = cart.fulfilment == FulfilmentMethod.delivery;
    if (isDelivery && (address == null || address.trim().isEmpty)) {
      throw const OrderException('Please add a delivery address.');
    }

    final nextNumber = await _run(
      () async => (await _service.highestOrderNumber()) + 1,
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
      deliveryFee: cart.deliveryFee,
      discount: cart.discount,
      total: cart.total,
      status: OrderStatus.pending,
      address: isDelivery ? address?.trim() : null,
      customerNote: (customerNote?.trim().isEmpty ?? true)
          ? null
          : customerNote!.trim(),
      promoCode: cart.promoCode,
    );

    final id = await _run(() => _service.createOrder(order));
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
  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on OrderException {
      rethrow;
    } on Object catch (error) {
      debugPrint('Order request failed: $error');
      throw const OrderException(
        'Could not reach the server. Please check your connection and '
        'try again.',
      );
    }
  }
}
