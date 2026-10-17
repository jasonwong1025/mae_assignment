import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worker.dart';

final staffServiceProvider = Provider<StaffService>((ref) {
  return StaffService(FirebaseFirestore.instance);
});

/// Reads and writes Store Workers in Firestore, and creates their logins.
class StaffService {
  StaffService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  Future<List<Worker>> getWorkers() async {
    final snapshot = await _users.where('role', isEqualTo: 'storeWorker').get();
    return [
      for (final doc in snapshot.docs) Worker.fromMap(doc.id, doc.data()),
    ];
  }

  /// Creates the worker's Firebase login and returns its id.
  ///
  /// Creating a login normally signs the app in as the new user, which
  /// would sign the admin out. So it is done on a second, separate
  /// Firebase app, and the admin stays signed in.
  Future<String> createLogin({
    required String email,
    required String password,
  }) async {
    const appName = 'createWorker';
    final app = Firebase.apps.any((app) => app.name == appName)
        ? Firebase.app(appName)
        : await Firebase.initializeApp(
            name: appName,
            options: Firebase.app().options,
          );

    final auth = FirebaseAuth.instanceFor(app: app);
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await auth.signOut();
    return credential.user!.uid;
  }

  /// Saves a new worker's profile, with the server time as joinedAt.
  Future<void> createWorker(Worker worker) {
    return _users.doc(worker.id).set({
      ...worker.toMap(),
      'joinedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Saves changed details. Email and joinedAt are never changed here.
  Future<void> updateWorker(Worker worker) {
    final data = worker.toMap()..remove('email');
    return _users.doc(worker.id).update(data);
  }
}
