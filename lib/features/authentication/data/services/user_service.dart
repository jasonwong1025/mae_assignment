import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/app_user.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(FirebaseFirestore.instance);
});

/// Reads and writes user profiles in the Firestore "users" collection.
class UserService {
  UserService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  Future<void> createUser(AppUser user) {
    return _users.doc(user.uid).set(user.toMap());
  }

  /// Returns null if the profile does not exist.
  Future<AppUser?> getUser(String uid) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    return AppUser.fromMap(uid, data);
  }
}
