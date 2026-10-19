import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/position_throttle.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/repositories/driver_tracking_repository.dart';
import 'package:mae_assignment/features/store_worker/session/presentation/view_models/worker_session_view_model.dart';

part 'driver_tracking_view_model.freezed.dart';

/// What the delivery screen shows about location sharing.
@freezed
abstract class DriverTrackingState with _$DriverTrackingState {
  const factory DriverTrackingState({
    /// True once a position has been shared.
    @Default(false) bool isSharing,

    /// What stops sharing (location off, permission refused, no connection),
    /// or null when all is well.
    String? error,
  }) = _DriverTrackingState;
}

/// Source of "now" for the throttle; tests replace it.
final Provider<DateTime Function()> trackingClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// Starts the repeating check that repeats a stationary driver's last
/// position. A provider so widget tests can switch the timer off (a timer
/// still running when a test ends fails it).
final Provider<Timer? Function(Duration every, void Function() tick)>
trackingTimerProvider =
    Provider<Timer? Function(Duration every, void Function() tick)>(
      (ref) =>
          (every, tick) => Timer.periodic(every, (_) => tick()),
    );

/// Shares the driver's position on one order while something watches this
/// provider (the delivery screen watches it only while the order is out for
/// delivery). autoDispose: leaving the screen, or completing the delivery,
/// stops the GPS and the timer.
final driverTrackingViewModelProvider = NotifierProvider.autoDispose
    .family<DriverTrackingViewModel, DriverTrackingState, String>(
      DriverTrackingViewModel.new,
    );

class DriverTrackingViewModel extends Notifier<DriverTrackingState> {
  DriverTrackingViewModel(this.orderId);

  final String orderId;

  final PositionThrottle _throttle = PositionThrottle();
  StreamSubscription<LatLng>? _subscription;
  Timer? _heartbeat;
  LatLng? _latest;

  @override
  DriverTrackingState build() {
    final worker = ref.watch(workerSessionProvider);
    if (worker == null) return const DriverTrackingState();

    final repository = ref.read(driverTrackingRepositoryProvider);
    final now = ref.read(trackingClockProvider);

    Future<void> share(LatLng position) async {
      _throttle.saved(position, now());
      try {
        await repository.publish(orderId, worker.id, position);
        if (ref.mounted) state = const DriverTrackingState(isSharing: true);
      } on AppException catch (error) {
        if (ref.mounted) state = state.copyWith(error: error.message);
      }
    }

    _subscription = repository.watchPosition().listen(
      (position) {
        _latest = position;
        if (_throttle.shouldSave(position, now())) unawaited(share(position));
      },
      onError: (Object error) {
        state = DriverTrackingState(
          error: error is AppException
              ? error.message
              : 'Your location could not be read.',
        );
      },
    );
    // A driver stuck in traffic produces no new fixes; repeat the last one so
    // the customer can see the phone is still sharing.
    _heartbeat = ref.read(trackingTimerProvider)(_throttle.heartbeat, () {
      final latest = _latest;
      if (latest != null && _throttle.shouldSave(latest, now())) {
        unawaited(share(latest));
      }
    });
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      _heartbeat?.cancel();
    });
    return const DriverTrackingState();
  }
}
