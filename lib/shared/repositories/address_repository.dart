import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/authentication/data/repositories/auth_repository.dart';
import 'package:mae_assignment/shared/models/customer_address.dart';
import 'package:mae_assignment/shared/services/address_service.dart';

final Provider<AddressRepository> addressRepositoryProvider =
    Provider<AddressRepository>((ref) {
      return AddressRepository(
        ref.watch(addressServiceProvider),
        ref.watch(authRepositoryProvider),
      );
    });

/// Error with a message that is safe to show on screen.
class AddressException implements Exception {
  const AddressException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A customer's saved delivery addresses. Resolves the signed-in user's uid
/// itself, so callers never pass it, and turns Firestore errors into
/// friendly [AddressException]s.
class AddressRepository {
  AddressRepository(this._service, this._auth);

  final AddressService _service;
  final AuthRepository _auth;

  Future<String> _requireUid() async {
    final user = await _auth.getCurrentUser();
    if (user == null) {
      throw const AddressException('Please sign in to manage addresses.');
    }
    return user.uid;
  }

  /// The signed-in customer's saved addresses, newest first.
  Future<List<CustomerAddress>> getAddresses() {
    return _run(() async {
      final uid = await _requireUid();
      return await _service.getAddresses(uid);
    });
  }

  /// Saves a new address and returns it with its id. The first address a
  /// customer saves becomes their default automatically.
  Future<CustomerAddress> addAddress(CustomerAddress address) {
    return _run(() async {
      final uid = await _requireUid();
      final existing = await _service.getAddresses(uid);
      final makeDefault = address.isDefault || existing.isEmpty;
      final toSave = address.copyWith(isDefault: makeDefault);
      final id = await _service.addAddress(uid, toSave);
      if (makeDefault) await _service.setDefault(uid, id);
      return toSave.copyWith(id: id);
    });
  }

  Future<void> updateAddress(CustomerAddress address) {
    return _run(() async {
      final uid = await _requireUid();
      await _service.updateAddress(uid, address);
    });
  }

  Future<void> deleteAddress(String addressId) {
    return _run(() async {
      final uid = await _requireUid();
      await _service.deleteAddress(uid, addressId);
    });
  }

  Future<void> setDefault(String addressId) {
    return _run(() async {
      final uid = await _requireUid();
      await _service.setDefault(uid, addressId);
    });
  }

  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AddressException {
      rethrow;
    } on Object catch (error) {
      debugPrint('Address request failed: $error');
      throw const AddressException(
        'Could not reach the server. Please check your connection and '
        'try again.',
      );
    }
  }
}

/// The signed-in customer's saved addresses, for the picker and the account
/// screen. Re-reads when invalidated after an add/edit/delete.
final FutureProvider<List<CustomerAddress>> savedAddressesProvider =
    FutureProvider<List<CustomerAddress>>((ref) {
      return ref.watch(addressRepositoryProvider).getAddresses();
    });
