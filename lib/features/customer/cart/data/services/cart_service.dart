import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/customer/cart/data/models/stored_cart.dart';

final Provider<CartService> cartServiceProvider = Provider<CartService>(
  (ref) => CartService(ref.watch(firebaseFirestoreProvider)),
);

/// Reads and writes a customer's saved cart in Firestore at
/// users/{uid}/cart/current. Owner-only; see `firestore.rules`.
class CartService {
  CartService(FirebaseFirestore firestore) : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// The saved cart, or null if none has been saved.
  Future<StoredCart?> getCart(String uid) async {
    final snapshot = await _refs
        .cart(uid)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    final data = snapshot.data();
    return data == null ? null : StoredCart.fromMap(data);
  }

  /// Replaces the saved cart.
  Future<void> saveCart(String uid, StoredCart cart) {
    return _refs.cart(uid).set({
      ...cart.toMap(),
      CartFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCart(String uid) => _refs.cart(uid).delete();
}
