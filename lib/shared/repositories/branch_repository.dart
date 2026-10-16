import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/branch.dart';
import '../models/page_result.dart';

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository();
});

/// Error with a message to show on screen.
class BranchException implements Exception {
  const BranchException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The retailer's branches. Used by every role.
/// No backend yet: kept in memory and reset on restart.
class BranchRepository {
  final List<Branch> _branches = [..._sampleBranches];
  int _nextId = 1;

  /// Every branch, oldest first.
  Future<List<Branch>> getBranches() async => [..._branches];

  /// One page of branches whose name or address has [searchText].
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
    _checkNameIsFree(details.name);

    final branch = Branch(
      id: 'branch-${_nextId++}',
      name: details.name,
      address: details.address,
      phone: details.phone,
      location: details.location,
      weeklyHours: details.weeklyHours,
      maxDeliveryKm: details.maxDeliveryKm,
      baseDeliveryFee: details.baseDeliveryFee,
      feePerKm: details.feePerKm,
    );
    _branches.add(branch);
    return branch;
  }

  /// Replaces the branch that has the same id.
  Future<void> updateBranch(Branch branch) async {
    _checkNameIsFree(branch.name, exceptId: branch.id);

    final index = _branches.indexWhere((old) => old.id == branch.id);
    if (index == -1) {
      throw const BranchException('This branch no longer exists.');
    }
    _branches[index] = branch;
  }

  void _checkNameIsFree(String name, {String? exceptId}) {
    final isTaken = _branches.any((branch) {
      return branch.id != exceptId &&
          branch.name.toLowerCase() == name.toLowerCase();
    });
    if (isTaken) {
      throw const BranchException('A branch with this name already exists.');
    }
  }
}

/// Same hours every day.
List<DayHours> _everyDay(int opensAt, int closesAt) {
  return List.filled(7, DayHours(opensAt: opensAt, closesAt: closesAt));
}

/// Sample branches. TODO: delete once branches come from Firestore.
final _sampleBranches = [
  Branch(
    id: 'ss15',
    name: 'SS15 Subang',
    address: '12, Jalan SS15/4D, 47500 Subang Jaya, Selangor',
    phone: '03-5611 2201',
    location: const LatLng(3.0757, 101.5869),
    weeklyHours: _everyDay(8 * 60, 21 * 60),
    maxDeliveryKm: 8,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
  ),
  Branch(
    id: 'bukit-jalil',
    name: 'Bukit Jalil',
    address: '3, Jalan Jalil Perkasa 1, 57000 Bukit Jalil, Kuala Lumpur',
    phone: '03-8996 4410',
    location: const LatLng(3.0584, 101.6890),
    weeklyHours: [
      ..._everyDay(9 * 60, 22 * 60).take(6),
      const DayHours(opensAt: 10 * 60, closesAt: 20 * 60),
    ],
    maxDeliveryKm: 10,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
  ),
  Branch(
    id: 'puchong',
    name: 'Puchong',
    address: '21, Jalan Puteri 1/2, 47100 Bandar Puteri Puchong, Selangor',
    phone: '03-8061 7720',
    location: const LatLng(3.0235, 101.6170),
    weeklyHours: [
      ..._everyDay(8 * 60, 20 * 60).take(6),
      const DayHours.closed(),
    ],
    maxDeliveryKm: 6,
    baseDeliveryFee: 4,
    feePerKm: 0.6,
  ),
];
