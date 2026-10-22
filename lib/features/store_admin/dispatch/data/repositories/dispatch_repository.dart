import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/services/driver_location_service.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';
import 'package:mae_assignment/shared/models/order.dart';
import 'package:mae_assignment/shared/services/order_service.dart';

final dispatchRepositoryProvider = Provider<DispatchRepository>((ref) {
  return DispatchRepository(
    ref.watch(orderServiceProvider),
    ref.watch(staffServiceProvider),
    ref.watch(driverLocationServiceProvider),
  );
});

/// Error with a message to show on screen.
class DispatchException extends AppException {
  const DispatchException(super.message);
}

/// Data for the Dispatch tab: delivery orders, drivers and where they are.
/// Orders are the shared `orders` collection (the same ones as the Orders
/// tab), drivers are the active delivery drivers in Staff, and locations
/// come from each driver's own app.
class DispatchRepository {
  DispatchRepository(this._orders, this._staff, this._locations);

  final OrderService _orders;
  final StaffService _staff;
  final DriverLocationService _locations;

  /// Every delivery that is ready or on the road, for all branches. A
  /// driver can be busy with another branch's order, so Dispatch needs them
  /// all to know who is free.
  Stream<List<Order>> watchActiveDeliveries() {
    return _orders.watchActiveDeliveries();
  }

  /// Active delivery drivers, sorted by name.
  Future<List<Driver>> getDrivers() {
    return guard(
      () async {
        final workers = await _staff.getWorkers();
        return [
          for (final worker in workers)
            if (worker.isDriver && worker.isActive)
              Driver(id: worker.id, name: worker.name, isOnDuty: true),
        ]..sort((a, b) => a.name.compareTo(b.name));
      },
      label: 'drivers',
      onError: () => const DispatchException(
        'Could not load the drivers. Please try again.',
      ),
    );
  }

  /// Live driver locations, by driver id.
  Stream<Map<String, DriverLocation>> watchLocations() {
    return _locations.watchLocations();
  }

  /// Gives [order] to [driver]. Any old driver of the order is set free,
  /// because a driver's current order is worked out from the orders.
  ///
  /// A driver may hold up to [maxActiveOrders] deliveries at once;
  /// [activeOrders] is how many they hold now.
  Future<void> assignDriver({
    required Order order,
    required Driver driver,
    required int activeOrders,
    required int maxActiveOrders,
  }) {
    if (!driver.isOnDuty) {
      throw DispatchException('${driver.name} is not on duty.');
    }
    if (activeOrders >= maxActiveOrders) {
      throw DispatchException(
        '${driver.name} already has $activeOrders deliveries.',
      );
    }
    if (order.addressLocation == null) {
      throw const DispatchException('This order has no address on the map.');
    }
    return guard(
      () => _orders.assignDriver(
        order.id,
        driverId: driver.id,
        driverName: driver.name.split(' ').first,
      ),
      label: 'assign driver',
      onError: () => const DispatchException(
        'Could not assign the driver. Please try again.',
      ),
    );
  }
}
