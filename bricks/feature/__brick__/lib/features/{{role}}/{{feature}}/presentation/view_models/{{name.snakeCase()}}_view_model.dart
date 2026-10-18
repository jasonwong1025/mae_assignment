import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mae_assignment/features/{{role}}/{{feature}}/data/models/{{name.snakeCase()}}.dart';
import 'package:mae_assignment/features/{{role}}/{{feature}}/data/repositories/{{name.snakeCase()}}_repository.dart';

/// autoDispose: the list is read again each time the screen opens. Drop
/// `.autoDispose` only if the state must survive moving between tabs.
///
/// `retry: (_, _) => null` so a failed load shows the screen's retry button
/// instead of retrying silently with a delay.
final AsyncNotifierProvider<{{name.pascalCase()}}ViewModel, List<{{name.pascalCase()}}>>
{{name.camelCase()}}ViewModelProvider =
    AsyncNotifierProvider.autoDispose<{{name.pascalCase()}}ViewModel, List<{{name.pascalCase()}}>>(
      {{name.pascalCase()}}ViewModel.new,
      retry: (_, _) => null,
    );

/// State for the {{name.sentenceCase()}} screen.
class {{name.pascalCase()}}ViewModel extends AsyncNotifier<List<{{name.pascalCase()}}>> {
  @override
  Future<List<{{name.pascalCase()}}>> build() {
    return ref.watch({{name.camelCase()}}RepositoryProvider).getAll();
  }
}
