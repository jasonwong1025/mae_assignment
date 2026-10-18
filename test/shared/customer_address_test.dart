import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/core/firebase/firestore_paths.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';

void main() {
  group('CustomerAddress.toFirestore', () {
    const address = CustomerAddress(
      id: 'a1',
      label: 'Home',
      line: '12 Jalan Besar',
      location: LatLng(3.1, 101.6),
      note: 'Leave at the guardhouse',
      isDefault: true,
    );

    test('does not store the document id', () {
      expect(address.toFirestore().containsKey('id'), isFalse);
    });

    test('stores the location as a GeoPoint', () {
      final point = address.toFirestore()[AddressFields.location];
      expect(point, isA<GeoPoint>());
      expect((point! as GeoPoint).latitude, 3.1);
      expect((point as GeoPoint).longitude, 101.6);
    });

    test('keeps label, line, note and default flag', () {
      final json = address.toFirestore();
      expect(json[AddressFields.label], 'Home');
      expect(json[AddressFields.line], '12 Jalan Besar');
      expect(json[AddressFields.note], 'Leave at the guardhouse');
      expect(json[AddressFields.isDefault], true);
    });

    test('leaves createdAt to the service', () {
      expect(
        address.toFirestore().containsKey(AddressFields.createdAt),
        isFalse,
      );
    });
  });

  group('CustomerAddress.fromFirestore', () {
    Map<String, dynamic> validMap() {
      return {
        AddressFields.label: 'Home',
        AddressFields.line: '12 Jalan Besar',
        AddressFields.location: const GeoPoint(3.1, 101.6),
        AddressFields.note: 'Ring the bell',
        AddressFields.isDefault: true,
      };
    }

    test('reads a well-formed document', () {
      final address = CustomerAddress.fromFirestore('a1', validMap());

      expect(address.id, 'a1');
      expect(address.label, 'Home');
      expect(address.location, const LatLng(3.1, 101.6));
      expect(address.note, 'Ring the bell');
      expect(address.isDefault, isTrue);
    });

    test('is malformed when the label is missing', () {
      final map = validMap()..remove(AddressFields.label);
      expect(() => CustomerAddress.fromFirestore('a1', map), throwsA(anything));
    });

    test('is malformed when the location is missing', () {
      final map = validMap()..remove(AddressFields.location);
      expect(() => CustomerAddress.fromFirestore('a1', map), throwsA(anything));
    });

    test('defaults note and isDefault when absent', () {
      final map = validMap()
        ..remove(AddressFields.note)
        ..remove(AddressFields.isDefault);
      final address = CustomerAddress.fromFirestore('a1', map);

      expect(address.note, '');
      expect(address.isDefault, isFalse);
    });

    test('reads a Firestore Timestamp into createdAt', () {
      final when = DateTime(2026, 3, 12);
      final map = validMap()
        ..[AddressFields.createdAt] = Timestamp.fromDate(when);
      expect(CustomerAddress.fromFirestore('a1', map).createdAt, when);
    });
  });
}
