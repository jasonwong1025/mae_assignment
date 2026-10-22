import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_worker/orders/data/repositories/worker_orders_repository.dart';
import 'package:mae_assignment/features/store_worker/session/data/models/worker_profile.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

/// The worker's day so far, for the Today card on the Account tab.
///
/// - Packing Staff: orders packed today, their average packing time, and
///   tasks still to pack.
/// - Delivery Drivers: deliveries completed today, and deliveries still
///   to do (on the road or ready to collect).
class WorkerTodaySummary {
  const WorkerTodaySummary({
    required this.doneToday,
    required this.stillToDo,
    this.averageMinutes,
  });

  /// Orders packed (packer) or delivered (driver) since midnight.
  final int doneToday;

  /// Tasks left to pack (packer) or deliveries left to finish (driver).
  final int stillToDo;

  /// Packers only: average minutes from start to ready for today's orders.
  /// Null if none had both times.
  final int? averageMinutes;
}

/// Today's numbers for the signed-in worker, live. Null while loading or
/// when nobody is signed in.
final workerTodaySummaryProvider = Provider.autoDispose<WorkerTodaySummary?>((
  ref,
) {
  final worker = ref.watch(workerSessionProvider);
  if (worker == null) return null;
  final history = ref.watch(_historyProvider(worker)).value;
  final active = ref.watch(_activeProvider(worker)).value;
  if (history == null || active == null) return null;
  return _summarise(worker, history, active, DateTime.now());
});

/// Finished work: packed orders (packer) or completed deliveries (driver).
final _historyProvider = StreamProvider.autoDispose
    .family<List<Order>, WorkerProfile>(
      (ref, worker) =>
          ref.watch(workerOrdersRepositoryProvider).watchMyHistory(worker),
    );

/// Work still open: packing tasks (packer) or assigned deliveries (driver).
final _activeProvider = StreamProvider.autoDispose
    .family<List<Order>, WorkerProfile>((ref, worker) {
      final repository = ref.watch(workerOrdersRepositoryProvider);
      return worker.isPackingStaff
          ? repository.watchMyPackingTasks(worker)
          : repository.watchMyDeliveries(worker);
    });

WorkerTodaySummary _summarise(
  WorkerProfile worker,
  List<Order> history,
  List<Order> active,
  DateTime now,
) {
  final midnight = DateTime(now.year, now.month, now.day);
  bool isToday(DateTime? time) => time != null && !time.isBefore(midnight);

  if (worker.isPackingStaff) {
    final packedToday = history.where((o) => isToday(o.readyAt)).toList();
    final durations = [
      for (final order in packedToday)
        if (order.packingStartedAt case final started?)
          order.readyAt!.difference(started).inMinutes,
    ];
    return WorkerTodaySummary(
      doneToday: packedToday.length,
      stillToDo: active.length,
      averageMinutes: durations.isEmpty
          ? null
          : (durations.reduce((a, b) => a + b) / durations.length).round(),
    );
  }

  return WorkerTodaySummary(
    doneToday: history.where((o) => isToday(o.completedAt)).length,
    stillToDo: active
        .where(
          (o) =>
              o.status == OrderStatus.ready ||
              o.status == OrderStatus.outForDelivery,
        )
        .length,
  );
}
