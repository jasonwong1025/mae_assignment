import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/store_admin/staff/data/models/worker.dart';
import 'package:mae_assignment/features/store_admin/staff/data/services/staff_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late StaffService service;

  final worker = Worker(
    id: 'w1',
    name: 'Daniel Lee',
    email: 'daniel@grocerly.test',
    phone: '012-555 0141',
    role: WorkerRole.packingStaff,
    branchId: 'ss15',
    isActive: true,
    joinedAt: DateTime(2025, 3, 12),
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = StaffService(firestore);
  });

  test('getWorkers returns only store workers', () async {
    await firestore.collection('users').doc('w1').set({
      ...worker.toFirestore(),
      'role': 'storeWorker',
    });
    await firestore.collection('users').doc('c1').set({
      'name': 'Aisha',
      'role': 'customer',
    });

    final workers = await service.getWorkers();

    expect(workers.map((w) => w.id), ['w1']);
    expect(workers.single.name, 'Daniel Lee');
  });

  test('updateWorker never changes the login email', () async {
    await firestore.collection('users').doc('w1').set({
      ...worker.toFirestore(),
      'role': 'storeWorker',
    });

    await service.updateWorker(
      worker.copyWith(name: 'Daniel L.', email: 'changed@grocerly.test'),
    );

    final data = (await firestore.collection('users').doc('w1').get()).data()!;
    expect(data['name'], 'Daniel L.');
    expect(data['email'], 'daniel@grocerly.test');
  });
}
