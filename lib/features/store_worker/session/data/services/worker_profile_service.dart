import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';

final Provider<WorkerProfileService> workerProfileServiceProvider =
    Provider<WorkerProfileService>(
      (ref) => WorkerProfileService(ref.watch(firebaseFirestoreProvider)),
    );

/// Reads a Store Worker's own profile (users/{uid}) and the name of their
/// branch.
class WorkerProfileService {
  WorkerProfileService(FirebaseFirestore firestore)
    : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// The worker's profile, or null if the document is missing.
  Future<WorkerProfile?> getProfile(String uid) async {
    final snapshot = await _refs
        .user(uid)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;

    final branchId = data.stringOrNull(UserFields.branchId);
    String? branchName;
    if (branchId != null) {
      final branch = await _refs
          .branch(branchId)
          .get()
          .timeout(FirestoreConfig.readTimeout);
      branchName = branch.data()?.stringOrNull(BranchFields.name);
    }
    return snapshot.toModel(
      fromFirestore: (id, fields) =>
          WorkerProfile.fromFirestore(id, fields, branchName: branchName),
    );
  }
}
