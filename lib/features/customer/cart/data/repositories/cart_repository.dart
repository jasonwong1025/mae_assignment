import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/customer/cart/data/models/stored_cart.dart';
import 'package:mae_assignment/features/customer/cart/data/services/cart_service.dart';

final Provider<CartRepository> cartRepositoryProvider =
    Provider<CartRepository>((ref) {
      return CartRepository(ref.watch(cartServiceProvider));
    });

/// The customer's saved cart. Takes the uid from the caller (the cart sync
/// knows exactly whose cart it is handling), and keeps the saved document
/// tidy: an empty cart is deleted rather than stored.
class CartRepository {
  CartRepository(this._service);

  final CartService _service;

  /// The saved cart for [uid], or null if there is none.
  Future<StoredCart?> load(String uid) => _service.getCart(uid);

  /// Saves [cart] for [uid]; deletes the saved cart when it is empty.
  Future<void> save(String uid, StoredCart cart) {
    return cart.isEmpty
        ? _service.deleteCart(uid)
        : _service.saveCart(uid, cart);
  }
}
