import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';

/// In-memory StaffService, so tests do not need Firebase.
/// SS15 has 12 packers (Nadia Yusof is deactivated), Puchong 3,
/// Bukit Jalil 1, and there are 14 drivers.
class FakeStaffService extends Fake implements StaffService {
  final List<Worker> workers = [
    _worker('w1', 'Daniel Lee', branchId: 'ss15'),
    _worker('w2', 'Hakim Roslan', branchId: 'ss15'),
    _worker('w3', 'Nadia Yusof', branchId: 'ss15', isActive: false),
    for (var i = 4; i <= 12; i++) _worker('w$i', 'Packer $i', branchId: 'ss15'),
    _worker('w13', 'Syafiq Azman', branchId: 'puchong'),
    _worker('w14', 'Hannah Lee', branchId: 'puchong'),
    _worker('w15', 'Izzat Karim', branchId: 'puchong'),
    _worker('w16', 'Hafiz Zainal', branchId: 'bukit-jalil'),
    _worker('w17', 'Amir Hamzah'),
    _worker('w18', 'Lau Wei Jie'),
    _worker('w19', 'Tan Wei Loon', isActive: false),
    for (var i = 20; i <= 30; i++) _worker('w$i', 'Driver $i'),
  ];

  /// Emails that already have a login.
  final Set<String> logins = {};

  int _nextId = 100;

  @override
  Future<List<Worker>> getWorkers() async => [...workers];

  @override
  Future<String> createLogin({
    required String email,
    required String password,
  }) async {
    final taken =
        logins.contains(email) ||
        workers.any((worker) => worker.email == email);
    if (taken) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    logins.add(email);
    return 'w${_nextId++}';
  }

  @override
  Future<void> createWorker(Worker worker) async => workers.add(worker);

  @override
  Future<void> updateWorker(Worker worker) async {
    final index = workers.indexWhere((old) => old.id == worker.id);
    workers[index] = worker;
  }
}

/// A packer if [branchId] is given, otherwise a driver.
Worker _worker(
  String id,
  String name, {
  String? branchId,
  bool isActive = true,
}) {
  return Worker(
    id: id,
    name: name,
    email: '${name.toLowerCase().replaceAll(' ', '.')}@grocerly.my',
    phone: '012-555 0${id.substring(1).padLeft(3, '0')}',
    role: branchId == null
        ? WorkerRole.deliveryDriver
        : WorkerRole.packingStaff,
    branchId: branchId,
    isActive: isActive,
    joinedAt: DateTime(2025, 3, 12),
  );
}
