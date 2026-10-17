import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(FirebaseFirestore.instance);
});

/// Reads and writes user profiles in the Firestore `users` collection.
///
/// The collection is bound with a typed converter, so every read returns an
/// [AppUser] and raw `Map<String, dynamic>` never leaves this service.
class UserService {
  UserService(this._firestore);

  final FirebaseFirestore _firestore;

  /// `users`, typed so documents are [AppUser]s at the SDK boundary.
  CollectionReference<AppUser> get _users {
    return _firestore
        .collection(FirestoreCollections.users)
        .withConverter<AppUser>(
          fromFirestore: (snapshot, _) =>
              AppUser.fromMap(snapshot.id, snapshot.data() ?? const {}),
          toFirestore: (user, _) => user.toMap(),
        );
  }

  Future<void> createUser(AppUser user) {
    return _users.doc(user.uid).set(user);
  }

  /// A second sign-in on another device must not overwrite an existing
  /// profile (including its role). The transaction retries on a race.
  Future<AppUser> getOrCreateCustomer(AppUser customer) {
    final document = _users.doc(customer.uid);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final existing = snapshot.data();
      if (existing != null) return existing;
      transaction.set(document, customer);
      return customer;
    });
  }

  /// Returns null if the profile does not exist.
  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    return snapshot.data();
  }
}
