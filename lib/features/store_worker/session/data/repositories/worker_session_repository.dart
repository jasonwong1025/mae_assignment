import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/data/services/worker_profile_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

final workerSessionRepositoryProvider = Provider<WorkerSessionRepository>((
  ref,
) {
  return WorkerSessionRepository(
    ref.watch(authRepositoryProvider),
    ref.watch(workerProfileServiceProvider),
  );
});

/// Error with a message that is safe to show on screen.
class WorkerSessionException extends AppException {
  const WorkerSessionException(super.message);
}

/// Finds out who the signed-in Store Worker is.
class WorkerSessionRepository {
  WorkerSessionRepository(this._auth, this._profiles);

  final AuthRepository _auth;
  final WorkerProfileService _profiles;

  /// The signed-in worker's profile. Throws [WorkerSessionException] if
  /// nobody is signed in, the account is not a Store Worker, or the
  /// profile cannot be read.
  Future<WorkerProfile> loadCurrent() {
    return guard(
      () async {
        final user = await _auth.getCurrentUser();
        if (user == null || user.role != UserRole.storeWorker) {
          throw const WorkerSessionException(
            'This account is not a Store Worker.',
          );
        }
        final profile = await _profiles.getProfile(user.uid);
        if (profile == null) {
          throw const WorkerSessionException(
            'Your worker profile is missing. Please contact HQ.',
          );
        }
        return profile;
      },
      label: 'worker session',
      onError: () => const WorkerSessionException(
        'Could not load your worker profile. Please check your connection '
        'and try again.',
      ),
    );
  }
}
