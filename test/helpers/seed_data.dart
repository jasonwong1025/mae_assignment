import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Loads the same demo data the real project is seeded with
/// (`test_firebase/seed-data/*.json`) into an in-memory Firestore, so the
/// Store Admin tests run on exactly the orders, staff and driver positions
/// a teammate sees after `node seed.mjs`.
///
/// Times in the seed files are minutes from the moment of seeding; here that
/// moment is [now].
Future<FakeFirebaseFirestore> seededFirestore({DateTime? now}) async {
  final firestore = FakeFirebaseFirestore();
  final clock = now ?? DateTime.now();

  Object? resolve(Object? value) {
    if (value is List) return [for (final item in value) resolve(item)];
    if (value is Map) {
      if (value.containsKey(r'$minutes')) {
        final minutes = value[r'$minutes']! as int;
        return Timestamp.fromDate(clock.add(Duration(minutes: minutes)));
      }
      if (value.containsKey(r'$geo')) {
        final point = value[r'$geo']! as List;
        return GeoPoint(
          (point[0] as num).toDouble(),
          (point[1] as num).toDouble(),
        );
      }
      return {for (final e in value.entries) e.key as String: resolve(e.value)};
    }
    return value;
  }

  Object? readJson(String name) {
    final file = File('test_firebase/seed-data/$name');
    return jsonDecode(file.readAsStringSync());
  }

  final orders = readJson('orders.json')! as List;
  for (final order in orders) {
    final entry = order as Map<String, dynamic>;
    await firestore
        .collection('orders')
        .doc(entry['id'] as String)
        .set(resolve(entry['data'])! as Map<String, dynamic>);
  }

  final staff = readJson('staff.json')! as Map<String, dynamic>;
  for (final worker in staff['workers'] as List) {
    final data = worker as Map<String, dynamic>;
    final uid = data['uid'] as String;
    await firestore.collection('users').doc(uid).set({
      'name': data['name'],
      'email': data['email'],
      'phone': data['phone'],
      'role': 'storeWorker',
      'workerRole': data['role'],
      'branchId': data['branchId'],
      'isActive': data['isActive'],
      'joinedAt': Timestamp.fromDate(clock),
    });
    final location = data['location'] as List?;
    if (location != null && data['isActive'] == true) {
      await firestore.collection('driverLocations').doc(uid).set({
        'position': GeoPoint(
          (location[0] as num).toDouble(),
          (location[1] as num).toDouble(),
        ),
        'updatedAt': Timestamp.fromDate(clock),
      });
    }
  }
  return firestore;
}
