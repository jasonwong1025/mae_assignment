import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/core/errors/app_exception.dart';
import 'package:mae_assignment/features/{{role}}/{{feature}}/data/models/{{name.snakeCase()}}.dart';
import 'package:mae_assignment/features/{{role}}/{{feature}}/data/services/{{name.snakeCase()}}_service.dart';

final Provider<{{name.pascalCase()}}Repository> {{name.camelCase()}}RepositoryProvider =
    Provider<{{name.pascalCase()}}Repository>((ref) {
      return {{name.pascalCase()}}Repository(ref.watch({{name.camelCase()}}ServiceProvider));
    });

/// Error with a message that is safe to show on screen.
class {{name.pascalCase()}}Exception extends AppException {
  const {{name.pascalCase()}}Exception(super.message);
}

/// The {{name.sentenceCase()}} data for the rest of the app. Turns Firestore
/// failures into a friendly [{{name.pascalCase()}}Exception] with the shared
/// [guard].
class {{name.pascalCase()}}Repository {
  {{name.pascalCase()}}Repository(this._service);

  final {{name.pascalCase()}}Service _service;

  Future<List<{{name.pascalCase()}}>> getAll() => _run(_service.getAll);

  Future<String> create({{name.pascalCase()}} {{name.camelCase()}}) {
    return _run(() => _service.create({{name.camelCase()}}));
  }

  Future<T> _run<T>(Future<T> Function() call) {
    return guard(
      call,
      label: '{{name.snakeCase()}}',
      onError: () => const {{name.pascalCase()}}Exception(kNetworkErrorMessage),
    );
  }
}
