import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mae_assignment/shared/models/app_user.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/repositories/address_repository.dart';

import '../helpers/fake_address_service.dart';
import '../helpers/fake_auth_repository.dart';

CustomerAddress _address(String label) {
  return CustomerAddress(
    id: '',
    label: label,
    line: '12 Jalan $label',
    location: const LatLng(3.1, 101.6),
  );
}

void main() {
  late FakeAddressService service;
  late FakeAuthRepository auth;
  late AddressRepository repository;

  setUp(() {
    service = FakeAddressService();
    auth = FakeAuthRepository()
      ..signedIn = true
      ..userToSignIn = const AppUser(
        uid: 'u1',
        name: 'Aisha',
        email: 'aisha@example.com',
        phone: '0123456789',
        role: UserRole.customer,
      );
    repository = AddressRepository(service, auth);
  });

  test('the first saved address becomes the default automatically', () async {
    final saved = await repository.addAddress(_address('Home'));
    expect(saved.isDefault, isTrue);

    final all = await repository.getAddresses();
    expect(all.single.isDefault, isTrue);
  });

  test('a later address is not made default on its own', () async {
    await repository.addAddress(_address('Home'));
    final second = await repository.addAddress(_address('Office'));
    expect(second.isDefault, isFalse);
  });

  test('setDefault moves the default to the chosen address', () async {
    final home = await repository.addAddress(_address('Home'));
    final office = await repository.addAddress(_address('Office'));

    await repository.setDefault(office.id);

    final all = await repository.getAddresses();
    final byId = {for (final a in all) a.id: a};
    expect(byId[office.id]!.isDefault, isTrue);
    expect(byId[home.id]!.isDefault, isFalse);
  });

  test('throws AddressException when nobody is signed in', () async {
    auth.signedIn = false;
    await expectLater(
      repository.getAddresses(),
      throwsA(isA<AddressException>()),
    );
  });
}
