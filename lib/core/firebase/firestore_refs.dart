import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';

/// The real Firestore instance. Services read it from here (and tests
/// override it), instead of each calling `FirebaseFirestore.instance`.
final Provider<FirebaseFirestore> firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// Every Firestore collection and document reference in the app is built
/// here, from the names in `firestore_paths.dart`.
///
/// Services call these helpers and never chain `.collection().doc()`
/// themselves, so a document path is spelled in exactly one place. The
/// schema this mirrors is written up in `DATABASE/FIRESTORE.md`, and
/// `firestore.rules` must agree with it.
///
/// References are untyped (raw maps). A service gives them a model with
/// `asModel` (see `firestore_models.dart`).
class FirestoreRefs {
  const FirestoreRefs(this._firestore);

  final FirebaseFirestore _firestore;

  // users/{uid}
  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection(FirestoreCollections.users);
  DocumentReference<Map<String, dynamic>> user(String uid) => users.doc(uid);

  // users/{uid}/addresses/{addressId}
  CollectionReference<Map<String, dynamic>> addresses(String uid) =>
      user(uid).collection(FirestoreCollections.addresses);
  DocumentReference<Map<String, dynamic>> address(
    String uid,
    String addressId,
  ) => addresses(uid).doc(addressId);

  // users/{uid}/cart/current
  DocumentReference<Map<String, dynamic>> cart(String uid) =>
      user(uid).collection(FirestoreCollections.cart).doc(CartDocs.current);

  // products/{productId}
  CollectionReference<Map<String, dynamic>> get products =>
      _firestore.collection(FirestoreCollections.products);
  DocumentReference<Map<String, dynamic>> product(String productId) =>
      products.doc(productId);

  // categories/{categoryId}
  CollectionReference<Map<String, dynamic>> get categories =>
      _firestore.collection(FirestoreCollections.categories);

  // branches/{branchId}
  CollectionReference<Map<String, dynamic>> get branches =>
      _firestore.collection(FirestoreCollections.branches);
  DocumentReference<Map<String, dynamic>> branch(String branchId) =>
      branches.doc(branchId);

  // branches/{branchId}/inventory/{productId}
  CollectionReference<Map<String, dynamic>> inventory(String branchId) =>
      branch(branchId).collection(FirestoreCollections.inventory);

  // orders/{orderId}
  CollectionReference<Map<String, dynamic>> get orders =>
      _firestore.collection(FirestoreCollections.orders);
  DocumentReference<Map<String, dynamic>> order(String orderId) =>
      orders.doc(orderId);

  // reviews/{orderId}
  CollectionReference<Map<String, dynamic>> get reviews =>
      _firestore.collection(FirestoreCollections.reviews);
  DocumentReference<Map<String, dynamic>> review(String orderId) =>
      reviews.doc(orderId);

  // counters/{name}
  DocumentReference<Map<String, dynamic>> counter(String name) =>
      _firestore.collection(FirestoreCollections.counters).doc(name);
}
