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
  }) = _DispatchDriver;

  const DispatchDriver._();

  String get id => worker.id;
  String get firstName => worker.name.split(' ').first;

  bool get isOffline => !worker.isOnDuty || location == null;
  bool get isFree => !isOffline && worker.currentOrderNumber == null;
  bool get isBusy => !isOffline && !isFree;

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
    if (order?.status == OrderStatus.ready) {
      final atBranch = location!.stops.isEmpty;
      return atBranch
          ? 'Waiting at branch #$number'
          : 'Going to branch #$number';
    }
    return 'Delivering #$number';
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

  /// Free drivers, nearest to where [order] is collected first.
  List<DispatchDriver> freeDriversFor(Order order) {
    final point = pickUpPoint(order);
    return drivers.where((driver) => driver.isFree).toList()
      ..sort((a, b) => a.metresTo(point)!.compareTo(b.metresTo(point)!));
  }
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
