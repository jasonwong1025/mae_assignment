import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mae_assignment/core/firebase/field_readers.dart';

part '{{name.snakeCase()}}.freezed.dart';

/// A {{name.sentenceCase()}}, stored at {{collection}}/{id}.
///
/// Add the field names below to `firestore_paths.dart` (use them instead of
/// the string literals here), then keep `firestore.rules` and
/// `DATABASE/FIRESTORE.md` in step.
@freezed
abstract class {{name.pascalCase()}} with _${{name.pascalCase()}} {
  const factory {{name.pascalCase()}}({
    required String id,
    required String title,

    /// Null until Firestore has saved the server time.
    DateTime? createdAt,
  }) = _{{name.pascalCase()}};

  const {{name.pascalCase()}}._();

  /// Reads {{collection}}/{id}. A missing title throws, so the document is
  /// skipped when reading a list.
  factory {{name.pascalCase()}}.fromFirestore(String id, Map<String, dynamic> data) {
    return {{name.pascalCase()}}(
      id: id,
      title: data.requiredString('title'),
      createdAt: data.dateTime('createdAt'),
    );
  }

  /// The id is the document id, and `createdAt` is added by the service with
  /// the server time, so neither is written from here.
  Map<String, dynamic> toFirestore() {
    return {'title': title};
  }
}
