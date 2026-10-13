import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/worker.dart';
import '../../data/repositories/staff_repository.dart';

final staffViewModelProvider =
    AsyncNotifierProvider.autoDispose<StaffViewModel, List<Worker>>(
      StaffViewModel.new,
    );

/// State for the Staff tab: the workers to show.
/// Methods that change a worker return an error message, or null if
/// it worked.
class StaffViewModel extends AsyncNotifier<List<Worker>> {
  @override
  Future<List<Worker>> build() async {
    // Runs again when the branch changes.
    final branchState = await ref.watch(branchViewModelProvider.future);
    final repository = ref.watch(staffRepositoryProvider);
    return repository.getWorkers(branchState.selected.id);
  }

  Future<String?> addWorker({
    required String name,
    required String email,
    required String phone,
    required String temporaryPassword,
    required WorkerRole role,
    required String? branchId,
  }) async {
    try {
      await ref
          .read(staffRepositoryProvider)
          .addWorker(
            name: name.trim(),
            // Firebase stores emails in lowercase.
            email: email.trim().toLowerCase(),
            phone: phone.trim(),
            temporaryPassword: temporaryPassword,
            role: role,
            branchId: branchId,
          );
    } on StaffException catch (e) {
      return e.message;
    }
    await _reload();
    return null;
  }

  Future<String?> updateDetails(
    Worker worker, {
    required String name,
    required String email,
    required String phone,
    required WorkerRole role,
    required String? branchId,
  }) {
    return _save(
      worker.withDetails(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        role: role,
        branchId: branchId,
      ),
    );
  }

  /// Deactivates or reactivates a worker.
  Future<String?> setActive(Worker worker, {required bool active}) {
    return _save(worker.withActive(active));
  }

  Future<String?> _save(Worker worker) async {
    try {
      await ref.read(staffRepositoryProvider).updateWorker(worker);
    } on StaffException catch (e) {
      return e.message;
    }
    await _reload();
    return null;
  }

  /// Reloads the list.
  Future<void> _reload() async {
    ref.invalidateSelf();
    await future;
  }
}
