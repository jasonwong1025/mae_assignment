import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Set with `--dart-define=WORKER_PREVIEW=true` to allow the preview in a
/// profile build (e.g. to record the demo video).
const bool _workerPreviewFlag = bool.fromEnvironment('WORKER_PREVIEW');

/// The Store Worker preview runs on mock data with no Firebase sign-in, so
/// it must never reach a real release:
/// - debug builds: always on
/// - profile builds: only with the WORKER_PREVIEW flag
/// - release builds: always off
const bool workerPreviewAllowed =
    kDebugMode || (kProfileMode && _workerPreviewFlag);

/// Whether the preview can be used. A provider, so tests can turn it off.
final workerPreviewEnabledProvider = Provider<bool>((ref) {
  return workerPreviewAllowed;
});
