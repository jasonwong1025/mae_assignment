import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/road_route.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/repositories/dispatch_repository.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/repositories/route_repository.dart';
import 'package:mae_assignment/features/store_admin/dispatch/presentation/view_models/dispatch_state.dart';
import 'package:mae_assignment/features/store_admin/shell/presentation/view_models/branch_view_model.dart';
import 'package:mae_assignment/shared/models/order.dart';

/// Every delivery that is ready or on the road. Updates when an order
/// changes.
final StreamProvider<List<Order>> _activeDeliveriesProvider =
    StreamProvider.autoDispose<List<Order>>((ref) {
      return ref.watch(dispatchRepositoryProvider).watchActiveDeliveries();
    });

final FutureProvider<List<Driver>> _driversProvider =
    FutureProvider.autoDispose<List<Driver>>((ref) {
      return ref.watch(dispatchRepositoryProvider).getDrivers();
    });

/// Driver locations. Updates every time a driver moves.
final StreamProvider<Map<String, DriverLocation>> _locationsProvider =
    StreamProvider.autoDispose<Map<String, DriverLocation>>((ref) {
      return ref.watch(dispatchRepositoryProvider).watchLocations();
    });

/// Road route through a driver's stops, or null while it loads or if the
/// routing service fails. Until then the map draws straight lines and the
/// table shows straight-line distance and time.
final roadRouteProvider = FutureProvider.autoDispose
    .family<RoadRoute?, RouteStops>((ref, stops) {
      return ref.read(routeRepositoryProvider).roadRoute(stops.points);
    });

/// The points of a route, rounded to about 100 m so a driver's small moves
/// do not ask the routing service again.
@immutable
class RouteStops {
  RouteStops(List<LatLng> points)
    : points = [
        for (final point in points)
          LatLng(_round(point.latitude), _round(point.longitude)),
      ];

  final List<LatLng> points;

  static double _round(double value) => (value * 1000).round() / 1000;

  @override
  bool operator ==(Object other) =>
      other is RouteStops && listEquals(other.points, points);

  @override
  int get hashCode => Object.hashAll(points);
}

final NotifierProvider<DispatchViewModel, AsyncValue<DispatchState>>
dispatchViewModelProvider =
    NotifierProvider.autoDispose<DispatchViewModel, AsyncValue<DispatchState>>(
      DispatchViewModel.new,
    );

/// State for the Dispatch tab: deliveries, drivers and their locations.
/// - AsyncLoading: waiting for the first data
/// - AsyncData: rebuilt whenever an order changes or a driver moves
/// - AsyncError: loading failed
class DispatchViewModel extends Notifier<AsyncValue<DispatchState>> {
  @override
  AsyncValue<DispatchState> build() {
    final branch = ref.watch(branchViewModelProvider).value?.selected;
    final deliveries = ref.watch(_activeDeliveriesProvider);
    final drivers = ref.watch(_driversProvider);
    final locations = ref.watch(_locationsProvider);

    for (final value in [deliveries, drivers, locations]) {
      if (value.hasError) return AsyncError(value.error!, value.stackTrace!);
    }
    if (branch == null ||
        !deliveries.hasValue ||
        !drivers.hasValue ||
        !locations.hasValue) {
      return const AsyncLoading();
    }

    return AsyncData(
      DispatchState.from(
        branch: branch,
        activeDeliveries: deliveries.requireValue,
        drivers: drivers.requireValue,
        locations: locations.requireValue,
      ),
    );
  }

  /// Gives [order] to [driver]. Returns an error message, or null if it
  /// worked.
  Future<String?> assignDriver(Order order, DispatchDriver driver) async {
    final current = state.value;
    if (current == null) return 'Still loading. Please try again.';

    try {
      await ref
          .read(dispatchRepositoryProvider)
          .assignDriver(
            order: order,
            driver: driver.worker,
            activeOrders: driver.activeOrders,
            maxActiveOrders: DispatchDriver.maxActiveOrders,
          );
    } on DispatchException catch (e) {
      return e.message;
    }

    return null;
  }

  /// Gives every order in [batch] to [driver], in drop-off order. Returns an
  /// error message, or null if all were assigned. Stops at the first one
  /// that fails, so the message says which orders still need a driver.
  Future<String?> assignBatch(
    DeliveryBatch batch,
    DispatchDriver driver,
  ) async {
    if (state.value == null) return 'Still loading. Please try again.';
    final repository = ref.read(dispatchRepositoryProvider);
    var held = driver.activeOrders;
    for (final (index, order) in batch.orders.indexed) {
      try {
        await repository.assignDriver(
          order: order,
          driver: driver.worker,
          activeOrders: held,
          maxActiveOrders: DispatchDriver.maxActiveOrders,
        );
        held++;
      } on DispatchException catch (e) {
        final left = batch.orders.skip(index).map((o) => '#${o.number}');
        return '${e.message} Still need a driver: ${left.join(', ')}.';
      }
    }
    return null;
  }
}
