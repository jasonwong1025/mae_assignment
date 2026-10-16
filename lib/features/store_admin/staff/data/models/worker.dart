import 'package:mae_assignment/shared/models/worker_role.dart';

// WorkerRole now lives in shared/ so the Store Worker app can use it too.
// Re-exported so files that import this one keep working.
export '../../../../../shared/models/worker_role.dart';

/// A Store Worker.
class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.branchId,
    required this.isActive,
    required this.isOnDuty,
    required this.ordersToday,
    required this.joinedAt,
    this.currentOrderNumber,
    this.minutesOnCurrentOrder,
    this.rating,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final WorkerRole role;

  /// Packer's branch. Null for drivers.
  final String? branchId;

  /// False if deactivated. Deactivated workers cannot sign in.
  final bool isActive;

  /// True if working today.
  final bool isOnDuty;

  /// Order being handled now. Null if free.
  final int? currentOrderNumber;
  final int? minutesOnCurrentOrder;

  /// Orders finished today, newest first.
  final List<int> ordersToday;

  /// Rating out of 5. Drivers only. Null if not rated yet.
  final double? rating;

  final DateTime joinedAt;

  bool get isDriver => role == WorkerRole.deliveryDriver;

  /// Text for the "Right now" column.
  String get rightNow {
    if (!isActive) return 'Deactivated';
    if (!isOnDuty) return 'Off duty';
    if (currentOrderNumber == null) return 'Free';
    return isDriver
        ? 'Delivering #$currentOrderNumber'
        : 'Packing #$currentOrderNumber';
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
    required String email,
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
      isOnDuty: isOnDuty,
      currentOrderNumber: currentOrderNumber,
      minutesOnCurrentOrder: minutesOnCurrentOrder,
      ordersToday: ordersToday,
      // Only drivers have a rating.
      rating: role == WorkerRole.deliveryDriver ? rating : null,
      joinedAt: joinedAt,
    );
  }

  /// Copy working on [orderNumber]. Null makes the worker free.
  Worker withCurrentOrder(int? orderNumber) {
    return Worker(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      branchId: branchId,
      isActive: isActive,
      isOnDuty: isOnDuty,
      currentOrderNumber: orderNumber,
      minutesOnCurrentOrder: orderNumber == null ? null : 0,
      ordersToday: ordersToday,
      rating: rating,
      joinedAt: joinedAt,
    );
  }

  /// Copy that is active or not. Deactivating also clears duty and order.
  Worker withActive({required bool active}) {
    return Worker(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      branchId: branchId,
      isActive: active,
      isOnDuty: active && isOnDuty,
      currentOrderNumber: active ? currentOrderNumber : null,
      minutesOnCurrentOrder: active ? minutesOnCurrentOrder : null,
      ordersToday: ordersToday,
      rating: rating,
      joinedAt: joinedAt,
    );
  }
}
