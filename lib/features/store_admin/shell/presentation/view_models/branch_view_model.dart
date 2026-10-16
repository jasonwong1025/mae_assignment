import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/features/store_admin/shell/data/models/branch.dart';
import 'package:mae_assignment/features/store_admin/shell/data/repositories/branch_repository.dart';

/// Not autoDispose on purpose: the chosen branch should stay the same
/// while the admin moves between pages.
final branchViewModelProvider =
    AsyncNotifierProvider<BranchViewModel, BranchState>(BranchViewModel.new);

/// The admin's branches and the one they are looking at.
class BranchState {
  const BranchState({required this.branches, required this.selected});

  final List<Branch> branches;
  final Branch selected;
}

/// State for the branch switcher at the top of the sidebar.
/// Admin pages watch this to know which branch to show.
class BranchViewModel extends AsyncNotifier<BranchState> {
  @override
  Future<BranchState> build() async {
    final branches = await ref.watch(branchRepositoryProvider).getBranches();
    return BranchState(branches: branches, selected: branches.first);
  }

  void selectBranch(Branch branch) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      BranchState(branches: current.branches, selected: branch),
    );
  }
}
