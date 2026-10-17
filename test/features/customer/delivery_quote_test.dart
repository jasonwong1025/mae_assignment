import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/features/customer/cart/presentation/view_models/selected_address_view_model.dart';
import 'package:mae_assignment/shared/models/branch.dart';

Branch _branch({double maxDeliveryKm = 8}) {
  return Branch(
    id: 'ss15',
    name: 'SS15 Subang',
    address: '1 Jalan SS15',
    phone: '0377778888',
    location: const LatLng(3.0757, 101.5869),
    weeklyHours: const [],
    maxDeliveryKm: maxDeliveryKm,
    baseDeliveryFee: 3,
    feePerKm: 0.5,
  );
}

void main() {
  group('quoteFor', () {
    test('a nearby address is in range with a base-plus-distance fee', () {
      // ~1.1 km north of the branch.
      final quote = quoteFor(
        branch: _branch(),
        destination: const LatLng(3.0857, 101.5869),
      );
      expect(quote.inRange, isTrue);
      expect(quote.distanceKm, closeTo(1.11, 0.2));
      // base 3 + ceil(km)=2 * 0.5 = 4.0 (fee rounds distance up to whole km).
      expect(quote.fee, 4);
    });

    test('an address beyond the delivery radius is out of range', () {
      final quote = quoteFor(
        branch: _branch(maxDeliveryKm: 2),
        // ~5.5 km away.
        destination: const LatLng(3.125, 101.5869),
      );
      expect(quote.inRange, isFalse);
      expect(quote.fee, 0);
    });

    test('the branch location itself is in range at the base fee', () {
      final quote = quoteFor(
        branch: _branch(),
        destination: const LatLng(3.0757, 101.5869),
      );
      expect(quote.inRange, isTrue);
      expect(quote.distanceKm, closeTo(0, 0.001));
      // base 3 + 0 km * 0.5 = 3.
      expect(quote.fee, 3);
    });
  });
}
