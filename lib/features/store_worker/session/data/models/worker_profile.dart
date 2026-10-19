import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/worker_role.dart';

part 'worker_profile.freezed.dart';

/// The Store Worker using the app: who they are, their one role and their
/// one branch.
///
/// Kept separate from AppUser on purpose: it adds the worker's role and
/// branch. Read from the signed-in worker's users/{uid} profile.
@freezed
abstract class WorkerProfile with _$WorkerProfile {
  const factory WorkerProfile({
    required String id,
    required String name,
    required String email,
    required String phone,

    /// Exactly one role. A worker is never both.
    required WorkerRole role,

    /// False if HQ deactivated the worker. Inactive workers cannot use the
    /// Store Worker app.
    required bool isActive,

    /// The one branch a Packing Staff member is permanently assigned to.
    /// Null for Delivery Drivers: they are not tied to a branch and can be
    /// given deliveries from any branch.
    String? branchId,
    String? branchName,
  }) = _WorkerProfile;

  const WorkerProfile._();

  /// Reads users/{id} of a Store Worker. [branchName] is looked up from the
  /// worker's branch document. An unknown role reads as Packing Staff.
  factory WorkerProfile.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    String? branchName,
  }) {
    return WorkerProfile(
      id: id,
      name: data.string(UserFields.name),
      email: data.string(UserFields.email),
      phone: data.string(UserFields.phone),
      role: data.enumValue(
        UserFields.workerRole,
        WorkerRole.values,
        fallback: WorkerRole.packingStaff,
      ),
      isActive: data.boolean(UserFields.isActive, fallback: true),
      branchId: data.stringOrNull(UserFields.branchId),
      branchName: branchName,
    );
  }

  /// Where the worker operates, for headers and the Account screen:
  /// the packer's branch, or "Cross-branch delivery" for drivers.
  String get coverageLabel => branchName ?? 'Cross-branch delivery';

  bool get isPackingStaff => role == WorkerRole.packingStaff;
  bool get isDeliveryDriver => role == WorkerRole.deliveryDriver;
}
