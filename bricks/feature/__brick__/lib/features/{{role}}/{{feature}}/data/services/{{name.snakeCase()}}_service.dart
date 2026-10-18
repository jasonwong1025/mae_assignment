import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/firebase/firestore_config.dart';
import 'package:mae_assignment/core/firebase/firestore_models.dart';
import 'package:mae_assignment/core/firebase/firestore_refs.dart';
import 'package:mae_assignment/features/{{role}}/{{feature}}/data/models/{{name.snakeCase()}}.dart';

final Provider<{{name.pascalCase()}}Service> {{name.camelCase()}}ServiceProvider =
    Provider<{{name.pascalCase()}}Service>(
      (ref) => {{name.pascalCase()}}Service(ref.watch(firebaseFirestoreProvider)),
    );

/// Reads and writes {{collection}}/{id} in Firestore. Only this layer talks to
/// Firestore; paths come from [FirestoreRefs].
class {{name.pascalCase()}}Service {
  {{name.pascalCase()}}Service(FirebaseFirestore firestore)
    : _refs = FirestoreRefs(firestore);

  final FirestoreRefs _refs;

  Future<List<{{name.pascalCase()}}>> getAll() async {
    final snapshot = await _refs.{{collection}}.get().timeout(
      FirestoreConfig.readTimeout,
    );
    return snapshot.toModels(fromFirestore: {{name.pascalCase()}}.fromFirestore);
  }

  /// Saves a new {{name.sentenceCase()}} and returns its id.
  Future<String> create({{name.pascalCase()}} {{name.camelCase()}}) async {
    final doc = _refs.{{collection}}.doc();
    await doc.set({
      ...{{name.camelCase()}}.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}
