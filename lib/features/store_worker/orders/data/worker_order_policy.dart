import '../../../../shared/models/order_status.dart';
import '../../session/data/models/worker_profile.dart';
import 'models/worker_order.dart';

/// The rules for what a Store Worker may see and do with an order.
///
/// Plain functions with no Flutter or Firebase code, so they are easy to
/// test. The repository enforces them before changing any order, and
/// screens use the same functions to enable or disable buttons.
///
/// These rules only run inside the app. Once the backend is connected,
/// Firestore Security Rules must enforce the same checks on the server;
/// these do not replace them.
///
/// Like Validators, the check functions return an error message to show,
/// or null if the action is allowed.
class WorkerOrderPolicy {
  WorkerOrderPolicy._();

  // ---------------------------------------------------------------------
  // What a worker may see.
  // ---------------------------------------------------------------------

  /// Active and working at the order's branch.
  static bool _inBranch(WorkerProfile worker, WorkerOrder order) {
    return worker.isActive && worker.branchId == order.branchId;
  }

  /// My Packing Tasks: orders assigned to this packer at their branch.
  static bool canViewPackingTask(WorkerProfile worker, WorkerOrder order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.packerId == worker.id;
  }

  /// Ready for Pickup: every ready self-pickup order at the packer's
  /// branch, whoever packed it.
  static bool canViewPickupOrder(WorkerProfile worker, WorkerOrder order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.isPickup &&
        order.status == OrderStatus.ready;
  }

  /// Pickups this packer handed over themselves.
  static bool canViewCompletedPickup(WorkerProfile worker, WorkerOrder order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.isPickup &&
        order.status == OrderStatus.completed &&
        order.pickupCompletedBy == worker.id;
  }

  /// My Deliveries: delivery orders assigned to this driver at their
  /// branch, in any status, including while still being packed.
  static bool canViewDelivery(WorkerProfile worker, WorkerOrder order) {
    return worker.isDeliveryDriver &&
        _inBranch(worker, order) &&
        order.isDelivery &&
        order.driverId == worker.id;
  }

  /// True if the worker may open the order's details at all.
  static bool canViewOrder(WorkerProfile worker, WorkerOrder order) {
    return canViewPackingTask(worker, order) ||
        canViewPickupOrder(worker, order) ||
        canViewCompletedPickup(worker, order) ||
        canViewDelivery(worker, order);
  }

  // ---------------------------------------------------------------------
  // Packing: pending -> packing -> ready, by the assigned packer only.
  // ---------------------------------------------------------------------

  static String? _packerCheck(WorkerProfile worker, WorkerOrder order) {
    if (!worker.isActive) return _inactiveMessage;
    if (!worker.isPackingStaff) return 'Only Packing Staff can pack orders.';
    if (worker.branchId != order.branchId) return _otherBranchMessage;
    if (order.packerId != worker.id) {
      return 'This order is assigned to ${order.packerName}.';
    }
    if (order.status == OrderStatus.cancelled) return _cancelledMessage;
    return null;
  }

  static String? checkStartPacking(WorkerProfile worker, WorkerOrder order) {
    final error = _packerCheck(worker, order);
    if (error != null) return error;
    if (order.status != OrderStatus.pending) {
      return 'Packing has already started for this order.';
    }
    return null;
  }

  /// Ticking or unticking [lineId] on the checklist.
  static String? checkEditChecklist(
    WorkerProfile worker,
    WorkerOrder order,
    String lineId,
  ) {
    final error = _packerCheck(worker, order);
    if (error != null) return error;
    if (order.status == OrderStatus.pending) {
      return 'Start packing before ticking items.';
    }
    if (order.status != OrderStatus.packing) {
      return 'This order is no longer being packed.';
    }
    if (!order.hasLine(lineId)) return 'This item is not part of the order.';
    return null;
  }

  static String? checkMarkReady(WorkerProfile worker, WorkerOrder order) {
    final error = _packerCheck(worker, order);
    if (error != null) return error;
    if (order.status == OrderStatus.pending) {
      return 'Start packing before marking the order ready.';
    }
    if (order.status != OrderStatus.packing) {
      return 'This order has already been marked ready.';
    }
    final left = order.lineCount - order.packedLineCount;
    if (left > 0) {
      return left == 1
          ? '1 item still needs to be packed.'
          : '$left items still need to be packed.';
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Self-pickup: ready -> completed, by any active packer at the branch.
  // ---------------------------------------------------------------------

  static String? checkCompletePickup(WorkerProfile worker, WorkerOrder order) {
    if (!worker.isActive) return _inactiveMessage;
    if (!worker.isPackingStaff) {
      return 'Only Packing Staff can hand over pickup orders.';
    }
    if (worker.branchId != order.branchId) return _otherBranchMessage;
    if (order.isDelivery) {
      return 'This is a delivery order. Its driver completes it.';
    }
    if (order.status == OrderStatus.cancelled) return _cancelledMessage;
    if (order.status == OrderStatus.completed) {
      final by = order.pickupCompletedByName;
      return by == null
          ? 'This order has already been handed over.'
          : 'This order has already been handed over by $by.';
    }
    if (order.status != OrderStatus.ready) {
      return 'This order is not ready for pickup yet.';
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Home delivery: ready -> verify -> out for delivery -> completed,
  // by the assigned driver only.
  // ---------------------------------------------------------------------

  static String? _driverCheck(WorkerProfile worker, WorkerOrder order) {
    if (!worker.isActive) return _inactiveMessage;
    if (!worker.isDeliveryDriver) {
      return 'Only Delivery Drivers can deliver orders.';
    }
    if (worker.branchId != order.branchId) return _otherBranchMessage;
    if (order.isPickup) {
      return 'This is a self-pickup order. It is handed over at the store.';
    }
    if (order.driverId != worker.id) {
      return 'This delivery is not assigned to you.';
    }
    if (order.status == OrderStatus.cancelled) return _cancelledMessage;
    return null;
  }

  static String? checkVerifyCollection(
    WorkerProfile worker,
    WorkerOrder order,
  ) {
    final error = _driverCheck(worker, order);
    if (error != null) return error;
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.packing:
        return 'This order is still being packed.';
      case OrderStatus.ready:
        return null;
      case OrderStatus.outForDelivery:
      case OrderStatus.completed:
        return 'This order has already been collected.';
      case OrderStatus.cancelled:
        return _cancelledMessage;
    }
  }

  /// Checks the code a driver entered or scanned against the order.
  /// Manual: the order number on the bag. QR: the bag label's payload.
  static String? checkCollectionCode(
    WorkerOrder order,
    VerificationMethod method,
    String code,
  ) {
    final matches = switch (method) {
      VerificationMethod.manual => _matchesNumber(order, code),
      VerificationMethod.qr => code.trim() == order.qrPayload,
    };
    if (matches) return null;
    return switch (method) {
      VerificationMethod.manual =>
        'That number does not match order #${order.number}. '
            'Check the bag and try again.',
      VerificationMethod.qr =>
        'This QR code is not for order #${order.number}.',
    };
  }

  /// Spaces and a leading "#" are ignored, so "2308", " 2308 " and "#2308"
  /// all match order #2308.
  static bool _matchesNumber(WorkerOrder order, String typed) {
    final digits = typed.trim().replaceFirst('#', '').trim();
    return digits == order.number.toString();
  }

  static String? checkStartDelivery(WorkerProfile worker, WorkerOrder order) {
    final error = _driverCheck(worker, order);
    if (error != null) return error;
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.packing:
        return 'This order is still being packed.';
      case OrderStatus.ready:
        if (order.collectionVerifiedBy != worker.id) {
          return 'Verify the order before starting the delivery.';
        }
        return null;
      case OrderStatus.outForDelivery:
        return 'This delivery has already started.';
      case OrderStatus.completed:
        return 'This delivery is already completed.';
      case OrderStatus.cancelled:
        return _cancelledMessage;
    }
  }

  static String? checkCompleteDelivery(
    WorkerProfile worker,
    WorkerOrder order,
  ) {
    final error = _driverCheck(worker, order);
    if (error != null) return error;
    switch (order.status) {
      case OrderStatus.outForDelivery:
        return null;
      case OrderStatus.completed:
        return 'This delivery is already completed.';
      case OrderStatus.cancelled:
        return _cancelledMessage;
      case OrderStatus.pending:
      case OrderStatus.packing:
      case OrderStatus.ready:
        return 'Start the delivery before marking it delivered.';
    }
  }

  static const _inactiveMessage =
      'Your account has been deactivated. Ask HQ for help.';
  static const _otherBranchMessage = 'This order belongs to another branch.';
  static const _cancelledMessage = 'This order was cancelled.';
}
