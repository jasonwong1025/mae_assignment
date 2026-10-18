import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/features/customer/cart/data/models/stored_cart.dart';

final Provider<CartService> cartServiceProvider = Provider<CartService>(
  (ref) => CartService(FirebaseFirestore.instance),
);

/// Reads and writes a customer's saved cart in Firestore at
/// users/{uid}/cart/current. Owner-only; see `firestore.rules`.
class CartService {
  CartService(this._firestore);

  /// How long to wait for a read before giving up, so loading never hangs
  /// when the backend is unreachable.
  static const Duration _timeout = Duration(seconds: 15);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _cart(String uid) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.cart)
        .doc(CartDocs.current);
  }

  /// The saved cart, or null if none has been saved.
  Future<StoredCart?> getCart(String uid) async {
    final snapshot = await _cart(uid).get().timeout(_timeout);
    final data = snapshot.data();
    return data == null ? null : StoredCart.fromFirestore(data);
  }

  /// Replaces the saved cart.
  Future<void> saveCart(String uid, StoredCart cart) {
    return _cart(uid).set(cart.toMap());
  }

  Future<void> deleteCart(String uid) => _cart(uid).delete();
}
