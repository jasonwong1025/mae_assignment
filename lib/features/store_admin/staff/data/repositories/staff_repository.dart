import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/sample_workers.dart';
import 'package:mae_assignment/shared/models/page_result.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository();
});

/// Error with a message to show on screen.
class StaffException implements Exception {
  const StaffException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Store Workers for the Staff tab.
/// No backend yet: workers are kept in memory and reset on restart.
class StaffRepository {
  final List<Worker> _workers = sampleWorkers();
  int _nextId = 100;

  /// One page of the packers of the branch plus all drivers.
  /// Packers come first, then drivers, each sorted by name.
  Future<PageResult<Worker>> getWorkers(
    String branchId, {
    String searchText = '',
    int page = 1,
  }) async {
    final matching =
        _workers.where((worker) {
          final isListed = worker.isDriver || worker.branchId == branchId;
          return isListed && worker.matchesSearch(searchText);
        }).toList()..sort((a, b) {
          if (a.role != b.role) return a.role.index.compareTo(b.role.index);
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    return PageResult.fromList(matching, page: page);
  }

  /// All active drivers. Drivers work for every branch.
  Future<List<Worker>> getDrivers() async {
    return _workers
        .where((worker) => worker.isDriver && worker.isActive)
        .toList();
  }

  /// Adds a worker. They sign in with [temporaryPassword].
  Future<Worker> addWorker({
    required String name,
    required String email,
    required String phone,
    required String temporaryPassword,
    required WorkerRole role,
    required String? branchId,
  }) async {
    _checkEmailIsFree(email);

    // TODO(team): create the Firebase account. The password is not saved yet.
    final worker = Worker(
      id: 'w${_nextId++}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      branchId: role == WorkerRole.deliveryDriver ? null : branchId,
      isActive: true,
      isOnDuty: false,
      ordersToday: const [],
      joinedAt: DateTime.now(),
    );
    _workers.add(worker);
    return worker;
  }

  /// Replaces the worker that has the same id.
  Future<void> updateWorker(Worker worker) async {
    _checkEmailIsFree(worker.email, exceptWorkerId: worker.id);

    final index = _workers.indexWhere((old) => old.id == worker.id);
    if (index == -1) {
      throw const StaffException('This worker no longer exists.');
    }
    _workers[index] = worker;
  }

  /// Emails must be unique because workers sign in with them.
  void _checkEmailIsFree(String email, {String? exceptWorkerId}) {
    final isTaken = _workers.any((worker) {
      return worker.id != exceptWorkerId &&
          worker.email.toLowerCase() == email.toLowerCase();
    });
    if (isTaken) {
      throw const StaffException('A worker with this email already exists.');
    }
  }
}
