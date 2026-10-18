import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';

final Provider<AddressService> addressServiceProvider =
    Provider<AddressService>(
      (ref) => AddressService(ref.watch(firebaseFirestoreProvider)),
    );

/// Reads and writes a customer's saved delivery addresses in Firestore at
/// users/{uid}/addresses. Owner-only; see `firestore.rules`.
class AddressService {
  AddressService(this._firestore) : _refs = FirestoreRefs(_firestore);

  final FirebaseFirestore _firestore;
  final FirestoreRefs _refs;

  /// A customer's saved addresses, newest first.
  Future<List<CustomerAddress>> getAddresses(String uid) async {
    final snapshot = await _refs
        .addresses(uid)
        .orderBy(AddressFields.createdAt, descending: true)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return snapshot.toModels(fromFirestore: CustomerAddress.fromFirestore);
  }

  /// Saves a new address and returns its id. Sets the server time so the
  /// list order is stable.
  Future<String> addAddress(String uid, CustomerAddress address) async {
    final doc = _refs.addresses(uid).doc();
    await doc.set({
      ...address.toFirestore(),
      AddressFields.createdAt: FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Overwrites the address with the same id (keeps createdAt).
  Future<void> updateAddress(String uid, CustomerAddress address) {
    return _refs
        .address(uid, address.id)
        .set(address.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteAddress(String uid, String addressId) {
    return _refs.address(uid, addressId).delete();
  }

  /// Marks [addressId] the default and clears the flag on all others, in one
  /// batch so there is never more than one default.
  Future<void> setDefault(String uid, String addressId) async {
    final snapshot = await _refs
        .addresses(uid)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        AddressFields.isDefault: doc.id == addressId,
      });
    }
    await batch.commit();
  }
}
