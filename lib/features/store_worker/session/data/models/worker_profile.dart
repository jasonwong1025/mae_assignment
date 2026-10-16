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
    required this.branchId,
    required this.branchName,
    required this.isActive,
  });

  final String id;
  final String name;
  final String email;
  final String phone;

  /// Exactly one role. A worker is never both.
  final WorkerRole role;

  /// The one branch the worker is assigned to.
  final String branchId;
  final String branchName;

  /// False if HQ deactivated the worker. Inactive workers cannot use the
  /// Store Worker app.
  final bool isActive;

  bool get isPackingStaff => role == WorkerRole.packingStaff;
  bool get isDeliveryDriver => role == WorkerRole.deliveryDriver;
}
