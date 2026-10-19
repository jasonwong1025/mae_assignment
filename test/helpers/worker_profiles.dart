import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/shared/models/worker_role.dart';

/// Store Workers for the worker tests. Their ids match the people in
/// `workerTestOrders` (test/helpers/worker_test_orders.dart).
const testWorkers = [
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
    isActive: true,
  ),
];

/// A test worker by name, e.g. "Daniel Lee".
WorkerProfile testWorker(String name) {
  return testWorkers.firstWhere((worker) => worker.name == name);
}
