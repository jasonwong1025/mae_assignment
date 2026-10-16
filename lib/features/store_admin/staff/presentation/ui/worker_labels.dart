import '../../../../../shared/models/branch.dart';
import '../../data/models/worker.dart';

// WorkerStatusChip and WorkerAvatar moved to shared/ so the Store Worker
// app can use them too. Re-exported so the Staff tab keeps working.
export '../../../../../shared/ui/worker_badges.dart';

/// Worker's branch name. Drivers show "All branches".
String workerBranchName(Worker worker, List<Branch> branches) {
  if (worker.isDriver) return 'All branches';
  for (final branch in branches) {
    if (branch.id == worker.branchId) return branch.name;
  }
  return 'No branch';
}
