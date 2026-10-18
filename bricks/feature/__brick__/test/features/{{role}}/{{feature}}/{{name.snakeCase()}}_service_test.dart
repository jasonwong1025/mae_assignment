import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_assignment/features/{{role}}/{{feature}}/data/models/{{name.snakeCase()}}.dart';
import 'package:mae_assignment/features/{{role}}/{{feature}}/data/services/{{name.snakeCase()}}_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late {{name.pascalCase()}}Service service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = {{name.pascalCase()}}Service(firestore);
  });

  test('create saves the document without the id field', () async {
    final id = await service.create(
      const {{name.pascalCase()}}(id: '', title: 'First'),
    );

    final data = (await firestore.collection('{{collection}}').doc(id).get()).data()!;
    expect(data['title'], 'First');
    expect(data.containsKey('id'), isFalse);
    expect(data.containsKey('createdAt'), isTrue);
  });

  test('the model round-trips through Firestore fields', () {
    const original = {{name.pascalCase()}}(id: 'x1', title: 'First');

    expect(
      {{name.pascalCase()}}.fromFirestore('x1', original.toFirestore()),
      original,
    );
  });

  test('getAll returns the saved documents with their ids', () async {
    final id = await service.create(
      const {{name.pascalCase()}}(id: '', title: 'First'),
    );

    final all = await service.getAll();

    expect(all.map((item) => item.id), [id]);
    expect(all.single.title, 'First');
  });

  test('getAll skips a malformed document', () async {
    await service.create(const {{name.pascalCase()}}(id: '', title: 'Good'));
    await firestore.collection('{{collection}}').doc('bad').set({'note': 'no title'});

    final all = await service.getAll();

    expect(all.map((item) => item.title), ['Good']);
  });
}
