import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/store_worker/delivery/data/position_throttle.dart';

void main() {
  final start = DateTime(2026, 10, 16, 15);
  const here = LatLng(3, 101.5);
  // About 55 metres north of [here] (0.0005 degrees of latitude).
  const farther = LatLng(3.0005, 101.5);
  // About 11 metres north.
  const nearby = LatLng(3.0001, 101.5);

  late PositionThrottle throttle;

  setUp(() {
    throttle = PositionThrottle();
  });

  test('the first fix is always saved', () {
    expect(throttle.shouldSave(here, start), isTrue);
  });

  test('a fix is not saved again within the minimum interval', () {
    throttle.saved(here, start);

    expect(
      throttle.shouldSave(farther, start.add(const Duration(seconds: 5))),
      isFalse,
    );
  });

  test('after the interval, a move of 30 m or more is saved', () {
    throttle.saved(here, start);

    expect(
      throttle.shouldSave(farther, start.add(const Duration(seconds: 12))),
      isTrue,
    );
  });

  test('a small move is not saved before the heartbeat', () {
    throttle.saved(here, start);

    expect(
      throttle.shouldSave(nearby, start.add(const Duration(seconds: 20))),
      isFalse,
    );
  });

  test('a driver who has not moved is still saved at the heartbeat', () {
    throttle.saved(here, start);

    expect(
      throttle.shouldSave(here, start.add(const Duration(seconds: 30))),
      isTrue,
    );
  });

  test('saving restarts the clock', () {
    throttle
      ..saved(here, start)
      ..saved(farther, start.add(const Duration(seconds: 12)));

    expect(
      throttle.shouldSave(
        const LatLng(3.001, 101.5),
        start.add(const Duration(seconds: 15)),
      ),
      isFalse,
    );
  });
}
