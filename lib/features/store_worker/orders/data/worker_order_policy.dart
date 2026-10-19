import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';

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

  /// Active and assigned to the order's branch. Only Packing Staff have a
  /// branch; drivers are never "in" one (they are limited by assignment).
  static bool _inBranch(WorkerProfile worker, Order order) {
    return worker.isActive &&
        worker.branchId != null &&
        worker.branchId == order.branchId;
  }

  /// My Packing Tasks: orders assigned to this packer at their branch.
  static bool canViewPackingTask(WorkerProfile worker, Order order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.packerId == worker.id;
  }

  /// Ready for Pickup: every ready self-pickup order at the packer's
  /// branch, whoever packed it.
  static bool canViewPickupOrder(WorkerProfile worker, Order order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.isPickup &&
        order.status == OrderStatus.ready;
  }

  /// Pickups this packer handed over themselves.
  static bool canViewCompletedPickup(WorkerProfile worker, Order order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.isPickup &&
        order.status == OrderStatus.completed &&
        order.pickupCompletedBy == worker.id;
  }

  /// Waiting for drivers: delivery orders at the packer's branch that are
  /// packed and ready but not yet verified by their driver. Read-only, so
  /// any packer can find the bag when a driver asks; only the driver
  /// collects it.
  static bool canViewWaitingForDriver(WorkerProfile worker, Order order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.isDelivery &&
        order.driverId != null &&
        order.status == OrderStatus.ready &&
        order.collectionVerifiedBy != order.driverId;
  }

  /// Opening a ready delivery order at the packer's branch, read-only, to
  /// find the bag for its driver. Stays open after the driver verifies it
  /// (still ready), so the packer sees it was collected.
  static bool canViewBranchDelivery(WorkerProfile worker, Order order) {
    return worker.isPackingStaff &&
        _inBranch(worker, order) &&
        order.isDelivery &&
        order.driverId != null &&
        order.status == OrderStatus.ready;
  }

  /// My Deliveries: delivery orders assigned to this driver, from any
  /// branch, in any status, including while still being packed.
  static bool canViewDelivery(WorkerProfile worker, Order order) {
    // Any branch: drivers are not tied to one. What limits them is that
    // HQ assigned the delivery to them.
    return worker.isDeliveryDriver &&
        worker.isActive &&
        order.isDelivery &&
        order.driverId == worker.id;
  }

  /// True if the worker may open the order's details at all.
  static bool canViewOrder(WorkerProfile worker, Order order) {
    return canViewPackingTask(worker, order) ||
        canViewPickupOrder(worker, order) ||
        canViewCompletedPickup(worker, order) ||
        canViewBranchDelivery(worker, order) ||
        canViewDelivery(worker, order);
  }

  // ---------------------------------------------------------------------
  // Packing: pending -> packing -> ready, by the assigned packer only.
  // ---------------------------------------------------------------------

  static String? _packerCheck(WorkerProfile worker, Order order) {
    if (!worker.isActive) return _inactiveMessage;
    if (!worker.isPackingStaff) return 'Only Packing Staff can pack orders.';
    if (worker.branchId != order.branchId) return _otherBranchMessage;
    if (order.packerId != worker.id) {
      return 'This order is assigned to ${order.packerName}.';
    }
    if (order.status == OrderStatus.cancelled) return _cancelledMessage;
    return null;
  }

  static String? checkStartPacking(WorkerProfile worker, Order order) {
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
    Order order,
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

  static String? checkMarkReady(WorkerProfile worker, Order order) {
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

  static String? checkCompletePickup(WorkerProfile worker, Order order) {
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

  static String? _driverCheck(WorkerProfile worker, Order order) {
    if (!worker.isActive) return _inactiveMessage;
    if (!worker.isDeliveryDriver) {
      return 'Only Delivery Drivers can deliver orders.';
    }
    // No branch check: a driver can deliver for any branch, as long as the
    // order is assigned to them (checked below).
    if (order.isPickup) {
      return 'This is a self-pickup order. It is handed over at the store.';
    }
    if (order.driverId != worker.id) {
      return 'This delivery is not assigned to you.';
    }
    if (order.status == OrderStatus.cancelled) return _cancelledMessage;
    return null;
  }

  static String? checkVerifyCollection(WorkerProfile worker, Order order) {
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
  /// Manual: the collection code printed on the bag label. QR: the bag
  /// label's payload.
  static String? checkCollectionCode(
    Order order,
    VerificationMethod method,
    String code,
  ) {
    final matches = switch (method) {
      VerificationMethod.manual => _matchesCollectionCode(order, code),
      VerificationMethod.qr => code.trim() == order.qrPayload,
    };
    if (matches) return null;
    return switch (method) {
      VerificationMethod.manual =>
        'That code does not match order #${order.number}. '
            'Check the label on the bag and try again.',
      VerificationMethod.qr =>
        'This QR code is not for order #${order.number}.',
    };
  }

  /// Spaces and letter case are ignored, so "k7p 4qa" matches "K7P4QA".
  static bool _matchesCollectionCode(Order order, String typed) {
    final cleaned = typed.replaceAll(RegExp(r'\s'), '').toUpperCase();
    return cleaned == order.collectionCode;
  }

  static String? checkStartDelivery(WorkerProfile worker, Order order) {
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

  static String? checkCompleteDelivery(WorkerProfile worker, Order order) {
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
