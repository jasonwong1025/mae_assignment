import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/models/order_status.dart';
import '../../../session/data/models/worker_profile.dart';
import '../mock_worker_orders.dart';
import '../models/worker_order.dart';
import '../worker_order_policy.dart';

/// Not autoDispose on purpose: there must be one order store for the whole
/// app, kept while workers switch and screens open and close.
final workerOrdersRepositoryProvider = Provider<WorkerOrdersRepository>((ref) {
  final repository = WorkerOrdersRepository(
    // A short wait so loading spinners can be seen in the preview.
    actionDelay: const Duration(milliseconds: 300),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Error with a message that is safe to show on screen.
class WorkerOrderException implements Exception {
  const WorkerOrderException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Orders for every Store Worker screen: packing, pickup and delivery.
///
/// The backend is not connected yet, so orders are kept in memory and go
/// back to the sample data on restart or [resetDemoData]. There is one
/// list for all workers, so a change made by one worker shows up in every
/// other worker's lists straight away.
///
/// Every method takes the worker using the app. Lists only contain what
/// that worker may see, and actions check WorkerOrderPolicy before
/// changing anything; they throw WorkerOrderException if not allowed.
///
/// The methods already return Streams and Futures, so later only the
/// inside of this class changes (to use Firestore) and the screens stay
/// the same.
class WorkerOrdersRepository {
  WorkerOrdersRepository({
    DateTime Function()? clock,
    this.actionDelay = Duration.zero,
    List<WorkerOrder> Function(DateTime now)? seed,
  }) : _clock = clock ?? DateTime.now,
       _seed = seed ?? seedWorkerOrders {
    _orders = _seed(_clock());
  }

  final DateTime Function() _clock;

  /// Builds the starting orders. Tests can pass their own (e.g. with a
  /// cancelled delivery); the app uses the sample data.
  final List<WorkerOrder> Function(DateTime now) _seed;

  /// Wait before each action, to imitate a network. Zero in tests.
  final Duration actionDelay;

  /// Every order, for all branches. Replaced (never edited) on each
  /// change, so a list handed out earlier never changes under a screen.
  late List<WorkerOrder> _orders;

  /// Sends the new full list after every change. Sync, so each listener
  /// has the change before the action's Future completes.
  final _changes = StreamController<List<WorkerOrder>>.broadcast(sync: true);

  // ---------------------------------------------------------------------
  // Lists
  // ---------------------------------------------------------------------

  /// My Tasks: orders assigned to [worker] to pack that are not ready yet.
  /// Orders being packed come first, then the longest waiting.
  Stream<List<WorkerOrder>> watchMyPackingTasks(WorkerProfile worker) {
    return _watchList((orders) {
      final tasks = orders.where((order) {
        return WorkerOrderPolicy.canViewPackingTask(worker, order) &&
            (order.status == OrderStatus.pending ||
                order.status == OrderStatus.packing);
      }).toList();
      tasks.sort((a, b) {
        if (a.status != b.status) {
          return a.status == OrderStatus.packing ? -1 : 1;
        }
        return a.packerAssignedAt.compareTo(b.packerAssignedAt);
      });
      return tasks;
    });
  }

  /// Ready for Pickup: every ready self-pickup order at [worker]'s branch,
  /// whoever packed it. Ready the longest first.
  Stream<List<WorkerOrder>> watchReadyForPickup(WorkerProfile worker) {
    return _watchList((orders) {
      final ready = orders.where((order) {
        return WorkerOrderPolicy.canViewPickupOrder(worker, order);
      }).toList();
      ready.sort((a, b) => _compareDates(a.readyAt, b.readyAt));
      return ready;
    });
  }

  /// Pickups [worker] handed over, newest first.
  Stream<List<WorkerOrder>> watchMyCompletedPickups(WorkerProfile worker) {
    return _watchList((orders) {
      final done = orders.where((order) {
        return WorkerOrderPolicy.canViewCompletedPickup(worker, order);
      }).toList();
      done.sort((a, b) => _compareDates(b.completedAt, a.completedAt));
      return done;
    });
  }

  /// My Deliveries: every delivery assigned to [worker], in any status.
  /// Sorted by stage (on the way, ready, being packed, finished), then by
  /// when it was assigned.
  Stream<List<WorkerOrder>> watchMyDeliveries(WorkerProfile worker) {
    return _watchList((orders) {
      final deliveries = orders.where((order) {
        return WorkerOrderPolicy.canViewDelivery(worker, order);
      }).toList();
      deliveries.sort((a, b) {
        final byStage = _deliveryStage(a).compareTo(_deliveryStage(b));
        if (byStage != 0) return byStage;
        return _compareDates(a.driverAssignedAt, b.driverAssignedAt);
      });
      return deliveries;
    });
  }

  /// One order, or null if it does not exist or [worker] may not see it
  /// (any more). Sends a new value whenever the order changes.
  Stream<WorkerOrder?> watchOrder(WorkerProfile worker, String orderId) {
    return _watch((orders) {
      final order = _find(orders, orderId);
      if (order == null) return null;
      return WorkerOrderPolicy.canViewOrder(worker, order) ? order : null;
    }, isSame: identical);
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
      );
    });
  }

  // ---------------------------------------------------------------------
  // Self-pickup
  // ---------------------------------------------------------------------

  /// Hands a ready pickup order to the customer. The screen checks the
  /// customer first and passes how it was checked as [method].
  Future<void> completePickup(
    WorkerProfile worker,
    String orderId, {
    required VerificationMethod method,
  }) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkCompletePickup(worker, order));
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

  /// Confirms the driver has the right bag. [code] is the order number
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

  Future<void> completeDelivery(WorkerProfile worker, String orderId) {
    return _act(orderId, (order) {
      _allow(WorkerOrderPolicy.checkCompleteDelivery(worker, order));
      final now = _clock();
      return order.copyWith(
        status: OrderStatus.completed,
        statusSince: now,
        deliveredBy: worker.id,
        deliveredByName: worker.name,
        completedAt: now,
      );
    });
  }

  // ---------------------------------------------------------------------
  // Demo data
  // ---------------------------------------------------------------------

  /// Puts every order back to the sample data. Open lists update at once.
  void resetDemoData() {
    _orders = _seed(_clock());
    _changes.add(_orders);
  }

  void dispose() => _changes.close();

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Runs one action: waits [actionDelay], then reads the order as it is
  /// now (another worker may have changed it during the wait), lets
  /// [change] check the rules and build the new copy, and saves it.
  Future<void> _act(
    String orderId,
    WorkerOrder Function(WorkerOrder order) change,
  ) async {
    if (actionDelay > Duration.zero) await Future<void>.delayed(actionDelay);

    final order = _find(_orders, orderId);
    if (order == null) {
      throw const WorkerOrderException('This order no longer exists.');
    }
    final updated = change(order);
    _orders = [
      for (final existing in _orders)
        existing.id == orderId ? updated : existing,
    ];
    _changes.add(_orders);
  }

  /// Throws if a policy check returned an error message.
  void _allow(String? error) {
    if (error != null) throw WorkerOrderException(error);
  }

  /// A list built by [select], resent after every change that alters it.
  Stream<List<WorkerOrder>> _watchList(
    List<WorkerOrder> Function(List<WorkerOrder> orders) select,
  ) {
    return _watch(select, isSame: _sameOrders);
  }

  /// Sends `select(current orders)` as soon as someone listens, then again
  /// after every change, skipping values that are the same as the last one.
  /// The first value is sent from onListen, before listening for changes,
  /// so a late listener still starts from the latest data.
  Stream<T> _watch<T>(
    T Function(List<WorkerOrder> orders) select, {
    required bool Function(T previous, T next) isSame,
  }) {
    late StreamController<T> controller;
    StreamSubscription<List<WorkerOrder>>? subscription;
    late T last;

    controller = StreamController<T>(
      onListen: () {
        last = select(_orders);
        controller.add(last);
        subscription = _changes.stream.listen(
          (orders) {
            final next = select(orders);
            if (isSame(last, next)) return;
            last = next;
            controller.add(next);
          },
          onDone: controller.close,
        );
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  /// True if both lists hold the very same order objects in the same
  /// order. Orders are replaced when they change, so this means "nothing
  /// in this list changed".
  static bool _sameOrders(List<WorkerOrder> a, List<WorkerOrder> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
  }

  static WorkerOrder? _find(List<WorkerOrder> orders, String orderId) {
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  /// Order of the stages in My Deliveries.
  static int _deliveryStage(WorkerOrder order) {
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

  /// Earliest first; missing dates last.
  static int _compareDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}
