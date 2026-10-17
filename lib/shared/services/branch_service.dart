import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/branch.dart';

final Provider<BranchService> branchServiceProvider = Provider<BranchService>((
  ref,
) {
  return BranchService(FirebaseFirestore.instance);
});

/// Reads and writes the "branches" collection in Firestore.
class BranchService {
  BranchService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _branches {
    return _firestore.collection(FirestoreCollections.branches);
  }

  /// How long to wait for a Firestore read before giving up. Without this,
  /// `get()` retries forever when the backend is unreachable, leaving any
  /// screen that waits on branches loading indefinitely.
  static const Duration _timeout = Duration(seconds: 15);

  /// Every branch, oldest first.
  Future<List<Branch>> getBranches() async {
    final snapshot = await _branches
        .orderBy('createdAt')
        .get()
        .timeout(_timeout);
    return [
      for (final doc in snapshot.docs) Branch.fromMap(doc.id, doc.data()),
    ];
  }

  /// Saves a new branch and returns its id. A branch with an empty id gets
  /// a new id from Firestore.
  Future<String> createBranch(Branch branch) async {
    final doc = branch.id.isEmpty ? _branches.doc() : _branches.doc(branch.id);
    await doc.set({
      ...branch.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateBranch(Branch branch) {
    return _branches.doc(branch.id).update(branch.toMap());
  }
}
