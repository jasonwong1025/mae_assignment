import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/data/repositories/worker_session_repository.dart';

/// Not autoDispose on purpose: the signed-in worker should stay the same
/// while they move between tabs.
final workerSessionProvider =
    NotifierProvider<WorkerSessionViewModel, WorkerProfile?>(
      WorkerSessionViewModel.new,
    );

/// The signed-in Store Worker, or null if nobody is.
///
/// Filled by [start] right after a worker signs in (or the app reopens with
/// a live session), from their users/{uid} profile. It is cleared as soon
/// as the Firebase session ends. Screens only read the state.
class WorkerSessionViewModel extends Notifier<WorkerProfile?> {
  @override
  WorkerProfile? build() {
    // Signing out (or the backend ending the session) ends the worker
    // session too.
    ref.listen(authUidProvider, (previous, next) {
      if (next.hasValue && next.value == null) state = null;
    });
    return null;
  }

  /// Loads the signed-in worker's profile and starts the session. Returns
  /// an error message, or null if it worked.
  Future<String?> start() async {
    final WorkerProfile profile;
    try {
      profile = await ref.read(workerSessionRepositoryProvider).loadCurrent();
    } on Exception catch (error) {
      return error.toString();
    }
    return open(profile);
  }

  /// Starts the session as [worker]. Returns an error message, or null if
  /// it worked.
  String? open(WorkerProfile worker) {
    if (!worker.isActive) {
      return '${worker.name} has been deactivated by HQ, so this account '
          'cannot use the Store Worker app.';
    }
    // Packing Staff work at one branch; without it they have no tasks.
    if (worker.isPackingStaff && worker.branchId == null) {
      return '${worker.name} has no branch assigned yet. Ask HQ to assign '
          'one.';
    }
    state = worker;
    return null;
  }

  /// Ends the session locally. Signing out of Firebase is done by the
  /// caller (the Account tab), which also clears this.
  void exit() => state = null;
}
