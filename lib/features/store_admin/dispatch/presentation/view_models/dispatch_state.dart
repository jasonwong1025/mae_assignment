import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';
import 'package:mae_assignment/shared/models/branch.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/models/order_status.dart';

part 'dispatch_state.freezed.dart';

const _distance = Distance();

/// Average city speed used for arrival times: 30 km/h.
const _metresPerMinute = 500.0;

/// A driver with their live location and this branch's order they handle.
@freezed
abstract class DispatchDriver with _$DispatchDriver {
  const factory DispatchDriver({
    required Driver worker,

    /// Null if the driver shares no location.
    DriverLocation? location,

    /// Null if free or busy with another branch's order.
    Order? order,

    /// Deliveries assigned to the driver that are ready or on the road, at
    /// any branch.
    @Default(0) int activeOrders,
  }) = _DispatchDriver;

  const DispatchDriver._();

  /// Most deliveries a driver may hold at once (ready or on the road), so
  /// nearby orders can share a trip without overloading anyone.
  static const maxActiveOrders = 3;

  String get id => worker.id;
  String get firstName => worker.name.split(' ').first;

  bool get isOffline => !worker.isOnDuty || location == null;
  bool get isFree => !isOffline && worker.currentOrderNumber == null;
  bool get isBusy => !isOffline && !isFree;

  /// How many more deliveries the driver can take now.
  int get spareCapacity => isOffline
      ? 0
      : (maxActiveOrders - activeOrders).clamp(0, maxActiveOrders);

  /// "Free", or the load, e.g. "2 active", for the driver picker.
  String get loadText => activeOrders == 0 ? 'free' : '$activeOrders active';

  /// Line from the driver through each stop and on to the customer.
  /// Empty if there is no trip.
  List<LatLng> get route {
    final location = this.location;
    if (location == null) return const [];

    final points = [location.position, ...location.stops];
    // Ready orders: the trip ends at the branch; show the rest too.
    final customer = order?.addressLocation;
    if (order?.status == OrderStatus.ready && customer != null) {
      points.add(customer);
    }
    return points.length < 2 ? const [] : points;
  }

  /// Length of [route].
  double get metresLeft {
    final points = route;
    var metres = 0.0;
    for (var i = 1; i < points.length; i++) {
      metres += _distance(points[i - 1], points[i]);
    }
    return metres;
  }

  int get minutesLeft => (metresLeft / _metresPerMinute).ceil();

  /// Straight-line distance to [point]. Null if the location is unknown.
  double? metresTo(LatLng point) {
    final location = this.location;
    if (location == null) return null;
    return _distance(location.position, point);
  }

  /// What the driver is doing, e.g. "Delivering #2290".
  String get statusText {
    if (isOffline) return 'Offline';
    if (isFree) return 'Free';

    final number = worker.currentOrderNumber;
    final more = activeOrders > 1 ? ' +${activeOrders - 1} more' : '';
    if (order?.status == OrderStatus.ready) {
      final atBranch = location!.stops.isEmpty;
      return atBranch
          ? 'Waiting at branch #$number$more'
          : 'Going to branch #$number$more';
    }
    return 'Delivering #$number$more';
  }
}

/// Everything the Dispatch tab shows for one branch.
@freezed
abstract class DispatchState with _$DispatchState {
  const factory DispatchState({
    required Branch branch,

    /// This branch's delivery orders that are ready or on the road.
    required List<Order> deliveries,

    /// All active drivers.
    required List<DispatchDriver> drivers,
  }) = _DispatchState;

  const DispatchState._();

  /// Joins the data together and sorts it.
  ///
  /// [activeDeliveries] are the ready or on-the-road deliveries of every
  /// branch: a driver's current order is the one assigned to them, and only
  /// this branch's are listed as [deliveries]. A driver's route is worked
  /// out here rather than stored: a ready order is collected at the branch,
  /// an order on the road goes to the customer.
  factory DispatchState.from({
    required Branch branch,
    required List<Order> activeDeliveries,
    required List<Driver> drivers,
    required Map<String, DriverLocation> locations,
  }) {
    final deliveries = [
      for (final order in activeDeliveries)
        if (order.branchId == branch.id) order,
    ];

    final dispatchDrivers = [
      for (final worker in drivers)
        _dispatchDriver(
          worker: worker,
          branch: branch,
          deliveries: deliveries,
          activeDeliveries: activeDeliveries,
          position: locations[worker.id]?.position,
        ),
    ];

    // Free drivers nearest the branch first, then busy, then offline.
    int group(DispatchDriver driver) {
      if (driver.isFree) return 0;
      return driver.isBusy ? 1 : 2;
    }

    dispatchDrivers.sort((a, b) {
      if (group(a) != group(b)) return group(a).compareTo(group(b));
      if (a.isFree) {
        return a
            .metresTo(branch.location)!
            .compareTo(b.metresTo(branch.location)!);
      }
      return a.worker.name.compareTo(b.worker.name);
    });

    // Orders without a driver first, then the longest waiting.
    final sortedDeliveries = [...deliveries]
      ..sort((a, b) {
        final aWaits = a.driverId == null;
        final bWaits = b.driverId == null;
        if (aWaits != bWaits) return aWaits ? -1 : 1;
        return a.statusStartedAt.compareTo(b.statusStartedAt);
      });

    return DispatchState(
      branch: branch,
      deliveries: sortedDeliveries,
      drivers: dispatchDrivers,
    );
  }

  List<Order> get needsDriver {
    return deliveries.where((order) => order.driverId == null).toList();
  }

  int get freeCount => drivers.where((driver) => driver.isFree).length;
  int get busyCount => drivers.where((driver) => driver.isBusy).length;
  int get offlineCount => drivers.where((driver) => driver.isOffline).length;

  Order? orderByNumber(int? number) {
    return deliveries.where((order) => order.number == number).firstOrNull;
  }

  DispatchDriver? driverById(String? id) {
    return drivers.where((driver) => driver.id == id).firstOrNull;
  }

  DispatchDriver? driverOf(Order order) => driverById(order.driverId);

  /// Where a new driver collects [order]: the branch, or the current
  /// driver if it is already on the road.
  LatLng pickUpPoint(Order order) {
    if (order.status == OrderStatus.ready) return branch.location;
    return driverOf(order)?.location?.position ?? branch.location;
  }

  /// Drivers who can take [order] now: free, or busy with fewer than
  /// [DispatchDriver.maxActiveOrders] deliveries. Nearest to where it is
  /// collected first. Its current driver is left out.
  List<DispatchDriver> driversFor(Order order) {
    final point = pickUpPoint(order);
    return drivers
        .where(
          (driver) => driver.spareCapacity > 0 && driver.id != order.driverId,
        )
        .toList()
      ..sort((a, b) => a.metresTo(point)!.compareTo(b.metresTo(point)!));
  }

  /// Drivers with room for every order in [batch], nearest the branch first.
  List<DispatchDriver> driversForBatch(DeliveryBatch batch) {
    return drivers
        .where((driver) => driver.spareCapacity >= batch.orders.length)
        .toList()
      ..sort(
        (a, b) => a
            .metresTo(branch.location)!
            .compareTo(b.metresTo(branch.location)!),
      );
  }

  /// Ready orders without a driver whose customers are close together and
  /// due around the same time, so one driver can take them in one trip.
  /// Suggestions only: the admin still picks the driver.
  ///
  /// Greedy and simple, which is enough for a branch's handful of orders:
  /// the order due soonest starts a group, and the nearest others within
  /// [batchRadiusMetres] and [batchDueWindow] of it join, up to
  /// [maxBatchSize]. Distances are straight lines, not roads.
  List<DeliveryBatch> get batchSuggestions {
    final waiting = [
      for (final order in needsDriver)
        if (order.status == OrderStatus.ready && order.addressLocation != null)
          order,
    ]..sort((a, b) => _dueOf(a).compareTo(_dueOf(b)));

    final used = <String>{};
    final batches = <DeliveryBatch>[];
    for (final seed in waiting) {
      if (used.contains(seed.id)) continue;
      final seedPoint = seed.addressLocation!;
      final nearby =
          [
            for (final other in waiting)
              if (other.id != seed.id &&
                  !used.contains(other.id) &&
                  _distance(seedPoint, other.addressLocation!) <=
                      batchRadiusMetres &&
                  _dueOf(other).difference(_dueOf(seed)).abs() <=
                      batchDueWindow)
                other,
          ]..sort(
            (a, b) => _distance(
              seedPoint,
              a.addressLocation!,
            ).compareTo(_distance(seedPoint, b.addressLocation!)),
          );
      if (nearby.isEmpty) continue;

      final group = [seed, ...nearby.take(maxBatchSize - 1)];
      used.addAll(group.map((order) => order.id));
      batches.add(DeliveryBatch.plan(branch.location, group));
    }
    return batches;
  }

  /// When an order is due: the saved due time, or the delivery service
  /// level (an hour after it was placed).
  static DateTime _dueOf(Order order) {
    return order.dueAt ??
        order.placedAt?.add(const Duration(hours: 1)) ??
        order.statusStartedAt;
  }
}

/// Customers this close (straight line) can share a trip.
const batchRadiusMetres = 1500.0;

/// Orders due this close together can share a trip, so nobody waits much
/// longer because of another customer.
const batchDueWindow = Duration(minutes: 30);

/// Most orders suggested for one trip.
const maxBatchSize = 3;

/// A suggested trip: ready orders from one branch, in the order the driver
/// should drop them off.
class DeliveryBatch {
  const DeliveryBatch({
    required this.orders,
    required this.tripMetres,
    required this.spreadMetres,
  });

  /// Plans the stops from [branch]: always the nearest customer next.
  factory DeliveryBatch.plan(LatLng branch, List<Order> orders) {
    final left = [...orders];
    final stops = <Order>[];
    var here = branch;
    var trip = 0.0;
    while (left.isNotEmpty) {
      left.sort(
        (a, b) => _distance(
          here,
          a.addressLocation!,
        ).compareTo(_distance(here, b.addressLocation!)),
      );
      final next = left.removeAt(0);
      trip += _distance(here, next.addressLocation!);
      here = next.addressLocation!;
      stops.add(next);
    }

    var spread = 0.0;
    for (final a in orders) {
      for (final b in orders) {
        final metres = _distance(a.addressLocation!, b.addressLocation!);
        if (metres > spread) spread = metres;
      }
    }
    return DeliveryBatch(orders: stops, tripMetres: trip, spreadMetres: spread);
  }

  /// In drop-off order.
  final List<Order> orders;

  /// Branch to the last customer, through each stop (straight lines).
  final double tripMetres;

  /// Furthest apart two of the customers are.
  final double spreadMetres;

  /// Changes whenever the orders in it change, for widget keys.
  String get key => orders.map((order) => order.id).join('+');
}

/// How close counts as having arrived at a stop.
const _arrivedMetres = 75.0;

DispatchDriver _dispatchDriver({
  required Driver worker,
  required Branch branch,
  required List<Order> deliveries,
  required List<Order> activeDeliveries,
  required LatLng? position,
}) {
  // A driver can hold several orders at once (the worker app allows it).
  // Dispatch follows the one on the road first, then the lowest number, and
  // prefers this branch's order so the map and the status line agree.
  final mine =
      [
        for (final order in activeDeliveries)
          if (order.driverId == worker.id) order,
      ]..sort((a, b) {
        final aOnRoad = a.status == OrderStatus.outForDelivery ? 0 : 1;
        final bOnRoad = b.status == OrderStatus.outForDelivery ? 0 : 1;
        if (aOnRoad != bOnRoad) return aOnRoad.compareTo(bOnRoad);
        return a.number.compareTo(b.number);
      });
  final order = mine.where((order) => order.branchId == branch.id).firstOrNull;
  final current = order ?? mine.firstOrNull;

  // The one stop still ahead, if the driver has not reached it yet.
  LatLng? stop;
  if (order?.status == OrderStatus.ready) {
    stop = branch.location;
  } else if (order?.status == OrderStatus.outForDelivery) {
    stop = order?.addressLocation;
  }
  final arrived =
      stop != null &&
      position != null &&
      _distance(position, stop) <= _arrivedMetres;

  return DispatchDriver(
    activeOrders: mine.length,
    worker: worker.withCurrentOrder(current?.number),
    location: position == null
        ? null
        : DriverLocation(
            position: position,
            stops: stop == null || arrived ? const [] : [stop],
          ),
    order: order,
  );
}
