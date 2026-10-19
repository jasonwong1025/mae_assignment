import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/models/driver_location.dart';
import 'package:mae_assignment/features/store_admin/dispatch/data/repositories/dispatch_repository.dart';
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
          .assignDriver(order: order, driver: driver.worker);
    } on DispatchException catch (e) {
      return e.message;
    }

    return null;
  }
}
