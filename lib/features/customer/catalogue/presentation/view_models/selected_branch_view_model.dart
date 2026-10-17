import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

/// The branch the customer is shopping from. For now it is the first open
/// branch; a branch/address picker will set it in a later slice.
final selectedBranchProvider = FutureProvider.autoDispose<Branch>((ref) async {
  final branches = await ref.watch(branchRepositoryProvider).getBranches();
  if (branches.isEmpty) {
    throw const BranchException('No stores are available right now.');
  }
  // Prefer a branch that is not temporarily closed.
  return branches.firstWhere(
    (branch) => !branch.isTemporarilyClosed,
    orElse: () => branches.first,
  );
});
