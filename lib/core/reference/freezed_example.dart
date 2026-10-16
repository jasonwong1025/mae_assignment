// Reference patterns for Freezed, kept as a copyable example for the team.
//
// Freezed generates immutable data classes (with ==, hashCode, copyWith,
// toString) and sealed unions (with pattern-matching via `switch`). New
// models and view-model states should follow these two shapes. Existing
// hand-written models are intentionally left as they are; we do not retrofit.
//
// After editing any file with these annotations, regenerate with:
//   fvm dart run build_runner build
// or, while developing, keep it running:
//   fvm dart run build_runner watch
//
// The generated code lives in freezed_example.freezed.dart, which the
// analyzer ignores (see analysis_options.yaml) and git ignores (*.freezed.dart
// is not committed).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'freezed_example.freezed.dart';

/// Pattern 1 — an immutable data model.
///
/// Use for domain/data objects. Freezed provides value equality, copyWith and
/// toString for free. (For Firestore, add fromMap/toMap by hand as the
/// existing models do; add json_serializable only when the model maps to real
/// JSON, e.g. a Cloud Functions or Gemini payload.)
@freezed
abstract class ExampleCartLine with _$ExampleCartLine {
  const factory ExampleCartLine({
    required String productId,
    required String name,
    required double unitPrice,
    @Default(1) int quantity,
  }) = _ExampleCartLine;
}

/// Pattern 2 — a sealed union for view-model state.
///
/// Use for the discrete states a screen can be in. `switch` over the union is
/// exhaustive, so adding a case the UI forgot to handle is a compile error.
@freezed
sealed class ExampleCheckoutState with _$ExampleCheckoutState {
  const factory ExampleCheckoutState.idle() = ExampleCheckoutIdle;
  const factory ExampleCheckoutState.submitting() = ExampleCheckoutSubmitting;
  const factory ExampleCheckoutState.success(String orderId) =
      ExampleCheckoutSuccess;
  const factory ExampleCheckoutState.failure(String message) =
      ExampleCheckoutFailure;
}
