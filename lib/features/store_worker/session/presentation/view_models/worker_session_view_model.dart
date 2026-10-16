import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/worker_preview.dart';

/// Not autoDispose on purpose: the chosen worker should stay the same while
/// they move between tabs.
final workerSessionProvider =
    NotifierProvider<WorkerSessionViewModel, WorkerProfile?>(
      WorkerSessionViewModel.new,
    );

/// The Store Worker using the app, or null if nobody is.
///
/// During the preview this is set by the Mock Worker Selector and has
/// nothing to do with Firebase sign-in. Later it will be filled from the
/// signed-in worker's profile instead; screens only read the state, so they
/// will not need to change.
class WorkerSessionViewModel extends Notifier<WorkerProfile?> {
  @override
  WorkerProfile? build() => null;

  /// Starts a preview as [worker]. Returns an error message, or null if it
  /// worked.
  String? select(WorkerProfile worker) {
    if (!ref.read(workerPreviewEnabledProvider)) {
      return 'The Store Worker preview is not available in this build.';
    }
    if (!worker.isActive) {
      return '${worker.name} has been deactivated by HQ, so this account '
          'cannot use the Store Worker app. Choose an active worker.';
    }
    state = worker;
    return null;
  }

  /// Ends the preview.
  void exit() => state = null;
}
