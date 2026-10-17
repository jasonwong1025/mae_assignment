import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/data/models/order.dart';
import '../../../shell/presentation/view_models/branch_view_model.dart';
import '../../data/models/driver.dart';
import '../../data/models/driver_location.dart';
import '../../data/repositories/dispatch_repository.dart';
import 'dispatch_state.dart';

/// This branch's deliveries. Updates when an order changes.
final _deliveriesProvider = StreamProvider.autoDispose<List<Order>>((
  ref,
) async* {
  final branchState = await ref.watch(branchViewModelProvider.future);
  final repository = ref.watch(dispatchRepositoryProvider);
  yield* repository.watchDeliveries(branchState.selected.id);
});

final _driversProvider = FutureProvider.autoDispose<List<Driver>>((ref) {
  return ref.watch(dispatchRepositoryProvider).getDrivers();
});

/// Driver locations. Updates every time a driver moves.
final _locationsProvider =
    StreamProvider.autoDispose<Map<String, DriverLocation>>((ref) {
      return ref.watch(dispatchRepositoryProvider).watchLocations();
    });

final dispatchViewModelProvider =
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
    final deliveries = ref.watch(_deliveriesProvider);
    final drivers = ref.watch(_driversProvider);
    final locations = ref.watch(_locationsProvider);

    for (final value in [deliveries, drivers, locations]) {
      if (value.hasError) return AsyncError(value.error!, value.stackTrace!);
    }
    // Deliveries also reload when the branch changes; wait so the old
    // branch's orders are not shown.
    if (branch == null ||
        deliveries.isLoading ||
        !deliveries.hasValue ||
        !drivers.hasValue ||
        !locations.hasValue) {
      return const AsyncLoading();
    }

    return AsyncData(
      DispatchState.from(
        branch: branch,
        deliveries: deliveries.requireValue,
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

    final oldDriver = current.driverOf(order);
    try {
      await ref
          .read(dispatchRepositoryProvider)
          .assignDriver(
            branch: current.branch,
            order: order,
            driver: driver.worker,
            oldDriver: oldDriver?.worker,
            oldDriverLocation: oldDriver?.location,
          );
    } on DispatchException catch (e) {
      return e.message;
    }

    // Drivers changed; load them again.
    ref.invalidate(_driversProvider);
    return null;
  }
}
