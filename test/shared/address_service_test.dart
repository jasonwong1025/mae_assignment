import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/services/address_service.dart';

CustomerAddress _address([String label = 'Home']) {
  return CustomerAddress(
    id: '',
    label: label,
    line: '12 Jalan $label',
    location: const LatLng(3.1, 101.6),
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late AddressService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = AddressService(firestore);
  });

  test(
    'addAddress writes under the user and getAddresses reads it back',
    () async {
      final id = await service.addAddress('u1', _address());
      expect(id, isNotEmpty);

      final addresses = await service.getAddresses('u1');
      expect(addresses, hasLength(1));
      expect(addresses.single.label, 'Home');
      expect(addresses.single.id, id);
    },
  );

  test("one user cannot see another user's addresses", () async {
    await service.addAddress('u1', _address('Mine'));
    expect(await service.getAddresses('u2'), isEmpty);
  });

  test('setDefault marks one address and clears the rest', () async {
    final home = await service.addAddress('u1', _address());
    final office = await service.addAddress('u1', _address('Office'));

    await service.setDefault('u1', office);

    final addresses = await service.getAddresses('u1');
    final byId = {for (final a in addresses) a.id: a};
    expect(byId[office]!.isDefault, isTrue);
    expect(byId[home]!.isDefault, isFalse);
  });

  test('deleteAddress removes it', () async {
    final id = await service.addAddress('u1', _address());
    await service.deleteAddress('u1', id);
    expect(await service.getAddresses('u1'), isEmpty);
  });

  test('updateAddress changes the stored fields', () async {
    final id = await service.addAddress('u1', _address());
    final updated = _address().copyWith(id: id, line: 'New line');
    await service.updateAddress('u1', updated);

    final addresses = await service.getAddresses('u1');
    expect(addresses.single.line, 'New line');
  });
}
