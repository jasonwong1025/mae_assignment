import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/models/page_result.dart';
import '../models/worker.dart';
import '../services/staff_service.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.watch(staffServiceProvider));
});

/// Error with a message to show on screen.
class StaffException implements Exception {
  const StaffException(this.message);

  final String message;

  @override
  String toString() => message;
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

    final matching = workers.where((worker) {
      final isListed = worker.isDriver || worker.branchId == branchId;
      return isListed && worker.matchesSearch(searchText);
    }).toList();

    matching.sort((a, b) {
      if (a.role != b.role) return a.role.index.compareTo(b.role.index);
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return PageResult.fromList(matching, page: page);
  }

  /// Creates the worker's login and profile. They sign in with
  /// [temporaryPassword].
  Future<void> addWorker({
    required String name,
    required String email,
    required String phone,
    required String temporaryPassword,
    required WorkerRole role,
    required String? branchId,
  }) async {
    final String id;
    try {
      id = await _service.createLogin(
        email: email,
        password: temporaryPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw StaffException(_messageFor(e));
    }

    final worker = Worker(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      branchId: role == WorkerRole.deliveryDriver ? null : branchId,
      isActive: true,
      joinedAt: DateTime.now(),
    );
    await _run(() => _service.createWorker(worker));
  }

  /// Saves changed details or the active flag.
  Future<void> updateWorker(Worker worker) {
    return _run(() => _service.updateWorker(worker));
  }

  /// Runs a Firestore call and turns any error into a StaffException.
  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error) {
      debugPrint('Staff request failed: $error');
      throw const StaffException(
        'Could not reach the server. Please check your connection.',
      );
    }
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email.';
      case 'weak-password':
        return 'The temporary password is too weak.';
      case 'network-request-failed':
        return 'No internet connection. Please check and try again.';
      default:
        return 'Could not create the login. Please try again.';
    }
  }
}
