import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(firebaseFirestoreProvider));
});

/// Reads and writes user profiles in the Firestore `users` collection.
///
/// Reads return an [AppUser] (parsed by `toModel`), so a raw
/// `Map<String, dynamic>` never leaves this service.
class UserService {
  UserService(this._firestore) : _refs = FirestoreRefs(_firestore);

  final FirebaseFirestore _firestore;
  final FirestoreRefs _refs;

  /// The fields written when a profile is created: the user's own fields
  /// plus the server time as createdAt, as `firestore.rules` requires.
  Map<String, dynamic> _newProfile(AppUser user) {
    return {
      ...user.toFirestore(),
      UserFields.createdAt: FieldValue.serverTimestamp(),
    };
  }

  Future<void> createUser(AppUser user) {
    return _refs.user(user.uid).set(_newProfile(user));
  }

  /// A second sign-in on another device must not overwrite an existing
  /// profile (including its role). The transaction retries on a race.
  Future<AppUser> getOrCreateCustomer(AppUser customer) {
    final document = _refs.user(customer.uid);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      final existing = snapshot.toModel(fromFirestore: AppUser.fromFirestore);
      if (existing != null) return existing;
      transaction.set(document, _newProfile(customer));
      return customer;
    });
  }

  /// Returns null if the profile does not exist.
  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _refs.user(uid).get();
    return snapshot.toModel(fromFirestore: AppUser.fromFirestore);
  }
}
