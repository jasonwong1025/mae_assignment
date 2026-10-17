import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/inventory/data/repositories/inventory_repository.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/page_result.dart';
import 'package:mae_assignment/shared/repositories/branch_repository.dart';
import 'package:mae_assignment/shared/repositories/geocoding_repository.dart';

final branchesFilterProvider =
    NotifierProvider.autoDispose<BranchesFilterViewModel, BranchesFilter>(
      BranchesFilterViewModel.new,
    );

final branchesViewModelProvider =
    AsyncNotifierProvider.autoDispose<BranchesViewModel, PageResult<Branch>>(
      BranchesViewModel.new,
    );

/// Search text and page of the Branches tab.
class BranchesFilter {
  const BranchesFilter({this.searchText = '', this.page = 1});

  final String searchText;
  final int page;
}

class BranchesFilterViewModel extends Notifier<BranchesFilter> {
  @override
  BranchesFilter build() => const BranchesFilter();

  /// A new search starts again from page 1.
  void setSearchText(String text) {
    state = BranchesFilter(searchText: text);
  }

  void setPage(int page) {
    state = BranchesFilter(searchText: state.searchText, page: page);
  }
}

/// State for the Branches tab: one page of branches.
/// Methods that change a branch return an error message, or null if it
/// worked.
class BranchesViewModel extends AsyncNotifier<PageResult<Branch>> {
  @override
  Future<PageResult<Branch>> build() {
    final filter = ref.watch(branchesFilterProvider);
    return ref
        .watch(branchRepositoryProvider)
        .getBranchPage(searchText: filter.searchText, page: filter.page);
  }

  /// Adds a branch and gives it every product with 0 stock.
  Future<String?> addBranch(Branch details) async {
    try {
      final branch = await ref
          .read(branchRepositoryProvider)
          .addBranch(details);
      await ref.read(inventoryRepositoryProvider).addBranch(branch.id);
    } on BranchException catch (e) {
      return e.message;
    }
    await _reload();
    return null;
  }

  Future<String?> updateBranch(Branch branch) async {
    try {
      await ref.read(branchRepositoryProvider).updateBranch(branch);
    } on BranchException catch (e) {
      return e.message;
    }
    await _reload();
    return null;
  }

  Future<String?> setTemporarilyClosed(Branch branch, {required bool closed}) {
    return updateBranch(branch.withTemporarilyClosed(closed: closed));
  }

  /// One-time setup: adds the 3 sample branches.
  Future<String?> addSampleBranches() async {
    try {
      await ref.read(branchRepositoryProvider).addSampleBranches();
    } on BranchException catch (e) {
      return e.message;
    }
    await _reload();
    return null;
  }

  /// Finds addresses for the form's search box.
  Future<List<AddressResult>> searchAddress(String text) {
    return ref.read(geocodingRepositoryProvider).search(text);
  }

  /// Reloads this list and the sidebar's branch dropdown.
  Future<void> _reload() async {
    await ref.read(branchViewModelProvider.notifier).reload();
    ref.invalidateSelf();
    await future;
  }
}
