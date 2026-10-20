import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_worker/orders/data/order_due_time.dart';
import 'package:mae_assignment/features/store_worker/orders/data/services/delivery_proof_service.dart';
import 'package:mae_assignment/features/store_worker/orders/data/worker_order_policy.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';
import 'package:mae_assignment/shared/models/verification_method.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final workerOrdersRepositoryProvider = Provider<WorkerOrdersRepository>((ref) {
  return WorkerOrdersRepository(
    ref.watch(orderServiceProvider),
    ref.watch(deliveryProofServiceProvider),
  );
});

/// Error with a message that is safe to show on screen.
class WorkerOrderException extends AppException {
  const WorkerOrderException(super.message);
}

/// Orders for every Store Worker screen: packing, pickup and delivery.
///
/// Orders live in the shared Firestore `orders` collection. A packer
/// watches their branch's orders; a driver watches the orders assigned to
/// them. Lists are then narrowed by [WorkerOrderPolicy], so each worker
/// sees only what they may, and every action checks the policy again inside
/// one transaction, so two workers cannot act on the same order at once.
/// Actions throw [WorkerOrderException] if not allowed. `firestore.rules`
/// enforces the same limits on the server (a worker may only write
/// fulfilment fields).
class WorkerOrdersRepository {
  WorkerOrdersRepository(
    this._service,
    this._proofs, {
    DateTime Function()? clock,
    this.actionDelay = Duration.zero,
  }) : _clock = clock ?? DateTime.now;

  final OrderService _service;
  final DeliveryProofService _proofs;
  final DateTime Function() _clock;

  /// Wait before each action. Zero unless a screen wants to show a spinner
  /// for longer; tests use zero.
  final Duration actionDelay;

  // ---------------------------------------------------------------------
  // Lists
  // ---------------------------------------------------------------------

  /// My Tasks: orders assigned to [worker] to pack that are not ready yet,
  /// due soonest first.
  Stream<List<Order>> watchMyPackingTasks(WorkerProfile worker) {
    return _watchList(worker, (orders) {
      final tasks =
          orders.where((order) {
            return WorkerOrderPolicy.canViewPackingTask(worker, order) &&
                (order.status == OrderStatus.pending ||
                    order.status == OrderStatus.packing);
          }).toList()..sort((a, b) {
            final byDue = _compareDates(a.promisedAt, b.promisedAt);
            if (byDue != 0) return byDue;
            return _compareDates(a.packerAssignedAt, b.packerAssignedAt);
          });
      return tasks;
    });
  }

  /// Ready for Pickup: every ready self-pickup order at [worker]'s branch,
  /// whoever packed it. Pickup time soonest first.
  Stream<List<Order>> watchReadyForPickup(WorkerProfile worker) {
    return _watchList(worker, (orders) {
      final ready = orders.where((order) {
        return WorkerOrderPolicy.canViewPickupOrder(worker, order);
      }).toList()..sort(_byDueThenReady);
      return ready;
    });
  }

  /// Delivery bags at [worker]'s branch waiting for their driver to
  /// collect them, delivery time soonest first. Read-only for packers.
  Stream<List<Order>> watchWaitingForDrivers(WorkerProfile worker) {
    return _watchList(worker, (orders) {
      final waiting = orders.where((order) {
        return WorkerOrderPolicy.canViewWaitingForDriver(worker, order);
      }).toList()..sort(_byDueThenReady);
      return waiting;
    });
  }

  /// My history, newest first:
  /// - Packing Staff: orders they packed (ready, collected or completed),
  ///   by when they marked them ready.
  /// - Delivery Drivers: deliveries they completed, by when.
  Stream<List<Order>> watchMyHistory(WorkerProfile worker) {
    return _watchList(worker, (orders) {
      final List<Order> history;
      if (worker.isPackingStaff) {
        history = orders.where((order) {
          return WorkerOrderPolicy.canViewPackingTask(worker, order) &&
              order.readyAt != null &&
              const [
                OrderStatus.ready,
                OrderStatus.outForDelivery,
                OrderStatus.completed,
              ].contains(order.status);
        }).toList()..sort((a, b) => _compareDates(b.readyAt, a.readyAt));
      } else {
        history = orders.where(
          (order) {
            return WorkerOrderPolicy.canViewDelivery(worker, order) &&
                order.status == OrderStatus.completed;
          },
        ).toList()..sort((a, b) => _compareDates(b.completedAt, a.completedAt));
      }
      return history;
    });
  }

  /// My Deliveries: every delivery assigned to [worker], in any status.
  /// Sorted by stage (on the way, ready, being packed, finished), then by
  /// when it was assigned.
  Stream<List<Order>> watchMyDeliveries(WorkerProfile worker) {
    return _watchList(worker, (orders) {
      final deliveries =
          orders.where((order) {
            return WorkerOrderPolicy.canViewDelivery(worker, order);
          }).toList()..sort((a, b) {
            final byStage = _deliveryStage(a).compareTo(_deliveryStage(b));
            if (byStage != 0) return byStage;
            return _compareDates(a.driverAssignedAt, b.driverAssignedAt);
          });
      return deliveries;
    });
  }

  /// One order, or null if it does not exist or [worker] may not see it
  /// (any more). Sends a new value whenever the order changes.
  Stream<Order?> watchOrder(WorkerProfile worker, String orderId) {
    return _ordersFor(worker).map((orders) {
      final order = _find(orders, orderId);
      if (order == null) return null;
      return WorkerOrderPolicy.canViewOrder(worker, order) ? order : null;
    }).distinct();
  }

  // ---------------------------------------------------------------------
  // Packing
  // ---------------------------------------------------------------------

  Future<void> startPacking(WorkerProfile worker, String orderId) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkStartPacking(worker, order));
      final now = _clock();
      return order.copyWith(
        status: OrderStatus.packing,
        statusSince: now,
        packingStartedAt: now,
      );
    });
  }

  /// Ticks ([packed] true) or unticks one line of the checklist.
  Future<void> setItemPacked(
    WorkerProfile worker,
    String orderId,
    String lineId, {
    required bool packed,
  }) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkEditChecklist(worker, order, lineId));
      final lines = {...order.packedLineIds};
      if (packed) {
        lines.add(lineId);
      } else {
        lines.remove(lineId);
      }
      return order.copyWith(packedLineIds: lines);
    });
  }

  Future<void> markReady(WorkerProfile worker, String orderId) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkMarkReady(worker, order));
      final now = _clock();
      return order.copyWith(
        status: OrderStatus.ready,
        statusSince: now,
        readyAt: now,
        readyBy: worker.id,
        // Removed lines are never ticked, but the checklist must still
        // account for every line (firestore.rules compares its size with
        // the number of lines), so they are added here.
        packedLineIds: {...order.packedLineIds, ...order.removedLineIds},
      );
    });
  }

  /// Reports one line unavailable. With a [replacement] (an item from the
  /// branch's stock) the customer is asked; without one the line is removed
  /// from the order at once.
  Future<void> flagUnavailable(
    WorkerProfile worker,
    String orderId,
    String lineId, {
    OrderItem? replacement,
  }) {
    return _guarded(() async {
      final order = await _service.getOrder(orderId);
      if (order == null) {
        throw const WorkerOrderException('This order no longer exists.');
      }
      _allow(WorkerOrderPolicy.checkFlagUnavailable(worker, order, lineId));
      final saved = await _service.flagShortage(
        orderId,
        lineId,
        replacement: replacement,
      );
      if (!saved) {
        throw const WorkerOrderException(
          'This item could not be reported. The order may have changed, '
          'please try again.',
        );
      }
    });
  }

  // ---------------------------------------------------------------------
  // Self-pickup
  // ---------------------------------------------------------------------

  /// Hands a ready pickup order to the customer. The screen checks the
  /// customer first and passes how it was checked as [method]. For
  /// [VerificationMethod.qr], [code] is the text scanned from the customer's
  /// phone and must be that order's handover code.
  Future<void> completePickup(
    WorkerProfile worker,
    String orderId, {
    required VerificationMethod method,
    String? code,
  }) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkCompletePickup(worker, order));
      if (method == VerificationMethod.qr) {
        _allow(WorkerOrderPolicy.checkPickupQr(order, code ?? ''));
      }
      final now = _clock();
      return order.copyWith(
        status: OrderStatus.completed,
        statusSince: now,
        pickupVerification: method,
        pickupCompletedBy: worker.id,
        pickupCompletedByName: worker.name,
        completedAt: now,
      );
    });
  }

  // ---------------------------------------------------------------------
  // Home delivery
  // ---------------------------------------------------------------------

  /// Confirms the driver has the right bag. [code] is the collection code
  /// they typed ([VerificationMethod.manual]) or the scanned QR text
  /// ([VerificationMethod.qr]). The status stays ready.
  Future<void> verifyCollection(
    WorkerProfile worker,
    String orderId, {
    required VerificationMethod method,
    required String code,
  }) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkVerifyCollection(worker, order));
      _allow(WorkerOrderPolicy.checkCollectionCode(order, method, code));
      return order.copyWith(
        collectionVerification: method,
        collectionVerifiedBy: worker.id,
        collectionVerifiedAt: _clock(),
      );
    });
  }

  Future<void> startDelivery(WorkerProfile worker, String orderId) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkStartDelivery(worker, order));
      final now = _clock();
      return order.copyWith(
        status: OrderStatus.outForDelivery,
        statusSince: now,
        outForDeliveryAt: now,
      );
    });
  }

  /// Needs a proof of delivery photo.
  Future<void> completeDelivery(
    WorkerProfile worker,
    String orderId, {
    required Uint8List photo,
  }) {
    return _actWith<String>(
      orderId,
      check: (order) {
        _allow(WorkerOrderPolicy.checkCompleteDelivery(worker, order));
        _allow(photo.isEmpty ? 'Take a photo of the delivery first.' : null);
      },
      // Uploaded only after the checks pass, so a refused delivery leaves no
      // photo behind.
      prepare: () => _proofs.upload(orderId, photo),
      change: (order, proofUrl) {
        final now = _clock();
        return order.copyWith(
          status: OrderStatus.completed,
          statusSince: now,
          deliveredBy: worker.id,
          deliveredByName: worker.name,
          proofPhotoUrl: proofUrl,
          completedAt: now,
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Runs one action in a transaction on the order as it is now (another
  /// worker may have changed it a moment ago): [change] checks the rules and
  /// builds the new copy; only the fields that differ are saved.
  Future<void> _act(String orderId, Order Function(Order order) change) {
    return _guarded(() async {
      final saved = await _service.updateOrder(orderId, change);
      if (saved == null) {
        throw const WorkerOrderException('This order no longer exists.');
      }
    });
  }

  /// Like [_act], for an action that first needs something from outside the
  /// transaction (an upload). [check] runs on the current order before
  /// [prepare], and again inside the transaction with the result.
  Future<void> _actWith<T>(
    String orderId, {
    required void Function(Order order) check,
    required Future<T> Function() prepare,
    required Order Function(Order order, T prepared) change,
  }) {
    return _guarded(() async {
      final current = await _service.getOrder(orderId);
      if (current == null) {
        throw const WorkerOrderException('This order no longer exists.');
      }
      check(current);
      final prepared = await prepare();
      final saved = await _service.updateOrder(orderId, (order) {
        check(order);
        return change(order, prepared);
      });
      if (saved == null) {
        throw const WorkerOrderException('This order no longer exists.');
      }
    });
  }

  Future<void> _guarded(Future<void> Function() action) async {
    if (actionDelay > Duration.zero) await Future<void>.delayed(actionDelay);
    await guard(
      action,
      label: 'worker order action',
      onError: () => const WorkerOrderException(
        'Could not save the change. Please check your connection and try '
        'again.',
      ),
    );
  }

  /// Throws if a policy check returned an error message.
  void _allow(String? error) {
    if (error != null) throw WorkerOrderException(error);
  }

  /// The orders [worker] can possibly see: a packer's branch, or the
  /// deliveries assigned to a driver. [WorkerOrderPolicy] narrows them.
  ///
  /// Two queries are merged: every unfinished order (no limit, so an old
  /// task is never dropped) and the most recent orders (for My history,
  /// which can stop at a limit).
  Stream<List<Order>> _ordersFor(WorkerProfile worker) {
    if (worker.isPackingStaff) {
      final branchId = worker.branchId;
      if (branchId == null) return Stream.value(const []);
      return _mergeById(
        _service.watchActiveBranchOrders(branchId),
        _service.watchBranchOrders(branchId),
      );
    }
    return _mergeById(
      _service.watchActiveDriverOrders(worker.id),
      _service.watchDriverOrders(worker.id),
    );
  }

  /// Combines the latest list from [active] and [recent] into one list
  /// without duplicates (an order in both appears once, newest copy from
  /// [active]). Sends nothing until both have sent their first list.
  static Stream<List<Order>> _mergeById(
    Stream<List<Order>> active,
    Stream<List<Order>> recent,
  ) {
    late StreamController<List<Order>> controller;
    StreamSubscription<List<Order>>? activeSub;
    StreamSubscription<List<Order>>? recentSub;
    List<Order>? latestActive;
    List<Order>? latestRecent;

    void emit() {
      final a = latestActive;
      final r = latestRecent;
      if (a == null || r == null) return;
      final byId = <String, Order>{
        for (final order in r) order.id: order,
        for (final order in a) order.id: order,
      };
      controller.add(byId.values.toList());
    }

    controller = StreamController<List<Order>>(
      onListen: () {
        activeSub = active.listen((orders) {
          latestActive = orders;
          emit();
        }, onError: controller.addError);
        recentSub = recent.listen((orders) {
          latestRecent = orders;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await activeSub?.cancel();
        await recentSub?.cancel();
      },
    );
    return controller.stream;
  }

  /// A list built by [select], resent only when it changes.
  Stream<List<Order>> _watchList(
    WorkerProfile worker,
    List<Order> Function(List<Order> orders) select,
  ) {
    return _ordersFor(worker).map(select).distinct(listEquals);
  }

  static Order? _find(List<Order> orders, String orderId) {
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  /// Order of the stages in My Deliveries.
  static int _deliveryStage(Order order) {
    switch (order.status) {
      case OrderStatus.outForDelivery:
        return 0;
      case OrderStatus.ready:
        return 1;
      case OrderStatus.packing:
      case OrderStatus.pending:
        return 2;
      case OrderStatus.completed:
        return 3;
      case OrderStatus.cancelled:
        return 4;
    }
  }

  /// Promised time soonest first; then ready the longest.
  static int _byDueThenReady(Order a, Order b) {
    final byDue = _compareDates(a.promisedAt, b.promisedAt);
    return byDue != 0 ? byDue : _compareDates(a.readyAt, b.readyAt);
  }

  /// Earliest first; missing dates last.
  static int _compareDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}
