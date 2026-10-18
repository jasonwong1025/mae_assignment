import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/shared/models/branch.dart';

final Provider<BranchService> branchServiceProvider = Provider<BranchService>((
  ref,
) {
  return BranchService(ref.watch(firebaseFirestoreProvider));
});

/// Reads and writes the "branches" collection in Firestore.
class BranchService {
  BranchService(FirebaseFirestore firestore) : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  /// Every branch, oldest first.
  Future<List<Branch>> getBranches() async {
    final snapshot = await _refs.branches
        .orderBy(BranchFields.createdAt)
        .get()
        .timeout(FirestoreConfig.readTimeout);
    return snapshot.toModels(fromFirestore: Branch.fromFirestore);
  }

  /// Saves a new branch and returns its id. A branch with an empty id gets
  /// a new id from Firestore.
  Future<String> createBranch(Branch branch) async {
    final doc = branch.id.isEmpty
        ? _refs.branches.doc()
        : _refs.branch(branch.id);
    await doc.set({
      ...branch.toFirestore(),
      BranchFields.createdAt: FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateBranch(Branch branch) {
    return _refs.branch(branch.id).update(branch.toFirestore());
  }
}
