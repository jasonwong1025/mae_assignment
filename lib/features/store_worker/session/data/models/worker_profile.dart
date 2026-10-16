import 'package:mae_assignment/shared/models/worker_role.dart';

/// The Store Worker using the app: who they are, their one role and their
/// one branch.
///
/// Kept separate from AppUser on purpose. During the preview it comes from
/// mock data; once the backend is connected it will be read from the
/// worker's users/{uid} profile, and the screens will not need to change.
class WorkerProfile {
  const WorkerProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    this.branchId,
    this.branchName,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  /// Exactly one role. A worker is never both.
  final WorkerRole role;

  /// The one branch a Packing Staff member is permanently assigned to.
  /// Null for Delivery Drivers: they are not tied to a branch and can be
  /// given deliveries from any branch.
  final String? branchId;
  final String? branchName;

  /// Where the worker operates, for headers and the Account screen:
  /// the packer's branch, or "Cross-branch delivery" for drivers.
  String get coverageLabel => branchName ?? 'Cross-branch delivery';

  /// False if HQ deactivated the worker. Inactive workers cannot use the
  /// Store Worker app.
  final bool isActive;

  bool get isPackingStaff => role == WorkerRole.packingStaff;
  bool get isDeliveryDriver => role == WorkerRole.deliveryDriver;
}
