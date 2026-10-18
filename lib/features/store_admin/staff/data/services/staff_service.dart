import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

final staffServiceProvider = Provider<StaffService>((ref) {
  return StaffService(ref.watch(firebaseFirestoreProvider));
});

/// Reads and writes Store Workers in Firestore, and creates their logins.
class StaffService {
  StaffService(FirebaseFirestore firestore) : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// The fields of a worker's users/{id} document: the worker's own fields
  /// plus the constant `role`.
  Map<String, dynamic> _document(Worker worker) {
    return {
      ...worker.toFirestore(),
      UserFields.role: UserRole.storeWorker.name,
    };
  }

  Future<List<Worker>> getWorkers() async {
    final snapshot = await _refs.users
        .where(UserFields.role, isEqualTo: UserRole.storeWorker.name)
        .get();
    return snapshot.toModels(fromFirestore: Worker.fromFirestore);
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
    return _refs.user(worker.id).set({
      ..._document(worker),
      UserFields.joinedAt: FieldValue.serverTimestamp(),
      UserFields.createdAt: FieldValue.serverTimestamp(),
    });
  }

  /// Saves changed details. Email and joinedAt are never changed here.
  Future<void> updateWorker(Worker worker) {
    final data = _document(worker)..remove(UserFields.email);
    return _refs.user(worker.id).update(data);
  }
}
