import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

/// The branch the customer is shopping from. For now it is the first open
/// branch; a branch/address picker will set it in a later slice.
///
/// Not autoDispose: the chosen branch is session-wide state, like the cart,
/// so it must survive moving between the Home, Cart and Orders tabs.
/// Checkout reads it from the Cart tab, where the catalogue (which also
/// watches it) is no longer mounted; if this disposed, checkout would see
/// no branch and fail with "No store selected".
///
/// A failure to reach Firestore (no connection, timeout) surfaces as a
/// retryable [BranchException] rather than a raw error, so the Home screen
/// shows "Try again" instead of a message only a developer understands.
final selectedBranchProvider = FutureProvider<Branch>((ref) async {
  final List<Branch> branches;
  try {
    branches = await ref.watch(branchRepositoryProvider).getBranches();
  } on BranchException {
    rethrow;
  } on Object {
    throw const BranchException(
      'Could not reach the store. Please check your connection and try '
      'again.',
    );
  }

  if (branches.isEmpty) {
    throw const BranchException('No stores are available right now.');
  }
  // Prefer a branch that is not temporarily closed.
  return branches.firstWhere(
    (branch) => !branch.isTemporarilyClosed,
    orElse: () => branches.first,
  );
});
