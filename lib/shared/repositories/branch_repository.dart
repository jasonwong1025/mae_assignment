import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/page_result.dart';
import 'package:mae_assignment/shared/repositories/sample_branches.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

final Provider<BranchRepository> branchRepositoryProvider =
    Provider<BranchRepository>((ref) {
      return BranchRepository(ref.watch(branchServiceProvider));
    });

/// Error with a message to show on screen.
class BranchException extends AppException {
  const BranchException(super.message);
}

/// The retailer's branches, saved in Firestore. Used by every role.
class BranchRepository {
  BranchRepository(this._service);

  final BranchService _service;

  /// Every branch, oldest first.
  Future<List<Branch>> getBranches() => _run(_service.getBranches);

  /// One page of branches whose name or address has [searchText].
  /// Branches are few, so all are loaded and the page is cut here.
  Future<PageResult<Branch>> getBranchPage({
    String searchText = '',
    int page = 1,
  }) async {
    final search = searchText.trim().toLowerCase();
    final matching = (await getBranches()).where((branch) {
      return branch.name.toLowerCase().contains(search) ||
          branch.address.toLowerCase().contains(search);
    }).toList();
    return PageResult.fromList(matching, page: page);
  }

  /// Adds a branch with a new id and returns it.
  Future<Branch> addBranch(Branch details) async {
    await _checkNameIsFree(details.name);
    final id = await _run(() => _service.createBranch(details));
    return Branch(
      id: id,
      name: details.name,
      address: details.address,
      phone: details.phone,
      location: details.location,
      weeklyHours: details.weeklyHours,
      maxDeliveryKm: details.maxDeliveryKm,
      baseDeliveryFee: details.baseDeliveryFee,
      feePerKm: details.feePerKm,
    );
  }

  /// Saves changes to the branch that has the same id.
  Future<void> updateBranch(Branch branch) async {
    await _checkNameIsFree(branch.name, exceptId: branch.id);
    await _run(() => _service.updateBranch(branch));
  }

  /// One-time setup: adds the 3 sample branches, in order, so SS15 Subang
  /// comes first.
  Future<void> addSampleBranches() async {
    for (final branch in sampleBranches()) {
      await _run(() => _service.createBranch(branch));
    }
  }

  Future<void> _checkNameIsFree(String name, {String? exceptId}) async {
    final isTaken = (await getBranches()).any((branch) {
      return branch.id != exceptId &&
          branch.name.toLowerCase() == name.toLowerCase();
    });
    if (isTaken) {
      throw const BranchException('A branch with this name already exists.');
    }
  }

  /// Runs a Firestore call through the shared [guard].
  Future<T> _run<T>(Future<T> Function() call) {
    return guard(
      call,
      label: 'branch',
      onError: () => const BranchException(kNetworkErrorMessage),
    );
  }
}
