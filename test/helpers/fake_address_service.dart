import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/services/address_service.dart';

/// In-memory AddressService so tests exercise the address flow with no
/// Firebase. Starts empty; seed `addresses` for tests that need some.
class FakeAddressService extends Fake implements AddressService {
  FakeAddressService({List<CustomerAddress> addresses = const []})
    : _addresses = [...addresses];

  final List<CustomerAddress> _addresses;
  int _nextId = 1;

  @override
  Future<List<CustomerAddress>> getAddresses(String uid) async {
    return [..._addresses];
  }

  @override
  Future<String> addAddress(String uid, CustomerAddress address) async {
    final id = 'addr-${_nextId++}';
    _addresses.insert(0, address.copyWith(id: id));
    return id;
  }

  @override
  Future<void> updateAddress(String uid, CustomerAddress address) async {
    final index = _addresses.indexWhere((a) => a.id == address.id);
    if (index != -1) _addresses[index] = address;
  }

  @override
  Future<void> deleteAddress(String uid, String addressId) async {
    _addresses.removeWhere((a) => a.id == addressId);
  }

  @override
  Future<void> setDefault(String uid, String addressId) async {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(
        isDefault: _addresses[i].id == addressId,
      );
    }
  }
}
