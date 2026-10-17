import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mae_assignment/shared/models/worker_role.dart';

// WorkerRole now lives in shared/ so the Store Worker app can use it too.
// Re-exported so files that import this one keep working.
export '../../../../../shared/models/worker_role.dart';

/// A Store Worker. Saved in Firestore at users/{id} with role "storeWorker".
class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.branchId,
    required this.isActive,
    required this.joinedAt,
  });

  factory Worker.fromMap(String id, Map<String, dynamic> map) {
    final joinedAt = map['joinedAt'];
    return Worker(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['workerRole'] == WorkerRole.deliveryDriver.name
          ? WorkerRole.deliveryDriver
          : WorkerRole.packingStaff,
      branchId: map['branchId'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      // Null for a moment while the server time is being saved.
      joinedAt: joinedAt is Timestamp ? joinedAt.toDate() : DateTime.now(),
    );
  }

  /// Same id as the worker's Firebase login.
  final String id;
  final String name;

  /// Login email. Cannot be changed after the account is created.
  final String email;
  final String phone;
  final WorkerRole role;

  /// Packer's branch. Null for drivers (they work for every branch).
  final String? branchId;

  /// False if deactivated. Deactivated workers cannot sign in.
  final bool isActive;

  final DateTime joinedAt;

  bool get isDriver => role == WorkerRole.deliveryDriver;

  /// Fields saved in users/{id}. joinedAt is set by the service.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'storeWorker',
      'workerRole': role.name,
      'branchId': branchId,
      'isActive': isActive,
    };
  }

  /// True if [text] is in the name, phone or email.
  bool matchesSearch(String text) {
    final search = text.trim().toLowerCase();
    if (search.isEmpty) return true;

    final digits = search.replaceAll(RegExp(r'[\s-]'), '');
    final phoneDigits = phone.replaceAll(RegExp(r'[\s-]'), '');
    return name.toLowerCase().contains(search) ||
        email.toLowerCase().contains(search) ||
        (digits.isNotEmpty && phoneDigits.contains(digits));
  }

  /// Copy with new details. Drivers get no branch.
  Worker withDetails({
    required String name,
    required String phone,
    required WorkerRole role,
    required String? branchId,
  }) {
    return Worker(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      branchId: role == WorkerRole.deliveryDriver ? null : branchId,
      isActive: isActive,
      joinedAt: joinedAt,
    );
  }

  /// Copy that is active or not.
  Worker withActive({required bool active}) {
    return Worker(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      branchId: branchId,
      isActive: active,
      joinedAt: joinedAt,
    );
  }
}
