import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.watch(staffServiceProvider));
});

/// Error with a message to show on screen.
class StaffException extends AppException {
  const StaffException(super.message);
}

/// Store Workers for the Staff tab, saved in Firestore.
class StaffRepository {
  StaffRepository(this._service);

  final StaffService _service;

  /// One page of the packers of the branch plus all drivers.
  /// Packers come first, then drivers, each sorted by name.
  /// Workers are few, so all are loaded and the page is cut here.
  Future<PageResult<Worker>> getWorkers(
    String branchId, {
    String searchText = '',
    int page = 1,
  }) async {
    final workers = await _run(_service.getWorkers);

    final matching =
        workers.where((worker) {
          final isListed = worker.isDriver || worker.branchId == branchId;
          return isListed && worker.matchesSearch(searchText);
        }).toList()..sort((a, b) {
          if (a.role != b.role) return a.role.index.compareTo(b.role.index);
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    return PageResult.fromList(matching, page: page);
  }

  /// Creates a worker through the admin-only Function.
  Future<void> addWorker({
    required String name,
    required String email,
    required String phone,
    required String temporaryPassword,
    required WorkerRole role,
    required String? branchId,
  }) async {
    try {
      await _service.createStaff(
        name: name,
        email: email,
        phone: phone,
        temporaryPassword: temporaryPassword,
        role: role,
        branchId: branchId,
      );
    } on FirebaseFunctionsException catch (e) {
      throw StaffException(_messageFor(e));
    }
  }

  /// Saves changed details or the active flag.
  Future<void> updateWorker(Worker worker) {
    return _run(() => _service.updateWorker(worker));
  }

  /// Runs a Firestore call through the shared [guard].
  Future<T> _run<T>(Future<T> Function() call) {
    return guard(
      call,
      label: 'staff',
      onError: () => const StaffException(kNetworkErrorMessage),
    );
  }

  String _messageFor(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'already-exists':
        return 'An account with this email already exists.';
      case 'unavailable':
        return 'No internet connection. Please check and try again.';
      case 'permission-denied':
        return 'Only HQ admin can manage staff.';
      case 'invalid-argument':
        return e.message ?? 'Please check the worker details.';
      default:
        return 'Could not create the worker. Please try again.';
    }
  }
}
