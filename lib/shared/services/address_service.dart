import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';

final Provider<AddressService> addressServiceProvider =
    Provider<AddressService>(
      (ref) => AddressService(FirebaseFirestore.instance),
    );

/// Reads and writes a customer's saved delivery addresses in Firestore at
/// users/{uid}/addresses. Owner-only; see `firestore.rules`.
class AddressService {
  AddressService(this._firestore);

  /// How long to wait for a read before giving up, so a screen never loads
  /// forever when the backend is unreachable.
  static const Duration _timeout = Duration(seconds: 15);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _addresses(String uid) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.addresses);
  }

  /// A customer's saved addresses, newest first.
  Future<List<CustomerAddress>> getAddresses(String uid) async {
    final snapshot = await _addresses(uid)
        .orderBy(AddressFields.createdAt, descending: true)
        .get()
        .timeout(_timeout);
    return [
      for (final doc in snapshot.docs)
        ?CustomerAddress.fromFirestore(doc.id, doc.data()),
    ];
  }

  /// Saves a new address and returns its id. Sets the server time so the
  /// list order is stable.
  Future<String> addAddress(String uid, CustomerAddress address) async {
    final doc = _addresses(uid).doc();
    await doc.set({
      ...address.toMap(),
      AddressFields.createdAt: FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Overwrites the address with the same id (keeps createdAt).
  Future<void> updateAddress(String uid, CustomerAddress address) {
    return _addresses(
      uid,
    ).doc(address.id).set(address.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteAddress(String uid, String addressId) {
    return _addresses(uid).doc(addressId).delete();
  }

  /// Marks [addressId] the default and clears the flag on all others, in one
  /// batch so there is never more than one default.
  Future<void> setDefault(String uid, String addressId) async {
    final snapshot = await _addresses(uid).get().timeout(_timeout);
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        AddressFields.isDefault: doc.id == addressId,
      });
    }
    await batch.commit();
  }
}
