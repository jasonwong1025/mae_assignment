import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../models/branch.dart';

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  return BranchRepository();
});

/// Branches the store admin manages.
///
/// The backend is not connected yet, so this returns sample data.
/// The method is already async, so later only the inside of this class
/// changes (to call a Firestore service) and the screens stay the same.
class BranchRepository {
  /// Branches the signed-in admin manages.
  Future<List<Branch>> getBranches() async => _sampleBranches;
}

const _sampleBranches = [
  Branch(
    id: 'ss15',
    name: 'SS15 Subang',
    openingHour: 8,
    closingHour: 21,
    location: LatLng(3.0757, 101.5869),
  ),
  Branch(
    id: 'bukit-jalil',
    name: 'Bukit Jalil',
    openingHour: 9,
    closingHour: 22,
    location: LatLng(3.0584, 101.6890),
  ),
  Branch(
    id: 'puchong',
    name: 'Puchong',
    openingHour: 8,
    closingHour: 20,
    location: LatLng(3.0235, 101.6170),
  ),
];
