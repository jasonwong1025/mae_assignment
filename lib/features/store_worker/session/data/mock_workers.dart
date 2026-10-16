import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/shared/models/worker_role.dart';

/// Workers offered by the Mock Worker Selector.
/// A provider, so tests can swap in their own list.
final mockWorkerProfilesProvider = Provider<List<WorkerProfile>>((ref) {
  return mockWorkerProfiles;
});

/// Sample Store Workers for the preview. Packers' branch ids match the
/// store admin's sample branches; drivers have no branch (they deliver for
/// any branch).
// TODO(team): delete once worker profiles come from the backend.
const mockWorkerProfiles = [
  // Branch A: SS15 Subang.
  WorkerProfile(
    id: 'mock-daniel',
    name: 'Daniel Lee',
    email: 'daniel.lee@grocerly.my',
    phone: '012-555 0141',
    role: WorkerRole.packingStaff,
    branchId: 'ss15',
    branchName: 'SS15 Subang',
    isActive: true,
  ),
  WorkerProfile(
    id: 'mock-hakim',
    name: 'Hakim Roslan',
    email: 'hakim.roslan@grocerly.my',
    phone: '017-555 0162',
    role: WorkerRole.packingStaff,
    branchId: 'ss15',
    branchName: 'SS15 Subang',
    isActive: true,
  ),
  WorkerProfile(
    id: 'mock-amir',
    name: 'Amir Hamzah',
    email: 'amir.hamzah@grocerly.my',
    phone: '011-555 0175',
    role: WorkerRole.deliveryDriver,
    // No branch: drivers take deliveries from any branch.
    isActive: true,
  ),
  WorkerProfile(
    id: 'mock-nadia',
    name: 'Nadia Yusof',
    email: 'nadia.yusof@grocerly.my',
    phone: '013-555 0188',
    role: WorkerRole.packingStaff,
    branchId: 'ss15',
    branchName: 'SS15 Subang',
    isActive: false,
  ),

  // Branch B: Bukit Jalil.
  WorkerProfile(
    id: 'mock-hafiz',
    name: 'Hafiz Zainal',
    email: 'hafiz.zainal@grocerly.my',
    phone: '019-555 0117',
    role: WorkerRole.packingStaff,
    branchId: 'bukit-jalil',
    branchName: 'Bukit Jalil',
    isActive: true,
  ),
  WorkerProfile(
    id: 'mock-weijie',
    name: 'Tan Wei Jie',
    email: 'weijie.tan@grocerly.my',
    phone: '016-555 0129',
    role: WorkerRole.deliveryDriver,
    // No branch: drivers take deliveries from any branch.
    isActive: true,
  ),
];
