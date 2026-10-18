import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/worker_role.dart';

// WorkerRole now lives in shared/ so the Store Worker app can use it too.
// Re-exported so files that import this one keep working.
export '../../../../../shared/models/worker_role.dart';

part 'worker.freezed.dart';

/// A Store Worker. Saved in Firestore at users/{id} with role "storeWorker".
@freezed
abstract class Worker with _$Worker {
  const factory Worker({
    /// Same id as the worker's Firebase login.
    required String id,
    required String name,

    /// Login email. Cannot be changed after the account is created.
    required String email,
    required String phone,
    required WorkerRole role,

    /// Packer's branch. Null for drivers (they work for every branch).
    required String? branchId,

    /// False if deactivated. Deactivated workers cannot sign in.
    required bool isActive,
    required DateTime joinedAt,
  }) = _Worker;

  const Worker._();

  /// Reads users/{id}. `joinedAt` reads as now for a moment while the server
  /// time is still being saved.
  factory Worker.fromFirestore(String id, Map<String, dynamic> data) {
    return Worker(
      id: id,
      name: data.string(UserFields.name),
      email: data.string(UserFields.email),
      phone: data.string(UserFields.phone),
      role: data.enumValue(
        UserFields.workerRole,
        WorkerRole.values,
        fallback: WorkerRole.packingStaff,
      ),
      branchId: data.stringOrNull(UserFields.branchId),
      isActive: data.boolean(UserFields.isActive, fallback: true),
      joinedAt: data.dateTime(UserFields.joinedAt) ?? DateTime.now(),
    );
  }

  /// The worker's own fields in users/{id}. The document's `role` (always
  /// "storeWorker") and `joinedAt` are added by the service. A driver's
  /// `branchId` is written as null so it is cleared on update.
  Map<String, dynamic> toFirestore() {
    return {
      UserFields.name: name,
      UserFields.email: email,
      UserFields.phone: phone,
      UserFields.workerRole: role.name,
      UserFields.branchId: branchId,
      UserFields.isActive: isActive,
    };
  }

  bool get isDriver => role == WorkerRole.deliveryDriver;

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
    return copyWith(
      name: name,
      phone: phone,
      role: role,
      branchId: role == WorkerRole.deliveryDriver ? null : branchId,
    );
  }

  /// Copy that is active or not.
  Worker withActive({required bool active}) => copyWith(isActive: active);
}
