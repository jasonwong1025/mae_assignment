import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/services/driver_location_service.dart';
import 'package:mae_assignment/features/store_admin/orders/data/models/order.dart';
import 'package:mae_assignment/features/store_admin/orders/data/repositories/orders_repository.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/repositories/staff_repository.dart';
import 'package:mae_assignment/shared/models/branch.dart';

final driverLocationServiceProvider = Provider<DriverLocationService>((ref) {
  final service = DriverLocationService();
  ref.onDispose(service.dispose);
  return service;
});

final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return DispatchRepository(
    ref.watch(ordersRepositoryProvider),
    ref.watch(staffRepositoryProvider),
    ref.watch(driverLocationServiceProvider),
  );
});

/// Error with a message to show on screen.
class DispatchException implements Exception {
  const DispatchException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Data for the Dispatch tab: delivery orders, drivers and where they are.
/// Uses the same orders and staff as the Orders and Staff tabs, so an
/// assignment shows up there too.
class DispatchRepository {
  DispatchRepository(this._orders, this._staff, this._locations);

  final OrdersRepository _orders;
  final StaffRepository _staff;
  final DriverLocationService _locations;

  /// Delivery orders of the branch that are ready or on the road.
  Stream<List<Order>> watchDeliveries(String branchId) {
    return _orders.watchTodaysOrders(branchId).map((orders) {
      return orders.where((order) {
        return order.isDelivery &&
            (order.status == OrderStatus.ready ||
                order.status == OrderStatus.outForDelivery);
      }).toList();
    });
  }

  Future<List<Worker>> getDrivers() => _staff.getDrivers();

  /// Live driver locations, by worker id.
  Stream<Map<String, DriverLocation>> watchLocations() {
    return _locations.watchLocations();
  }

  /// Gives [order] to [driver]. Any old driver of the order is set free.
  /// [oldDriver] and [oldDriverLocation] are the current driver, if any.
  Future<void> assignDriver({
    required Branch branch,
    required Order order,
    required Worker driver,
    Worker? oldDriver,
    DriverLocation? oldDriverLocation,
  }) async {
    if (!driver.isOnDuty || driver.currentOrderNumber != null) {
      throw DispatchException('${driver.name} is not free any more.');
    }
    if (order.location == null) {
      throw const DispatchException('This order has no address on the map.');
    }

    // Set the old driver free.
    if (oldDriver != null) {
      await _staff.updateWorker(oldDriver.withCurrentOrder(null));
      _locations.setStops(oldDriver.id, []);
    }

    await _staff.updateWorker(driver.withCurrentOrder(order.number));
    await _orders.updateOrder(
      branch.id,
      order.withDriver(
        driverId: driver.id,
        driverName: driver.name.split(' ').first,
        now: DateTime.now(),
      ),
    );

    // Ready orders: drive to the branch and wait there. The driver app
    // starts the delivery after scanning the order.
    if (order.status == OrderStatus.ready) {
      _locations.setStops(driver.id, [branch.location]);
      return;
    }

    // On the road: collect it from the old driver, then deliver.
    _locations.setStops(driver.id, [
      oldDriverLocation?.position ?? branch.location,
      order.location!,
    ]);
  }
}
