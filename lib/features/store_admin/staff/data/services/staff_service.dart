import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  /// Admin-only Function creates Auth and profile together.
  Future<void> createStaff({
    required String name,
    required String email,
    required String phone,
    required String temporaryPassword,
    required WorkerRole role,
    required String? branchId,
  }) async {
    await FirebaseFunctions.instanceFor(
      region: 'asia-southeast1',
    ).httpsCallable('createStaff').call<void>({
      'name': name,
      'email': email,
      'phone': phone,
      'temporaryPassword': temporaryPassword,
      'workerRole': role.name,
      'branchId': branchId,
    });
  }

  Future<void> setStaffActive(String uid, {required bool isActive}) async {
    await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
        .httpsCallable('setStaffActive')
        .call<void>({'uid': uid, 'isActive': isActive});
  }

  /// Saves changed details. Account state is handled by the Function.
  Future<void> updateWorker(Worker worker) async {
    final ref = _refs.user(worker.id);
    final before = await ref.get();
    if (before.data()?[UserFields.isActive] != worker.isActive) {
      await setStaffActive(worker.id, isActive: worker.isActive);
    }
    final data = _document(worker)
      ..remove(UserFields.email)
      ..remove(UserFields.isActive);
    await ref.update(data);
  }
}
