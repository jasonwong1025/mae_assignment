import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/authentication/data/services/user_service.dart';
import 'package:mae_assignment/shared/models/app_user.dart';

/// Device-free tests for UserService using an in-memory Firestore fake.
/// These run in the plain Dart VM: no device, emulator, or network, so they
/// are the same on macOS, Windows and Linux. The emulator-backed rules tests
/// in test_firebase/ cover firestore.rules; this covers the Dart logic.
void main() {
  late FakeFirebaseFirestore firestore;
  late UserService userService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    userService = UserService(firestore);
  });

  AppUser customer(String uid, {String name = 'May', String phone = ''}) {
    return AppUser(
      uid: uid,
      name: name,
      email: '$uid@example.com',
      phone: phone,
      role: UserRole.customer,
    );
  }

  group('createUser / getUser', () {
    test('creates a profile that can be read back', () async {
      await userService.createUser(customer('uid-1', phone: '0123456789'));

      final loaded = await userService.getUser('uid-1');

      expect(loaded, isNotNull);
      expect(loaded!.name, 'May');
      expect(loaded.phone, '0123456789');
      expect(loaded.role, UserRole.customer);
      // toMap writes a server timestamp, which the fake resolves to a date.
      expect(loaded.createdAt, isNotNull);
    });

    test('getUser returns null when the profile is missing', () async {
      expect(await userService.getUser('does-not-exist'), isNull);
    });

    test('uid is the document id, not a stored field', () async {
      await userService.createUser(customer('uid-1'));

      final raw = await firestore.collection('users').doc('uid-1').get();
      expect(raw.data()!.containsKey('uid'), isFalse);
    });
  });

  group('getOrCreateCustomer', () {
    test('creates a new customer when none exists', () async {
      final result = await userService.getOrCreateCustomer(customer('uid-1'));

      expect(result.uid, 'uid-1');
      expect(result.role, UserRole.customer);
      expect(await userService.getUser('uid-1'), isNotNull);
    });

    test('keeps an existing profile instead of overwriting it', () async {
      await userService.createUser(
        customer('uid-1', name: 'Preferred Name', phone: '0199999999'),
      );

      // A later Google sign-in proposes different details for the same uid.
      final result = await userService.getOrCreateCustomer(
        customer('uid-1', name: 'Google Name'),
      );

      expect(result.name, 'Preferred Name');
      expect(result.phone, '0199999999');
    });

    test('preserves a store role on an existing document', () async {
      await firestore.collection('users').doc('uid-1').set({
        'name': 'Admin',
        'email': 'uid-1@example.com',
        'phone': '',
        'role': UserRole.storeAdmin.name,
      });

      final result = await userService.getOrCreateCustomer(customer('uid-1'));

      expect(result.role, UserRole.storeAdmin);
    });
  });
}
