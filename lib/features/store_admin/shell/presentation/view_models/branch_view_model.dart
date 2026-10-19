import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';

part 'branch_view_model.freezed.dart';

/// Not autoDispose on purpose: the chosen branch should stay the same
/// while the admin moves between pages.
final branchViewModelProvider =
    AsyncNotifierProvider<BranchViewModel, BranchState>(BranchViewModel.new);

/// The admin's branches and the one they are looking at.
@freezed
abstract class BranchState with _$BranchState {
  const factory BranchState({
    required List<Branch> branches,
    required Branch selected,
  }) = _BranchState;

  const BranchState._();
}

/// State for the branch switcher at the top of the sidebar.
/// Admin pages watch this to know which branch to show.
class BranchViewModel extends AsyncNotifier<BranchState> {
  @override
  Future<BranchState> build() async {
    final auth = ref.watch(authRepositoryProvider);
    final repository = ref.watch(branchRepositoryProvider);
    // Start again when someone signs in or out, so a new admin never sees
    // the previous one's branch.
    ref.listen(authUidProvider, (previous, next) {
      if (next.hasValue && previous?.value != next.value) ref.invalidateSelf();
    });
    // Branches can only be read while signed in; after sign-out the pages
    // are being closed, so do not ask Firestore (it would refuse).
    if (!auth.isSignedIn) {
      throw const BranchException('Please sign in again.');
    }
    final branches = await repository.getBranches();
    if (branches.isEmpty) {
      throw const BranchException(
        'No branches yet. Add one in the Branches tab.',
      );
    }
    return BranchState(branches: branches, selected: branches.first);
  }

  /// Loads the branches again after one is added or edited.
  /// Keeps the same branch selected.
  Future<void> reload() async {
    final selectedId = state.value?.selected.id;
    final branches = await ref.read(branchRepositoryProvider).getBranches();
    if (branches.isEmpty) return;
    final selected = branches.firstWhere(
      (branch) => branch.id == selectedId,
      orElse: () => branches.first,
    );
    state = AsyncData(BranchState(branches: branches, selected: selected));
  }

  void selectBranch(Branch branch) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      BranchState(branches: current.branches, selected: branch),
    );
  }
}
