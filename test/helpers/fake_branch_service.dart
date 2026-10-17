import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/repositories/sample_branches.dart';
import 'package:mae_assignment/shared/services/branch_service.dart';

/// In-memory BranchService, so tests do not need Firebase.
/// Starts with the 3 sample branches, or none if empty is true.
class FakeBranchService extends Fake implements BranchService {
  FakeBranchService({bool empty = false})
    : branches = empty ? [] : sampleBranches();

  final List<Branch> branches;
  int _nextId = 1;

  @override
  Future<List<Branch>> getBranches() async => [...branches];

  @override
  Future<String> createBranch(Branch branch) async {
    final id = branch.id.isEmpty ? 'branch-${_nextId++}' : branch.id;
    branches.add(
      Branch(
        id: id,
        name: branch.name,
        address: branch.address,
        phone: branch.phone,
        location: branch.location,
        weeklyHours: branch.weeklyHours,
        maxDeliveryKm: branch.maxDeliveryKm,
        baseDeliveryFee: branch.baseDeliveryFee,
        feePerKm: branch.feePerKm,
        isTemporarilyClosed: branch.isTemporarilyClosed,
      ),
    );
    return id;
  }

  @override
  Future<void> updateBranch(Branch branch) async {
    final index = branches.indexWhere((old) => old.id == branch.id);
    branches[index] = branch;
  }
}
